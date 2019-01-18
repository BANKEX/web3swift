//
//  AES.swift
//  web3swift
//
//  Created by Dmitry on 30/11/2018.
//

import Foundation
import CommonCrypto

//extension Data {
//    var bytes: Array<UInt8> {
//        return Array(self)
//    }
//}

enum AesMode {
    case ctr
    case cbc
    var cc: CCMode {
        switch self {
        case .cbc:
            return CCMode(kCCModeCBC)
        case .ctr:
            return CCMode(kCCModeCTR)
        }
    }
    enum Error: Swift.Error {
        case invalidType(String)
    }
    init(_ string: String) throws {
        switch string {
        case "aes-128-ctr": self = .ctr
        case "aes-128-cbc": self = .cbc
        default: throw Error.invalidType(string)
        }
    }
    func blockMode(_ iv: Data) -> BlockMode {
        switch self {
        case .ctr: return CTR(iv: iv.bytes)
        case .cbc: return CBC(iv: iv.bytes)
        }
    }
}

public enum AESPadding {
    case noPadding, pkcs5, pkcs7
    var cc: CCPadding {
        switch self {
        case .noPadding:
            return CCPadding(ccNoPadding)
        case .pkcs5:
            return CCPadding(ccPKCS7Padding)
        case .pkcs7:
            return CCPadding(ccPKCS7Padding)
        }
    }
}
public struct BlockMode {
    var mode: AesMode
    var iv: Data
}

public func CBC(iv: [UInt8]) -> BlockMode {
    return BlockMode(mode: .cbc, iv: Data(iv))
}
public func CTR(iv: [UInt8]) -> BlockMode {
    return BlockMode(mode: .ctr, iv: Data(iv))
}

public class AES {
    var blockMode: BlockMode
    var padding: AESPadding
    var key: Data
    public init(key: [UInt8], blockMode: BlockMode, padding: AESPadding) {
        self.blockMode = blockMode
        self.padding = padding
        self.key = Data(key)
    }
    
    public func encrypt(_ data: [UInt8]) throws -> [UInt8] {
        return try encrypt(Data(data)).bytes
    }
    public func encrypt(_ data: Data) throws -> Data {
        let iv = blockMode.iv
        let mode = blockMode.mode
        guard key.count == kCCKeySizeAES128 else {
            throw AESError.badKeyLength
        }
        guard iv.count == kCCBlockSizeAES128 else {
            throw AESError.badInputVectorLength
        }
        var outLength = 0
        var outBytes = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
        var length = 0
        
        var cryptor: CCCryptorRef!
        try CCCryptorCreateWithMode(CCOperation(kCCEncrypt), mode.cc, CCAlgorithm(kCCAlgorithmAES128), padding.cc, •iv, •key, key.count, nil, 0, 0, CCModeOptions(kCCModeOptionCTR_BE), &cryptor).check()
        try CCCryptorUpdate(cryptor, •data, data.count, &outBytes, outBytes.count, &outLength).check()
        length += outLength
        try CCCryptorFinal(cryptor, &outBytes + outLength, outBytes.count, &outLength).check()
        length += outLength
        
        return Data(bytes: •outBytes, count: length)
    }
    
    public func decrypt(_ data: [UInt8]) throws -> [UInt8] {
        return try decrypt(Data(data)).bytes
    }
    public func decrypt(_ data: Data) throws -> Data {
        let iv = blockMode.iv
        let mode = blockMode.mode
        guard key.count == kCCKeySizeAES128 else {
            throw AESError.badKeyLength
        }
        guard iv.count == kCCBlockSizeAES128 else {
            throw AESError.badInputVectorLength
        }
        var outLength = 0
        var outBytes = [UInt8](repeating: 0, count: data.count + kCCBlockSizeAES128)
        var length = 0
        
        var cryptor: CCCryptorRef!
        try CCCryptorCreateWithMode(CCOperation(kCCDecrypt), mode.cc, CCAlgorithm(kCCAlgorithmAES128), padding.cc, •iv, •key, key.count, nil, 0, 0, CCModeOptions(kCCModeOptionCTR_BE), &cryptor).check()
        try CCCryptorUpdate(cryptor, •data, data.count, &outBytes, outBytes.count, &outLength).check()
        length += outLength
        try CCCryptorFinal(cryptor, &outBytes + outLength, outBytes.count, &outLength).check()
        length += outLength
        
        return Data(bytes: •outBytes, count: length)
    }
}

private extension CCCryptorStatus {
    func check() throws {
        guard self == kCCSuccess else { throw AESError.cryptoFailed(status: self) }
    }
}

private func aes128(key: Data, iv: Data, input: Data, operation: CCOperation, padding: AESPadding, mode: AesMode) throws -> Data {
    guard key.count == kCCKeySizeAES128 else {
        throw AESError.badKeyLength
    }
    guard iv.count == kCCBlockSizeAES128 else {
        throw AESError.badInputVectorLength
    }
    var outLength = 0
    var outBytes = [UInt8](repeating: 0, count: input.count + kCCBlockSizeAES128)
    var length = 0
    
    var cryptor: CCCryptorRef!
    try CCCryptorCreateWithMode(operation, mode.cc, CCAlgorithm(kCCAlgorithmAES128), padding.cc, •iv, •key, key.count, nil, 0, 0, CCModeOptions(kCCModeOptionCTR_BE), &cryptor).check()
    try CCCryptorUpdate(cryptor, •input, input.count, &outBytes, outBytes.count, &outLength).check()
    length += outLength
    try CCCryptorFinal(cryptor, &outBytes + outLength, outBytes.count, &outLength).check()
    length += outLength
    
    return Data(bytes: •outBytes, count: length)
}

enum AESError: Swift.Error {
    case cryptoFailed(status: CCCryptorStatus)
    case badKeyLength
    case badInputVectorLength
}
