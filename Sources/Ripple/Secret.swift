//
//  Account.swift
//  Ripple
//
//  Created by Dmitry on 1/9/19.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import Foundation
import CoreBlockchain

public class Secret {
    public var data: Data
    public var string: String {
        return data.base58(.ripple, prefix: RipplePrefix.secret)
    }
    public init(_ secret: String) throws {
        data = try secret.base58(.ripple, check: true, prefix: RipplePrefix.secret)
    }
    public init() {
        data = .random(length: 16)
    }
    public subscript(index: UInt32) -> PrivateKey {
        let accountIndex = Data(raw: index)
        let curveOrder = UInt256(0xffffffffffffffff,0xfffffffffffffffe,0xbaaedce6af48a03b,0xbfd25e8cd0364141)
        var counter: UInt32 = 0
        
        let rootAccount = familyGenerator
        var update1: UInt256 = 0
        let privateKey = UInt256(rootAccount.privateKey)
        let publicKey = rootAccount.publicKey.compressed()
        repeat {
            let update = publicKey.data + accountIndex + Data(raw: counter)
            update1 = privateKey &+ UInt256(update.sha512)
            counter += 1
        } while update1 > curveOrder
        return PrivateKey(update1 % curveOrder)
    }
    public var familyGenerator: PrivateKey {
        let curveOrder = UInt256(0xffffffffffffffff,0xfffffffffffffffe,0xbaaedce6af48a03b,0xbfd25e8cd0364141)
        var counter = UInt32()
        var privateKey: UInt256
        repeat {
            privateKey = UInt256((data + Data(raw: counter)).sha512)
            counter += 1
        } while privateKey > curveOrder
        return PrivateKey(privateKey.data)
    }
}
