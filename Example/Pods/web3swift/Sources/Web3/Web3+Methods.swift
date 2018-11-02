//
//  Web3+Methods.swift
//  web3swift
//
//  Created by Alexander Vlasov on 21.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation

public struct JsonRpcMethod: Encodable, Equatable {
    public var api: String
    public var parameters: Int
    public init(api: String, parameters: Int) {
        self.api = api
        self.parameters = parameters
    }
    public static let gasPrice = JsonRpcMethod(api: "eth_gasPrice", parameters: 0)
    public static let blockNumber = JsonRpcMethod(api: "eth_blockNumber", parameters: 0)
    public static let getNetwork = JsonRpcMethod(api: "net_version", parameters: 0)
    public static let sendRawTransaction = JsonRpcMethod(api: "eth_sendRawTransaction", parameters: 1)
    public static let sendTransaction = JsonRpcMethod(api: "eth_sendTransaction", parameters: 1)
    public static let estimateGas = JsonRpcMethod(api: "eth_estimateGas", parameters: 1)
    public static let call = JsonRpcMethod(api: "eth_call", parameters: 2)
    public static let getTransactionCount = JsonRpcMethod(api: "eth_getTransactionCount", parameters: 2)
    public static let getBalance = JsonRpcMethod(api: "eth_getBalance", parameters: 2)
    public static let getCode = JsonRpcMethod(api: "eth_getCode", parameters: 2)
    public static let getStorageAt = JsonRpcMethod(api: "eth_getStorageAt", parameters: 2)
    public static let getTransactionByHash = JsonRpcMethod(api: "eth_getTransactionByHash", parameters: 1)
    public static let getTransactionReceipt = JsonRpcMethod(api: "eth_getTransactionReceipt", parameters: 1)
    public static let getAccounts = JsonRpcMethod(api: "eth_accounts", parameters: 0)
    public static let getBlockByHash = JsonRpcMethod(api: "eth_getBlockByHash", parameters: 2)
    public static let getBlockByNumber = JsonRpcMethod(api: "eth_getBlockByNumber", parameters: 2)
    public static let personalSign = JsonRpcMethod(api: "eth_sign", parameters: 1)
    public static let unlockAccount = JsonRpcMethod(api: "personal_unlockAccount", parameters: 1)
    public static let getLogs = JsonRpcMethod(api: "eth_getLogs", parameters: 1)
    public static let txPoolStatus = JsonRpcMethod(api: "txpool_status", parameters: 0)
    public static let txPoolInspect = JsonRpcMethod(api: "txpool_inspect", parameters: 0)
    public static let txPoolContent = JsonRpcMethod(api: "txpool_content", parameters: 0)
}

public struct JsonRpcRequestFabric {
    public static func prepareRequest(_ method: JsonRpcMethod, parameters: [Encodable]) -> JsonRpcRequest {
        var request = JsonRpcRequest(method: method)
        let pars = JsonRpcParams(params: parameters)
        request.params = pars
        return request
    }
}
