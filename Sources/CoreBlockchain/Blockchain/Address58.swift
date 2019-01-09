//
//  Address58.swift
//  web3swift
//
//  Created by Dmitry on 08/01/2019.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import Foundation

open class Address58 {
    public let data: Data
    open var string: String {
        return data.base58(.bitcoin)
    }
    public init(_ data: Data) {
        self.data = data
    }
    public init(publicKey: Data, network: UInt8 = 0x00) throws {
        let publicKey = try SECP256K1.compressed(publicKey: publicKey)
        var encrypted = publicKey.sha256.ripemd160
        encrypted.insert(network, at: 0)
        encrypted.append(encrypted.sha256.sha256[..<4])
        data = encrypted
    }
}
