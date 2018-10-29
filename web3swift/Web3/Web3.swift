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
    convenience init(infura networkId: NetworkId) {
        let infura = InfuraProvider(networkId, accessToken: nil)!
        self.init(provider: infura)
    }
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

struct ResultUnwrapper {
    // throws Web3Error
    static func getResponse(_ response: [String: Any]?) throws -> Any {
        guard response != nil, let res = response else { throw Web3Error.connectionError }
        if let error = res["error"] {
            if let errString = error as? String {
                throw Web3Error.nodeError(errString)
            } else if let errDict = error as? [String: Any] {
                if errDict["message"] != nil, let descr = errDict["message"]! as? String {
                    throw Web3Error.nodeError(descr)
                }
            }
            throw Web3Error.unknownError
        }
        guard let result = res["result"] else { throw Web3Error.dataError }
        return result
    }
}
