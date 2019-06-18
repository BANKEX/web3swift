//
//  Web3+Methods.swift
//  web3swift
//
//  Created by Alexander Vlasov on 21.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation

/// Contains JsonRpc api methods and required number of parameters
public struct JsonRpcMethod: Encodable, Equatable {
	/// Method name
    public var api: String
	/// Required number of parameters
    public var parameters: Int
	
	/// init with api and parameters. Used for custom api methods
    public init(api: String, parameters: Int) {
        self.api = api
        self.parameters = parameters
    }
	
	/// ctxc_gasPrice method
    public static let gasPrice = JsonRpcMethod(api: "ctxc_gasPrice", parameters: 0)
	/// ctxc_blockNumber method
    public static let blockNumber = JsonRpcMethod(api: "ctxc_blockNumber", parameters: 0)
	/// net_version method
    public static let getNetwork = JsonRpcMethod(api: "net_version", parameters: 0)
	/// ctxc_sendRawTransaction method
    public static let sendRawTransaction = JsonRpcMethod(api: "ctxc_sendRawTransaction", parameters: 1)
	/// ctxc_sendTransaction method
    public static let sendTransaction = JsonRpcMethod(api: "ctxc_sendTransaction", parameters: 1)
	/// ctxc_estimateGas method
    public static let estimateGas = JsonRpcMethod(api: "ctxc_estimateGas", parameters: 1)
	/// ctxc_call method
    public static let call = JsonRpcMethod(api: "ctxc_call", parameters: 2)
	/// ctxc_getTransactionCount method
    public static let getTransactionCount = JsonRpcMethod(api: "ctxc_getTransactionCount", parameters: 2)
	/// ctxc_getBalance method
    public static let getBalance = JsonRpcMethod(api: "ctxc_getBalance", parameters: 2)
	/// ctxc_getCode method
    public static let getCode = JsonRpcMethod(api: "ctxc_getCode", parameters: 2)
	/// ctxc_getStorageAt method
    public static let getStorageAt = JsonRpcMethod(api: "ctxc_getStorageAt", parameters: 2)
	/// ctxc_getTransactionByHash method
    public static let getTransactionByHash = JsonRpcMethod(api: "ctxc_getTransactionByHash", parameters: 1)
	/// ctxc_getTransactionReceipt method
    public static let getTransactionReceipt = JsonRpcMethod(api: "ctxc_getTransactionReceipt", parameters: 1)
	/// ctxc_accounts method
    public static let getAccounts = JsonRpcMethod(api: "ctxc_accounts", parameters: 0)
	/// ctxc_getBlockByHash method
    public static let getBlockByHash = JsonRpcMethod(api: "ctxc_getBlockByHash", parameters: 2)
	/// ctxc_getBlockByNumber method
    public static let getBlockByNumber = JsonRpcMethod(api: "ctxc_getBlockByNumber", parameters: 2)
	/// ctxc_sign method
    public static let personalSign = JsonRpcMethod(api: "ctxc_sign", parameters: 1)
	/// personal_unlockAccount method
    public static let unlockAccount = JsonRpcMethod(api: "personal_unlockAccount", parameters: 1)
	/// ctxc_getLogs method
    public static let getLogs = JsonRpcMethod(api: "ctxc_getLogs", parameters: 1)
	/// txpool_status method
    public static let txPoolStatus = JsonRpcMethod(api: "txpool_status", parameters: 0)
	/// txpool_inspect method
    public static let txPoolInspect = JsonRpcMethod(api: "txpool_inspect", parameters: 0)
	/// txpool_content method
    public static let txPoolContent = JsonRpcMethod(api: "txpool_content", parameters: 0)
}
