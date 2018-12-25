//
//  XRPAccount.swift
//  web3swift
//
//  Created by Dmitry on 12/24/18.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
public enum BTCNetworkId: UInt8 {
    case mainnet = 0x00
    case testnet = 0x6f
}

public struct XRPNetworkId: RawRepresentable {
    public var rawValue: UInt8
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

extension PrivateKey {
    func btcAddress(network: BTCNetworkId = .mainnet) -> BTCAddress {
        return try! BTCAddress(publicKey: publicKey, network: network.rawValue)
    }
    func xrpAddress() -> XRPAddress {
        return try! XRPAddress(publicKey: publicKey)
    }
}

class BTCAddress: Address58 {
    override var string: String {
        return data.base58(.bitcoin)
    }
}
class XRPAddress: Address58 {
    override var string: String {
        var string = data.base58(.ripple)
        string[0] = "r"
        return string
    }
}

class Address58 {
    let data: Data
    var string: String {
        return data.base58(.bitcoin)
    }
    init(_ data: Data) {
        self.data = data
    }
    init(publicKey: Data, network: UInt8 = 0) throws {
        let publicKey = try SECP256K1.compressed(publicKey: publicKey)
        let sha = publicKey.sha256()
        var a = RIPEMD160()
        a.update(data: sha)
        var encrypted = a.finalize()
        encrypted.insert(network, at: 0)
        encrypted.append(encrypted.sha256().sha256()[..<4])
        data = encrypted
    }
}
