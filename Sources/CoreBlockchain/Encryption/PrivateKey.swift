//
//  PrivateKey.swift
//  web3swift
//
//  Created by Dmitry on 29/11/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

/**
 Secp256k1 private key.
 
 Used in ethereum accounts. You can get public key, address and sign some data
 
 ## Performance
 
 > Operations per second in debug and release build mode
 ```
 Generate Private key:
 release            debug
 175772             160180
 
 PrivateKey -> Public Key:
 release            debug
 26642              9036
 
 PrivateKey -> Address:
 release            debug
 11894              2058
 ```
 */
public class PrivateKey {
    /// Private key data
    public var privateKey: Data
    
    /// Singleton that generates public key from private key
    public lazy var publicKey = PublicKey(try! SECP256K1.privateToPublic(privateKey: privateKey))
    
    /// Generates random private key. All generated keys are verified
    public init() {
        self.privateKey = .random(length: 32)
    }
    
    /// Init with private key data. run .verify() to verify it
    public init(_ privateKey: Data) {
        self.privateKey = privateKey
    }
    
    /// Signs hash with private key signature
    ///
    /// - Parameter hash: 32 bytes hash. To get hash call data.keccak256()
    /// - Returns: Signature that you can use in your transactions
    /// - Throws: If hash size invalid hash size or private key. Call privateKey.verify()
    public func sign(hash: Data) throws -> Signature {
        let signature = try SECP256K1.signForRecovery(hash: hash, privateKey: privateKey).serializedSignature
        return Signature(data: signature)
    }
    
    /// Verifies the private key. Also every 32 byte private keys are valid
    ///
    /// - Throws: SECP256K1Error.invalidPrivateKey
    public func verify() throws {
        try SECP256K1.verifyPrivateKey(privateKey: privateKey)
    }
}

public class PublicKey {
    public var data: Data
    public init(_ data: Data) {
        self.data = data
    }
    public func check() throws {
        
    }
    public func compressed() throws -> PublicKey {
        guard self.data.count != 33 else { return self }
        let data = try SECP256K1.combineSerializedPublicKeys(keys: [self.data], outputCompressed: true)
        return PublicKey(data)
    }
    public func decompressed() throws -> PublicKey {
        guard self.data.count != 65 else { return self }
        let data = try SECP256K1.combineSerializedPublicKeys(keys: [self.data], outputCompressed: false)
        return PublicKey(data)
    }
    public func ethereumAddress() throws -> Address {
        var stipped = try decompressed().data
        if stipped.count == 65 {
            guard stipped[0] == 4 else { throw PublicKeyError.invalidPublicKeySize }
            return Address(stipped[1..<65].keccak256()[12..<32])
        }
        guard stipped.count == 64 else { throw PublicKeyError.invalidPublicKeySize }
        return Address(stipped.keccak256()[12 ..< 32])
    }
}
public enum PublicKeyError: Error {
    case invalidPublicKeySize
}


/// Signature of some hash. You can get it by calling PrivateKey.sign(hash:)
public class Signature {
    /// Signature data
    public let data: Data
    
    /// Init with data. Don't forget to call .check(compressed:) if you want to init with custom data
    ///
    /// - Parameter data: Signature data
    public init(data: Data) {
        self.data = data
    }
    
    
    /// Checks for signature
    ///
    /// - Parameter compressed: Checks for compressed signature (33 bytes long)
    /// - Throws: SECP256K1Error.invalidSignatureSize or SECP256DataError.signatureCorrupted
    public func check(compressed: Bool = false) throws {
        if compressed {
            guard data.count == 33 else { throw SECP256K1Error.invalidSignatureSize }
        } else {
            guard data.count == 65 else { throw SECP256K1Error.invalidSignatureSize }
        }
        guard v < 4 else { throw SECP256DataError.signatureCorrupted }
    }
    
    /// Signature first 32 bytes
    public lazy var r = BigUInt(data[0..<32])
    /// Signature next 32 bytes
    public lazy var s = BigUInt(data[32..<64])
    /// Last signature byte. Should be less than 4
    public lazy var v: UInt8 = {
        var v = data.last!
        if v >= 27 {
            v = v - 27
        }
        return v
    }()
}


