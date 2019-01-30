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
    public func bitcoinAddress(network: BitcoinNetworkId = .mainnet) -> BitcoinAddress {
        return publicKey.bitcoinAddress(network: network)
    }
}
extension PublicKey {
    public func bitcoinAddress(network: BitcoinNetworkId = .mainnet) -> BitcoinAddress {
        return BitcoinAddress(publicKey: self, network: network)
    }
}

open class BitcoinAddress: Address58 {
    public init?(_ base58: String) {
        guard let data = try? base58.base58(.bitcoin, check: true) else { return nil }
        super.init(data)
    }
    public override init(_ data: Data) {
        super.init(data)
    }
    public init(publicKey: PublicKey, network: BitcoinNetworkId) {
        let data = publicKey.bitcoinAddress().base58Check(.bitcoin, network.rawValue)
        super.init(data)
    }
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

public enum BitcoinNetworkId: UInt8 {
    case mainnet = 0x00
    case testnet = 0x6f
}

