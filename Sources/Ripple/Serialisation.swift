//
//  Serialisation.swift
//  Ripple
//
//  Created by Dmitry on 1/15/19.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import Foundation
import CoreBlockchain

protocol REncodable {
    func encode(to data: RippleWriter)
}

func sortKeys(_ json: Any) -> [(String, Any)] {
    return []
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
}
