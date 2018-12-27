//
//  RippleAddress.swift
//  web3swift
//
//  Created by Dmitry on 12/24/18.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

public struct RippleNetworkId: RawRepresentable {
    public var rawValue: UInt8
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

extension PrivateKey {
    func rippleAddress() -> RippleAddress {
        return try! RippleAddress(publicKey: publicKey)
    }
}
class RippleAddress: Address58 {
    override var string: String {
        var string = data.base58(.ripple)
        string[0] = "r"
        return string
    }
}

