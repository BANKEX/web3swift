//
//  PlainKeystore.swift
//  web3swift
//
//  Created by Alexander Vlasov on 06.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

public class PlainKeystore: AbstractKeystore {
    private var privateKey: Data

    public var addresses: [Address]

    public var isHDKeystore: Bool = false

    public func UNSAFE_getPrivateKeyData(password _: String = "", account _: Address) throws -> Data {
        return privateKey
    }

    public convenience init(privateKey: String) throws {
        try self.init(privateKey: privateKey.dataFromHex())
    }

    public init(privateKey: Data) throws {
        try SECP256K1.verifyPrivateKey(privateKey: privateKey)

        let publicKey = try Web3Utils.privateToPublic(privateKey, compressed: false)
        let address = try Web3Utils.publicToAddress(publicKey)
        addresses = [address]
        self.privateKey = privateKey
    }
}
