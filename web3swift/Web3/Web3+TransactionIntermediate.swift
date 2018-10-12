//
//  Web3+TransactionIntermediate.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation
import PromiseKit

public enum Web3ResponseError: Error {
    case notFound
    case wrongType
}

public class Web3Response {
    let dictionary: [String: Any]
    public var position = 0
    init(_ dictionary: [String: Any]) {
        self.dictionary = dictionary
    }

    public subscript(key: String) -> Any? {
        return dictionary[key]
    }

    public subscript(index: Int) -> Any? {
        return dictionary["\(index)"]
    }

    /// Returns next response argument as BigUInt (like self[n] as? BigUInt; n += 1)
    /// throws Web3ResponseError.notFound if there is no value at self[n]
    /// throws Web3ResponseError.wrongType if it cannot cast self[n] to BigUInt
    public func uint256() throws -> BigUInt {
        guard let value = dictionary[nextIndex] else { throw Web3ResponseError.notFound }
        if let value = value as? BigUInt {
            return value
        } else if let value = value as? String {
            guard let value = BigUInt(value.withoutHex, radix: 16) else { throw Web3ResponseError.wrongType }
            return value
        } else {
            throw Web3ResponseError.wrongType
        }
    }

    /// Returns next response argument as EthereumAddress (like self[n] as? EthereumAddress; n += 1)
    /// throws Web3ResponseError.notFound if there is no value at self[n]
    /// throws Web3ResponseError.wrongType if it cannot cast self[n] to EthereumAddress
    public func address() throws -> EthereumAddress {
        guard let value = dictionary[nextIndex] else { throw Web3ResponseError.notFound }
        guard let address = value as? EthereumAddress else { throw Web3ResponseError.wrongType }
        return address
    }

    /// Returns next response argument as String (like self[n] as? String; n += 1)
    /// throws Web3ResponseError.notFound if there is no value at self[n]
    /// throws Web3ResponseError.wrongType if it cannot cast self[n] to String
    public func string() throws -> String {
        guard let value = dictionary[nextIndex] else { throw Web3ResponseError.notFound }
        guard let string = value as? String else { throw Web3ResponseError.wrongType }
        return string
    }

    public func next() throws -> Any {
        guard let value = dictionary[nextIndex] else { throw Web3ResponseError.notFound }
        return value
    }

    private var nextIndex: String {
        let p = position
        position += 1
        return String(p)
    }
}

extension web3.Web3Contract {
    /// TransactionIntermediate is an almost-ready transaction or a smart-contract function call. It bears all the required information
    /// to call the smart-contract and decode the returned information, or estimate gas required for transaction, or send a transaciton
    /// to the blockchain.
    public class TransactionIntermediate {
        public var transaction: EthereumTransaction
        public var contract: ContractProtocol
        public var method: String
        public var options: Web3Options = .default
        var web3: web3
        public init(transaction: EthereumTransaction, web3 web3Instance: web3, contract: ContractProtocol, method: String, options: Web3Options) {
            self.transaction = transaction
            web3 = web3Instance
            self.contract = contract
            self.contract.options = options
            self.method = method
            self.options = web3.options.merge(with: options)
            if web3.provider.network != nil {
                self.transaction.chainID = web3.provider.network
            }
        }

        /**
         *Send a prepared transaction to the blockchain. Internally checks the nonce for a sending account, assigns it, get a gas estimate and signs a transaction either locally or on the remote node.*

         - parameters:
         - password: Password for a private key if transaction is signed locally
         - options: Web3Options to override the previously assigned gas price, gas limit and value.
         - onBlock: String field determines if nonce value and the gas estimate are based on the state of a blockchain on the latest mined block ("latest") or the expected state after all the transactions in memory pool are applied ("pending"). Using "pending" allows to send transactions one after another without waiting for inclusion of the previous one in some block.

         - returns:
         - Result object

         - important: This call is synchronous

         */
        @discardableResult
        public func send(password: String = "BANKEXFOUNDATION", options: Web3Options? = nil, onBlock: String = "pending") throws -> TransactionSendingResult {
            return try sendPromise(password: password, options: options, onBlock: onBlock).wait()
        }

        /**
         *Calls a function of the smart-contract and parses the returned data to native objects.*

         - parameters:
         - options: Web3Options to override the previously assigned gas price, gas limit and value.
         - onBlock: String field determines if nonce value and the gas estimate are based on the state of a blockchain on the latest mined block ("latest") or the expected state after all the transactions in memory pool are applied ("pending"). Using "pending" allows to send transactions one after another without waiting for inclusion of the previous one in some block.

         - returns:
         - Result object

         - important: This call is synchronous

         */

        @discardableResult
        public func call(options: Web3Options?, onBlock: String = "latest") throws -> Web3Response {
            return try callPromise(options: options, onBlock: onBlock).wait()
        }

        /**
         *Estimates gas required to execute the transaction. Setting a gas limit lower than the estimate will most likely result in a failed transaction. If this call returns an error it can also indicate that transaction is invalid as itself.*

         - parameters:
         - options: Web3Options to override the previously assigned gas price, gas limit and value.
         - onBlock: String field determines if nonce value and the gas estimate are based on the state of a blockchain on the latest mined block ("latest") or the expected state after all the transactions in memory pool are applied ("pending"). Using "pending" allows to send transactions one after another without waiting for inclusion of the previous one in some block.

         - returns:
         - Result object

         - important: This call is synchronous

         */
        public func estimateGas(options: Web3Options?, onBlock: String = "latest") throws -> BigUInt {
            return try estimateGasPromise(options: options, onBlock: onBlock).wait()
        }

        /**
         *Assembles (but does not sign!) a transaction by fetching the nonce value and applying provided options.*

         - parameters:
         - options: Web3Options to override the previously assigned gas price, gas limit and value.
         - onBlock: String field determines if nonce value and the gas estimate are based on the state of a blockchain on the latest mined block ("latest") or the expected state after all the transactions in memory pool are applied ("pending"). Using "pending" allows to send transactions one after another without waiting for inclusion of the previous one in some block.

         - returns:
         - Result object

         - important: This call is synchronous

         */
        public func assemble(options: Web3Options? = nil, onBlock: String = "pending") throws -> EthereumTransaction {
            return try assemblePromise(options: options, onBlock: onBlock).wait()
        }
    }
}

extension web3.Web3Contract.TransactionIntermediate {
    public func assemblePromise(options: Web3Options? = nil, onBlock: String = "pending") -> Promise<EthereumTransaction> {
        var assembledTransaction: EthereumTransaction = transaction
        let queue = web3.requestDispatcher.queue
        let returnPromise = Promise<EthereumTransaction> { seal in
            let mergedOptions = self.options.merge(with: options)
            guard let from = mergedOptions.from else {
                seal.reject(Web3Error.inputError("No 'from' field provided"))
                return
            }
            var optionsForGasEstimation = Web3Options()
            optionsForGasEstimation.from = mergedOptions.from
            optionsForGasEstimation.to = mergedOptions.to
            optionsForGasEstimation.value = mergedOptions.value
            let getNoncePromise: Promise<BigUInt> = self.web3.eth.getTransactionCountPromise(address: from, onBlock: onBlock)
            let gasEstimatePromise: Promise<BigUInt> = self.web3.eth.estimateGasPromise(assembledTransaction, options: optionsForGasEstimation, onBlock: onBlock)
            let gasPricePromise: Promise<BigUInt> = self.web3.eth.getGasPricePromise()
            var promisesToFulfill: [Promise<BigUInt>] = [getNoncePromise, gasPricePromise, gasPricePromise]
            when(resolved: getNoncePromise, gasEstimatePromise, gasPricePromise).map(on: queue, { (results: [Result<BigUInt>]) throws -> EthereumTransaction in

                promisesToFulfill.removeAll()
                guard case let .fulfilled(nonce) = results[0] else {
                    throw Web3Error.processingError("Failed to fetch nonce")
                }
                guard case let .fulfilled(gasEstimate) = results[1] else {
                    throw Web3Error.processingError("Failed to fetch gas estimate")
                }
                guard case let .fulfilled(gasPrice) = results[2] else {
                    throw Web3Error.processingError("Failed to fetch gas price")
                }
                let estimate = Web3Options.smartMergeGasLimit(originalOptions: options, extraOptions: mergedOptions, gasEstimate: gasEstimate)
                assembledTransaction.nonce = nonce
                assembledTransaction.gasLimit = estimate
                let finalGasPrice = Web3Options.smartMergeGasPrice(originalOptions: options, extraOptions: mergedOptions, priceEstimate: gasPrice)
                assembledTransaction.gasPrice = finalGasPrice
//                if assembledTransaction.gasPrice == 0 {
//                    if mergedOptions.gasPrice != nil {
//                        assembledTransaction.gasPrice = mergedOptions.gasPrice!
//                    } else {
//                        assembledTransaction.gasPrice = gasPrice
//                    }
//                }
                return assembledTransaction
            }).done(on: queue) { tx in
                seal.fulfill(tx)
            }.catch(on: queue) { err in
                seal.reject(err)
            }
        }
        return returnPromise
    }

    public func sendPromise(password: String = "BANKEXFOUNDATION", options: Web3Options? = nil, onBlock: String = "pending") -> Promise<TransactionSendingResult> {
        let queue = web3.requestDispatcher.queue
        return assemblePromise(options: options, onBlock: onBlock).then(on: queue) { transaction throws -> Promise<TransactionSendingResult> in
            let mergedOptions = self.options.merge(with: options)
            var cleanedOptions = Web3Options()
            cleanedOptions.from = mergedOptions.from
            cleanedOptions.to = mergedOptions.to
            return self.web3.eth.sendTransactionPromise(transaction, options: cleanedOptions, password: password)
        }
    }

    public func callPromise(options: Web3Options? = nil, onBlock: String = "latest") -> Promise<Web3Response> {
        let assembledTransaction: EthereumTransaction = transaction
        let queue = web3.requestDispatcher.queue
        let returnPromise = Promise<Web3Response> { seal in
            let mergedOptions = self.options.merge(with: options)
            var optionsForCall = Web3Options()
            optionsForCall.from = mergedOptions.from
            optionsForCall.to = mergedOptions.to
            optionsForCall.value = mergedOptions.value
            let callPromise: Promise<Data> = self.web3.eth.callPromise(assembledTransaction, options: optionsForCall, onBlock: onBlock)
            callPromise.done(on: queue) { data in
                do {
                    if self.method == "fallback" {
                        let resultHex = data.toHexString().withHex
                        let response = Web3Response(["result": resultHex as Any])
                        seal.fulfill(response)
                    } else {
                        guard let decodedData = self.contract.decodeReturnData(self.method, data: data) else {
                            throw Web3Error.processingError("Can not decode returned parameters")
                        }
                        seal.fulfill(Web3Response(decodedData))
                    }
                } catch {
                    seal.reject(error)
                }
            }.catch(on: queue) { err in
                seal.reject(err)
            }
        }
        return returnPromise
    }

    public func estimateGasPromise(options: Web3Options? = nil, onBlock: String = "latest") -> Promise<BigUInt> {
        let assembledTransaction: EthereumTransaction = transaction
        let queue = web3.requestDispatcher.queue
        let returnPromise = Promise<BigUInt> { seal in
            let mergedOptions = self.options.merge(with: options)
            var optionsForGasEstimation = Web3Options()
            optionsForGasEstimation.from = mergedOptions.from
            optionsForGasEstimation.to = mergedOptions.to
            optionsForGasEstimation.value = mergedOptions.value
            let promise = self.web3.eth.estimateGasPromise(assembledTransaction, options: optionsForGasEstimation, onBlock: onBlock)
            promise.done(on: queue) { (estimate: BigUInt) in
                seal.fulfill(estimate)
            }.catch(on: queue) { err in
                seal.reject(err)
            }
        }
        return returnPromise
    }
}
