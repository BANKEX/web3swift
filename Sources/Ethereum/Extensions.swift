//
//  Extensions.swift
//  CoreBlockchain
//
//  Created by Dmitry on 08/01/2019.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import Foundation
import CoreBlockchain

extension BlockNumber: JEncodable {
    public func jsonRpcValue(with network: NetworkProvider) -> Any {
        return promise(network: network).jsonRpcValue(with: network)
    }
}

extension AnyReader {
    /// Tries to represent raw as string then string as address
    /// - Returns: Address
    /// - Throws: DictionaryReader.Error.unconvertible
    public func address() throws -> Address {
        let string = try self.string()
        guard string.count >= 42 else { throw unconvertible(to: "Address") }
        guard string != "0x" && string != "0x0" else { return .contractDeployment }
        let address = Address(String(string[..<42]))
        // already checked for size. so don't need to check again for address.isValid
        // guard address.isValid else { throw Error.unconvertible }
        return address
    }
}

extension Address: JEncodable {
    public func jsonRpcValue(with network: NetworkProvider) -> Any {
        return address
    }
}

extension PrivateKey {
    /// Singleton that generates address from public key
    public var address: Address {
        return try! publicKey.ethereumAddress()
    }
}

