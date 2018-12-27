//
//  BitcoinAddress.swift
//  web3swift
//
//  Created by Dmitry on 26/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

extension PrivateKey {
    func btcAddress(network: BTCNetworkId = .mainnet) -> BTCAddress {
        return try! BTCAddress(publicKey: publicKey, network: network.rawValue)
    }
}

class BTCAddress: Address58 {
    override var string: String {
        return data.base58(.bitcoin)
    }
}

public enum BTCNetworkId: UInt8 {
    case mainnet = 0x00
    case testnet = 0x6f
}

class Address58 {
    let data: Data
    var string: String {
        return data.base58(.bitcoin)
    }
    init(_ data: Data) {
        self.data = data
    }
    init(publicKey: Data, network: UInt8 = 0x00) throws {
        let publicKey = try SECP256K1.compressed(publicKey: publicKey)
        var encrypted = publicKey.sha256.ripemd160
        encrypted.insert(network, at: 0)
        encrypted.append(encrypted.sha256.sha256[..<4])
        data = encrypted
    }
}
