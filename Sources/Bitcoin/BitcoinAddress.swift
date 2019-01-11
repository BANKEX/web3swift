//
//  BitcoinAddress.swift
//  web3swift
//
//  Created by Dmitry on 26/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit
import CoreBlockchain

extension PrivateKey {
    public func bitcoinAddress(network: BTCNetworkId = .mainnet) -> BitcoinAddress {
        return publicKey.bitcoinAddress(network: network)
    }
}
extension PublicKey {
    public func bitcoinAddress(network: BTCNetworkId = .mainnet) -> BitcoinAddress {
        return try! BitcoinAddress(publicKey: self, network: network.rawValue)
    }
}

open class BitcoinAddress: Address58 {
    public func balance() -> Promise<Int64> {
        return URLSession.web3.get("https://insight.bitpay.com/api/addr/\(string)/balance").map(on: .web3) {
            let string = $0.string
            if let balance = Int64(string) {
                return balance
            } else {
                throw NSError(domain: string, code: 0, userInfo: nil)
            }
        }
    }
}

public enum BTCNetworkId: UInt8 {
    case mainnet = 0x00
    case testnet = 0x6f
}

