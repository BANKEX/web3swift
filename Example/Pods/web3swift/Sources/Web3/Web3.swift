//
//  Web3.swift
//  web3swift
//
//  Created by Alexander Vlasov on 11.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation

public enum Web3Error: Error {
    case transactionSerializationError
    case connectionError
    case dataError
    case walletError
    case inputError(String)
    case nodeError(String)
    case processingError(String)
    case keystoreError(AbstractKeystoreError)
    case generalError(Error)
    case unknownError
}

/// An arbitary Web3 object. Is used only to construct provider bound fully functional object by either supplying provider URL
/// or using pre-coded Infura nodes
public extension Web3 {
    /// returns web3 to work with local node at 127.0.0.1
    /// - parameter port: node port, default: 8545
    public static func local(port: Int = 8545) throws -> Web3 {
        guard let web3 = Web3(url: URL(string: "http://127.0.0.1:\(port)")!) else { throw Web3Error.connectionError }
        return web3
    }
    /// returns web3 infura provider
    /// - parameter networkId: blockchain network id. like .mainnet / .ropsten
    convenience init(infura networkId: NetworkId) {
        let infura = InfuraProvider(networkId, accessToken: nil)!
        self.init(provider: infura)
    }
    /// returns web3 infura provider
    /// - parameter networkId: blockchain network id. like .mainnet / .ropsten
    /// - parameter accessToken: your infura access token
    convenience init(infura networkId: NetworkId, accessToken: String) {
        let infura = InfuraProvider(networkId, accessToken: accessToken)!
        self.init(provider: infura)
    }
    /// Initialized provider-bound Web3 instance using a provider's URL. Under the hood it performs a synchronous call to get
    /// the Network ID for EIP155 purposes
    convenience init?(url: URL) {
        guard let provider = Web3HttpProvider(url) else { return nil }
        self.init(provider: provider)
    }
}

