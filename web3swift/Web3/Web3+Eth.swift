//
//  Web3+Eth.swift
//  web3swift
//
//  Created by Alexander Vlasov on 22.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation

extension Web3.Eth {
    /// Send an EthereumTransaction object to the network. Transaction is either signed locally if there is a KeystoreManager
    /// object bound to the web3 instance, or sent unsigned to the node. For local signing the password is required.
    ///
    /// "options" object can override the "to", "gasPrice", "gasLimit" and "value" parameters is pre-formed transaction.
    /// "from" field in "options" is mandatory for both local and remote signing.
    ///
    /// This function is synchronous!
    public func sendTransaction(_ transaction: EthereumTransaction, options: Web3Options, password: String = "BANKEXFOUNDATION") throws -> TransactionSendingResult {
        return try sendTransactionPromise(transaction, options: options, password: password).wait()
    }

    /// Performs a non-mutating "call" to some smart-contract. EthereumTransaction bears all function parameters required for the call.
    /// Does NOT decode the data returned from the smart-contract.
    /// "options" object can override the "to", "gasPrice", "gasLimit" and "value" parameters is pre-formed transaction.
    /// "from" field in "options" is mandatory for both local and remote signing.
    ///
    /// "onString" field determines if value is returned based on the state of a blockchain on the latest mined block ("latest")
    /// or the expected state after all the transactions in memory pool are applied ("pending").
    ///
    /// This function is synchronous!
    func call(_ transaction: EthereumTransaction, options: Web3Options, onBlock: String = "latest") throws -> Data {
        return try callPromise(transaction, options: options, onBlock: onBlock).wait()
    }

    /// Send raw Ethereum transaction data to the network.
    ///
    /// This function is synchronous!
    public func sendRawTransaction(_ transaction: Data) throws -> TransactionSendingResult {
        return try sendRawTransactionPromise(transaction).wait()
    }

    /// Send raw Ethereum transaction data to the network by first serializing the EthereumTransaction object.
    ///
    /// This function is synchronous!
    public func sendRawTransaction(_ transaction: EthereumTransaction) throws -> TransactionSendingResult {
        return try sendRawTransactionPromise(transaction).wait()
    }

    /// Returns a total number of transactions sent by the particular Ethereum address.
    ///
    /// "onBlock" field determines if value is returned based on the state of a blockchain on the latest mined block ("latest")
    /// or the expected state after all the transactions in memory pool are applied ("pending").
    ///
    /// This function is synchronous!
    public func getTransactionCount(address: EthereumAddress, onBlock: String = "latest") throws -> BigUInt {
        return try getTransactionCountPromise(address: address, onBlock: onBlock).wait()
    }

    /// Returns a balance of particular Ethereum address in Wei units (1 ETH = 10^18 Wei).
    ///
    /// "onString" field determines if value is returned based on the state of a blockchain on the latest mined block ("latest")
    /// or the expected state after all the transactions in memory pool are applied ("pending").
    ///
    /// This function is synchronous!
    public func getBalance(address: EthereumAddress, onBlock: String = "latest") throws -> BigUInt {
        return try getBalancePromise(address: address, onBlock: onBlock).wait()
    }

    /// Returns a block number of the last mined block that Ethereum node knows about.
    ///
    /// This function is synchronous!
    public func getBlockNumber() throws -> BigUInt {
        return try getBlockNumberPromise().wait()
    }

    /// Returns a current gas price in the units of Wei. The node has internal algorithms for averaging over the last few blocks.
    ///
    /// This function is synchronous!
    public func getGasPrice() throws -> BigUInt {
        return try getGasPricePromise().wait()
    }

    /// Returns transaction details for particular transaction hash. Details indicate position of the transaction in a particular block,
    /// as well as original transaction details such as value, gas limit, gas price, etc.
    ///
    /// This function is synchronous!
    public func getTransactionDetails(_ txhash: Data) throws -> TransactionDetails {
        return try getTransactionDetailsPromise(txhash).wait()
    }

    /// Returns transaction details for particular transaction hash. Details indicate position of the transaction in a particular block,
    /// as well as original transaction details such as value, gas limit, gas price, etc.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getTransactionDetails(_ txhash: String) throws -> TransactionDetails {
        return try getTransactionDetailsPromise(txhash).wait()
    }

    /// Returns transaction receipt for particular transaction hash. Receipt indicate what has happened when the transaction
    /// was included in block, so it contains logs and status, such as succesful or failed transaction.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getTransactionReceipt(_ txhash: Data) throws -> TransactionReceipt {
        return try getTransactionReceiptPromise(txhash).wait()
    }

    /// Returns transaction receipt for particular transaction hash. Receipt indicate what has happened when the transaction
    /// was included in block, so it contains logs and status, such as succesful or failed transaction.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getTransactionReceipt(_ txhash: String) throws -> TransactionReceipt {
        return try getTransactionReceiptPromise(txhash).wait()
    }

    /// Estimates a minimal amount of gas required to run a transaction. To do it the Ethereum node tries to run it and counts
    /// how much gas it consumes for computations. Setting the transaction gas limit lower than the estimate will most likely
    /// result in a failing transaction.
    ///
    /// "onString" field determines if value is returned based on the state of a blockchain on the latest mined block ("latest")
    /// or the expected state after all the transactions in memory pool are applied ("pending").
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    /// Error can also indicate that transaction is invalid in the current state, so formally it's gas limit is infinite.
    /// An example of such transaction can be sending an amount of ETH that is larger than the current account balance.
    public func estimateGas(_ transaction: EthereumTransaction, options: Web3Options?, onBlock: String = "latest") throws -> BigUInt {
        return try estimateGasPromise(transaction, options: options, onBlock: onBlock).wait()
    }

    /// Get a list of Ethereum accounts that a node knows about.
    /// If one has attached a Keystore Manager to the web3 object it returns accounts known to the keystore.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getAccounts() throws -> [EthereumAddress] {
        return try getAccountsPromise().wait()
    }

    /// Get information about the particular block in Ethereum network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded EthereumTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getBlockByHash(_ hash: String, fullTransactions: Bool = false) throws -> Block {
        return try getBlockByHashPromise(hash, fullTransactions: fullTransactions).wait()
    }

    /// Get information about the particular block in Ethereum network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded EthereumTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getBlockByHash(_ hash: Data, fullTransactions: Bool = false) throws -> Block {
        return try getBlockByHashPromise(hash, fullTransactions: fullTransactions).wait()
    }

    /// Get information about the particular block in Ethereum network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded EthereumTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getBlockByNumber(_ number: UInt64, fullTransactions: Bool = false) throws -> Block {
        return try getBlockByNumberPromise(number, fullTransactions: fullTransactions).wait()
    }

    /// Get information about the particular block in Ethereum network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded EthereumTransaction objects.
    ///
    /// This function is synchronous!
    ///
    /// Returns the Result object that indicates either success of failure.
    public func getBlockByNumber(_ number: BigUInt, fullTransactions: Bool = false) throws -> Block {
        return try getBlockByNumberPromise(number, fullTransactions: fullTransactions).wait()
    }

    /// Get information about the particular block in Ethereum network. If "fullTransactions" parameter is set to "true"
    /// this call fill do a virtual join and fetch not just transaction hashes from this block,
    /// but full decoded EthereumTransaction objects.
    ///
    /// This function is synchronous!
    ///
    ///
    public func getBlockByNumber(_ block: String, fullTransactions: Bool = false) throws -> Block {
        return try getBlockByNumberPromise(block, fullTransactions: fullTransactions).wait()
    }

    /**
     Convenience wrapper to send Ethereum to another address. Internally it creates a virtual contract and encodes all the options and data.
     - Parameters:
     - to: EthereumAddress to send funds to
     - amount: BigUInt indicating the amount in wei
     - extraData: Additional data to attach to the transaction
     - options: Web3Options to override the default gas price, gas limit. "Value" field of the options is ignored and the "amount" parameter is used instead

     - returns:
     - TransactionIntermediate object

     */
    public func sendETH(to: EthereumAddress, amount: BigUInt, extraData: Data = Data(), options: Web3Options? = nil) throws -> TransactionIntermediate {
        let contract = try web3.contract(Web3.Utils.coldWalletABI, at: to)
        var mergedOptions = self.options.merge(with: options)
        mergedOptions.value = amount
        return try contract.method("fallback", extraData: extraData, options: mergedOptions)
    }

    /**
     *Convenience wrapper to send Ethereum to another address. Internally it creates a virtual contract and encodes all the options and data.*

     - parameters:
     - to: EthereumAddress to send funds to
     - amount: String in "units" demonimation. It can contain either "," or "." decimal separator.
     - units: Ethereum units indicating the denomination of amout about
     - extraData: Additional data to attach to the transaction
     - options: Web3Options to override the default gas price, gas limit. "Value" field of the options is ignored and the "amount" parameter is used instead

     - returns:
     - TransactionIntermediate object

     * String "1.01" and units: .eth will result in sending 1.01 ETH to another address*
     */

    @available(*, unavailable, message: "Use sendETH with BigUInt(\"1.01\",units: .eth)")
    public func sendETH(to _: EthereumAddress, amount _: String, units _: Web3Units = .eth, extraData _: Data = Data(), options _: Web3Options? = nil) throws -> TransactionIntermediate { fatalError() }

    /**
     *Convenience wrapper to send Ethereum to another address. Internally it creates a virtual contract and encodes all the options and data.*

     - parameters:
     - from: EthereumAddress to send funds from
     - to: EthereumAddress to send funds to
     - amount: String in "units" demonimation. It can contain either "," or "." decimal separator.
     - units: Ethereum units indicating the denomination of amout about
     - extraData: Additional data to attach to the transaction
     - options: Web3Options to override the default gas price, gas limit. "Value" field of the options is ignored and the "amount" parameter is used instead. "From" parameter is also ignored.

     - returns:
     - TransactionIntermediate object

     * String "1.01" and units: .eth will result in sending 1.01 ETH to another address*
     */

    @available(*, unavailable, message: "Use sendETH BigUInt(\"some\",units: .eth)")
    public func sendETH(from _: EthereumAddress, to _: EthereumAddress, amount _: String, units _: Web3Units = .eth, extraData _: Data = Data(), options _: Web3Options? = nil) -> TransactionIntermediate? { fatalError() }

    /**
     *Convenience wrapper to send ERC20 tokens to another address. Internally it creates a virtual contract and encodes all the options and data. Assumes that the sender knows the decimal units of the underlying token.*

     - parameters:
     - tokenAddress: EthereumAddress of the token contract
     - from: EthereumAddress to send tokens from
     - to: EthereumAddress to send tokens to
     - amount: BigUInt indicating the number of tokens in the the smallest indivisible units (mind that sender knows the number of decimals)
     - options: Web3Options to override the default gas price, gas limit. "Value" field of the options is ignored and the "amount" parameter is used instead. "From" parameter is also ignored.

     - returns:
     - TransactionIntermediate object

     */
    @available(*, unavailable, message: "Use ERC20 class instead")
    public func sendERC20tokensWithKnownDecimals(tokenAddress _: EthereumAddress, from _: EthereumAddress, to _: EthereumAddress, amount _: BigUInt, options _: Web3Options? = nil) throws -> TransactionIntermediate {
        fatalError("")
    }

    /**
     *Convenience wrapper to send ERC20 tokens to another address. Internally it creates a virtual contract and encodes all the options and data. Pulls the number of decimals of the token under the hood.*

     - parameters:
     - tokenAddress: EthereumAddress of the token contract
     - from: EthereumAddress to send tokens from
     - to: EthereumAddress to send tokens to
     - amount: String in "natura" demonimation. It can contain either "," or "." decimal separator.
     - options: Web3Options to override the default gas price, gas limit. "Value" field of the options is ignored and the "amount" parameter is used instead. "From" parameter is also ignored.

     - returns:
     - TransactionIntermediate object

     - important: This call is synchronous

     * If the amount is  "1.01" and token has 9 decimals it will result in sending 1010000000 of the smallest invidisible token units.*
     */
    @available(*, unavailable, message: "Use ERC20 class instead")
    public func sendERC20tokensWithNaturalUnits(tokenAddress _: EthereumAddress, from _: EthereumAddress, to _: EthereumAddress, amount _: String, options _: Web3Options? = nil) throws -> TransactionIntermediate {
        fatalError("")
    }
}
