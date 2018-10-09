//
//  EthereumStringEncodingExtensions.swift
//  web3swift
//
//  Created by Alexander Vlasov on 09.05.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

extension BigUInt: EventFilterEncodable {
    public func eventFilterEncoded() -> String? {
        return self.abiEncode(bits: 256)?.toHexString().withHex
    }
}

extension BigInt: EventFilterEncodable {
    public func eventFilterEncoded() -> String? {
        return self.abiEncode(bits: 256)?.toHexString().withHex
    }
}

extension Data: EventFilterEncodable {
    public func eventFilterEncoded() -> String? {
        guard let padded = self.setLengthLeft(32) else { return nil }
        return padded.toHexString().withHex
    }
}

extension EthereumAddress: EventFilterEncodable {
    public func eventFilterEncoded() -> String? {
        guard let padded = self.addressData.setLengthLeft(32) else { return nil }
        return padded.toHexString().withHex
    }
}

extension String: EventFilterEncodable {
    public func eventFilterEncoded() -> String? {
        guard let data = self.data(using: .utf8) else { return nil }
        return data.sha3(.keccak256).toHexString().withHex
    }
}


