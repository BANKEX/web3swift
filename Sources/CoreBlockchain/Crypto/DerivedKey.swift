//
//  Encryption.swift
//  web3swift
//
//  Created by Dmitry on 27/11/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

protocol DerivedKey {
    func calculate(password: Data) throws -> Data
}

enum DecryptionError: Error {
    case invalidPassword
}

enum DerivedKeyType {
    enum Error: Swift.Error {
        case invalidType(String)
    }
    case scrypt
    case pbkdf2
    init(_ type: String) throws {
        switch type {
        case "scrypt": self = .scrypt
        case "pbkdf2": self = .pbkdf2
        default: throw Error.invalidType(type)
        }
    }
    func derivedKey(_ json: AnyReader) throws -> DerivedKey {
        switch self {
        case .scrypt: return try Scrypt(json: json)
        case .pbkdf2: return try PBKDF2Object(json: json)
        }
    }
}

//extension HMAC.Variant {
//    init(_ string: String) throws {
//        switch string {
//        case "hmac-sha256":
//            self = HMAC.Variant.sha256
//        case "hmac-sha384":
//            self = HMAC.Variant.sha384
//        case "hmac-sha512":
//            self = HMAC.Variant.sha512
//        default:
//            throw PBKDF2Object.Error.unknownHmacAlgorithm(string)
//        }
//    }
//    var digestLength: Int {
//        switch self {
//        case .sha1:
//            return 20
//        case .sha256:
//            return SHA2.Variant.sha256.digestLength
//        case .sha384:
//            return SHA2.Variant.sha384.digestLength
//        case .sha512:
//            return SHA2.Variant.sha512.digestLength
//        case .md5:
//            return 16
//        }
//    }
//}


public enum HmacVariant {
    case sha1, sha224, sha256, sha384, sha512
    var cc: PBKDF.PseudoRandomAlgorithm {
        switch self {
        case .sha1: return .sha1
        case .sha224: return .sha224
        case .sha256: return .sha256
        case .sha384: return .sha384
        case .sha512: return .sha512
        }
    }
    var c: HMAC.Algorithm {
        switch self {
        case .sha1: return .sha1
        case .sha224: return .sha224
        case .sha256: return .sha256
        case .sha384: return .sha384
        case .sha512: return .sha512
        }
    }
    
    public init(_ string: String) throws {
        switch string {
        case "hmac-sha256":
            self = HmacVariant.sha256
        case "hmac-sha384":
            self = HmacVariant.sha384
        case "hmac-sha512":
            self = HmacVariant.sha512
        default:
            throw PBKDF2Object.Error.unknownHmacAlgorithm(string)
        }
    }
    var digestLength: Int {
        switch self {
        case .sha1:
            return 160 / 8
        case .sha224:
            return 224 / 8
        case .sha256:
            return 256 / 8
        case .sha384:
            return 384 / 8
        case .sha512:
            return 512 / 8
        }
    }
}

extension HMAC {
    enum HMACError: Error {
        case authenticationFailed
    }
    public convenience init(key: [UInt8], variant: HmacVariant) {
        self.init(using: variant.c, key: Data(key))
    }
    public func authenticate(_ bytes: [UInt8]) throws -> [UInt8] {
        if let data = update(byteArray: bytes)?.final() {
            return data
        } else {
            throw HMACError.authenticationFailed
        }
    }
}
public func BetterPBKDF(password: [UInt8], salt: [UInt8], iterations: Int, keyLength: Int, variant: HmacVariant) throws -> [UInt8] {
    let string = String(bytes: password, encoding: .utf8)!
    return try PBKDF.deriveKey(fromPassword: string, salt: salt, prf: variant.cc, rounds: UInt32(iterations), derivedKeyLength: UInt(keyLength))
}

class PBKDF2Object: DerivedKey {
    enum Error: Swift.Error {
        case unknownHmacAlgorithm(String)
        case invalidParameters
        var localizedDescription: String {
            switch self {
            case let .unknownHmacAlgorithm(string):
                return "Unknown hmac algorithm \"\(string)\". Allowed: hmac-sha256, hmac-sha384, hmac-sha512"
            case .invalidParameters:
                return "Cannot load PBKDF2 with provided parameters"
            }
        }
    }
    let variant: HmacVariant
    let keyLength: Int
    let iterations: Int
    let salt: [UInt8]
    
    init(salt: Data, iterations: Int, keyLength: Int, variant: HmacVariant) {
        self.salt = Array(salt)
        self.keyLength = keyLength
        self.iterations = iterations
        self.variant = variant
    }
    init(json: AnyReader) throws {
        variant = try HmacVariant(json.at("prf").string())
        keyLength = try json.at("dklen").int()
        iterations = try json.at("c").int()
        salt = try Array(json.at("salt").data())
        guard iterations > 0 && !salt.isEmpty else { throw Error.invalidParameters }
        if Double(keyLength) > (pow(2, 32) - 1) * Double(variant.digestLength) {
            throw Error.invalidParameters
        }
    }
    
    func calculate(password: Data) throws -> Data {
        do {
            return try Data(BetterPBKDF(password: Array(password), salt: Array(salt), iterations: iterations, keyLength: keyLength, variant: variant))
        } catch {
            throw DecryptionError.invalidPassword
        }
    }
}


/**
 Scrypt function. Used to generate derivedKey from password, salt, n, r, p
 */
class Scrypt: DerivedKey {
    enum ScryptError: Swift.Error {
        case nIsTooLarge
        case rIsTooLarge
        case nMustBeAPowerOf2GreaterThan1
        
        var localizedDescription: String {
            switch self {
            case .nIsTooLarge:
                return "Scrypt error: N is too large"
            case .rIsTooLarge:
                return "Scrypt error: R is too large"
            case .nMustBeAPowerOf2GreaterThan1:
                return "Scrypt error: N must be a power of two and greater than 1"
            }
        }
    }
    enum Error: Swift.Error {
        case invalidPassword
        case invalidSalt
        var localizedDescription: String {
            switch self {
            case .invalidPassword:
                return "Scrypt error: invalid password"
            case .invalidSalt:
                return "Scrypt error: invalid salt"
            }
        }
    }
    
    let salt: Data // S
    let dkLen: Int
    let n: Int
    let r: Int
    let p: Int
    
    init(salt: Data, dkLen: Int, N: Int, r: Int, p: Int) throws {
        guard !(N < 2 || (N & (N - 1)) != 0) else { throw ScryptError.nMustBeAPowerOf2GreaterThan1 }
        
        guard N <= .max / 128 / r else { throw ScryptError.nIsTooLarge }
        guard r <= .max / 128 / p else { throw ScryptError.rIsTooLarge }
        
        self.n = N
        self.r = r
        self.p = p
        self.salt = salt
        self.dkLen = dkLen
    }
    init(json: AnyReader) throws {
        dkLen = try json.at("dklen").int()
        n = try json.at("n").int()
        r = try json.at("r").int()
        p = try json.at("p").int()
        salt = try json.at("salt").data()
    }
    
    /// Runs the key derivation function with a specific password.
    func calculate(password: Data) throws -> Data {
        return try scrypt(password: password.string, salt: salt, length: dkLen, N: n, R: r, P: p)
    }
}
