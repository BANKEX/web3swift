//
//  Serialisation.swift
//  Ripple
//
//  Created by Dmitry on 1/15/19.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import Foundation
import CoreBlockchain
import PromiseKit

protocol REncodable {
    func encode(to data: RippleWriter)
}

class RippleWriter: DataWriter {
    func write(key: String, value: REncodable) {
        append(data: key.data)
        value.encode(to: self)
    }
    func append(length: Int) {
        var length = length
        if (length <= 192) {
            append(byte: UInt8(length))
        } else if (length <= 12480) {
            length -= 193
            let a = UInt8(193 + (length >> 8))
            let b = UInt8(length & 0xff)
            append(bytes: [a,b])
        } else if (length <= 918744) {
            length -= 12481
            let a = UInt8(241 + (length >> 16))
            let b = UInt8((length >> 8) & 0xff)
            let c = UInt8(length & 0xff)
            append(bytes: [a,b,c])
        }
    }
    func append(_ dictionary: [String: Any]) throws {
        
    }
    func append(key: String, value: AnyReader, filters: [(Definition)->(Bool)] = []) throws {
        guard let definition = Definitions.main[key] else { return }
        let fieldCode = definition.nth
        let typeCode = definition.type
        var byte: UInt8 = 0
        if fieldCode < 16 {
            byte = UInt8(fieldCode)
        }
        if typeCode < 16 {
            byte += UInt8(typeCode) << 4
        }
        append(byte: byte)
        if typeCode >= 16 {
            append(byte: UInt8(typeCode))
        }
        if fieldCode >= 16 {
            append(byte: UInt8(fieldCode))
        }
        switch typeCode {
        case 1: try append(uint16: value)
        case 2: try append(uint32: value)
        case 3: try append(uint64: value)
        case 4: try append(hash128: value)
        case 5: try append(hash256: value)
        case 6: try append(amount: value)
        case 7: try append(blob: value)
        case 8: try append(accountId: value)
        case 14: try append(stObject: value)
        case 15: try append(stArray: value)
        case 16: try append(uint8: value)
        case 17: try append(hash160: value)
        case 18: try append(pathSet: value)
        case 19: try append(vector256: value)
        default: break
        }
    }
    func append(accountId: AnyReader) throws {
        let account = try accountId.rippleAddress()
        append(data: account.data)
    }
    func append(amount: AnyReader) throws {
        
    }
    func append(blob: AnyReader) throws {
        let data = try blob.data()
        append(length: data.count)
        append(data: data)
    }
    func append(hash128: AnyReader) throws {
        let data = try hash128.data()
        append(data: data)
    }
    func append(hash160: AnyReader) throws {
        let data = try hash160.data()
        append(data: data)
    }
    func append(hash256: AnyReader) throws {
        let data = try hash256.data()
        append(data: data)
    }
    func append(pathSet: AnyReader) throws {
        
    }
    func append(stArray: AnyReader) throws {
        
    }
    func append(stObject: AnyReader) throws {
        
    }
    func append(uint8: AnyReader) throws {
        
    }
    func append(uint16: AnyReader) throws {
        let value = try uint16.uint64()
        append(raw: UInt16(value))
    }
    func append(uint32: AnyReader) throws {
        let value = try uint32.uint64()
        append(raw: UInt32(value))
    }
    func append(transaction: AnyReader) throws {
        
    }
    func append(ledgerEntry: AnyReader) throws {
        
    }
    func append(validation: AnyReader) throws {
        
    }
    func append(metadata: AnyReader) throws {
        
    }
    func append(uint64: AnyReader) throws {
        let value = try uint64.uint64()
        append(raw: UInt64(value))
    }
    func append(vector256: AnyReader) throws {
        
    }
}
