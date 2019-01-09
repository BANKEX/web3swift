//
//  BitcoinAddress.swift
//  web3swift
//
//  Created by Dmitry on 26/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import CoreBlockchain

extension PrivateKey {
    public func btcAddress(network: BTCNetworkId = .mainnet) -> BTCAddress {
        return try! BTCAddress(publicKey: publicKey, network: network.rawValue)
    }
}

open class BTCAddress: Address58 {
    open override var string: String {
        return data.base58(.bitcoin)
    }
}

public enum BTCNetworkId: UInt8 {
    case mainnet = 0x00
    case testnet = 0x6f
}

