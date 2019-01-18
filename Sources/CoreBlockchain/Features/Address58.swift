//
//  Address58.swift
//  web3swift
//
//  Created by Dmitry on 08/01/2019.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import Foundation

extension PublicKey {
    public func bitcoinAddress() -> Data {
        return compressed().data.sha256.ripemd160
    }
}

open class Address58 {
    public let data: Data
    open var string: String {
        return data.base58(.bitcoin)
    }
    public init(_ data: Data) {
        self.data = data
    }
}
