//
//  RippleAddress.swift
//  web3swift
//
//  Created by Dmitry on 12/24/18.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit
import CoreBlockchain

public struct RippleNetworkId: RawRepresentable {
    public var rawValue: UInt8
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

extension PrivateKey {
    public func rippleAddress() -> RippleAddress {
        return try! RippleAddress(publicKey: publicKey)
    }
}
public class RippleAddress: Address58 {
    public override var string: String {
        var string = data.base58(.ripple)
        string[0] = "r"
        return string
    }
}

