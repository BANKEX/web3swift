//
//  SolidityFunction.swift
//  web3swift
//
//  Created by Dmitry on 12/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

public protocol SolidityDataRepresentable {
    var solidityData: Data { get }
    var isSolidityBinaryType: Bool { get }
}
public extension SolidityDataRepresentable {
    var isSolidityBinaryType: Bool { return false }
}

extension BinaryInteger {
    public var solidityData: Data { return BigInt(self).abiEncode(bits: 256) }
    
}
extension Int: SolidityDataRepresentable {}
extension Int8: SolidityDataRepresentable {}
extension Int16: SolidityDataRepresentable {}
extension Int32: SolidityDataRepresentable {}
extension Int64: SolidityDataRepresentable {}
extension BigInt: SolidityDataRepresentable {}
extension UInt: SolidityDataRepresentable {}
extension UInt8: SolidityDataRepresentable {}
extension UInt16: SolidityDataRepresentable {}
extension UInt32: SolidityDataRepresentable {}
extension UInt64: SolidityDataRepresentable {}
extension BigUInt: SolidityDataRepresentable {}
extension Address: SolidityDataRepresentable {
    public var solidityData: Data { return addressData.setLengthLeft(32)! }
}
extension Data: SolidityDataRepresentable {
    public var solidityData: Data { return self }
    public var isSolidityBinaryType: Bool { return true }
}
extension String: SolidityDataRepresentable {
    public var solidityData: Data { return data }
    public var isSolidityBinaryType: Bool { return true }
}
extension Array: SolidityDataRepresentable where Element == SolidityDataRepresentable {
    public var solidityData: Data {
        var data = Data(capacity: 32 * count)
        for element in self {
            data.append(element.solidityData)
        }
        return data
    }
    
//    func dynamicSolidityData() -> Data {
//        var data = Data(capacity: 32 * (count+1))
//        data.append(count.solidityData)
//        for element in self {
//            data.append(element.solidityData)
//        }
//        return data
//    }
//    func staticSolidityData(count: Int) -> Data {
//        let capacity = 32 * count
//        var data = Data(capacity: capacity)
//        for element in self {
//            data.append(element.solidityData)
//        }
//        if data.count < capacity {
//            data.append(Data(count: capacity - data.count))
//        }
//        return data
//    }
    func data(function: String) -> Data {
        var data = Data(capacity: count * 32 + 4)
        data.append(function.keccak256()[0..<4])
        for element in self {
            data.append(element.solidityData)
        }
        return data
    }
}

extension Address {
    public func assemble(_ function: String, _ arguments: [Any], web3: Web3 = .default, options: Web3Options? = nil, onBlock: String = "pending") -> Promise<EthereumTransaction> {
        let options = web3.options.merge(with: options)
        
        let function = try! SolidityFunction(function: function)
        let data = function.encode(arguments as! [SolidityDataRepresentable])
        var assembledTransaction = EthereumTransaction(to: self, data: data, options: options)
        let queue = web3.requestDispatcher.queue
        let returnPromise = Promise<EthereumTransaction> { seal in
            guard let from = options.from else {
                seal.reject(Web3Error.inputError("No 'from' field provided"))
                return
            }
            var optionsForGasEstimation = Web3Options()
            optionsForGasEstimation.from = options.from
            optionsForGasEstimation.to = options.to
            optionsForGasEstimation.value = options.value
            let getNoncePromise = web3.eth.getTransactionCountPromise(address: from, onBlock: onBlock)
            let gasEstimatePromise = web3.eth.estimateGasPromise(assembledTransaction, options: optionsForGasEstimation, onBlock: onBlock)
            let gasPricePromise = web3.eth.getGasPricePromise()
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
                let estimate = Web3Options.smartMergeGasLimit(originalOptions: options, extraOptions: options, gasEstimate: gasEstimate)
                assembledTransaction.nonce = nonce
                assembledTransaction.gasLimit = estimate
                let finalGasPrice = Web3Options.smartMergeGasPrice(originalOptions: options, extraOptions: options, priceEstimate: gasPrice)
                assembledTransaction.gasPrice = finalGasPrice
                return assembledTransaction
            }).done(on: queue, seal.fulfill).catch(on: queue, seal.reject)
        }
        return returnPromise
    }
    
    public func send(_ function: String, _ arguments: Any..., password: String = "BANKEXFOUNDATION", web3: Web3 = .default, options: Web3Options? = nil, onBlock: String = "pending") -> Promise<TransactionSendingResult> {
        return send(function, arguments, password: password, web3: web3, options: options, onBlock: onBlock)
    }
    public func send(_ function: String, _ arguments: [Any], password: String = "BANKEXFOUNDATION", web3: Web3 = .default, options: Web3Options? = nil, onBlock: String = "pending") -> Promise<TransactionSendingResult> {
        let options = web3.options.merge(with: options)
        let queue = web3.requestDispatcher.queue
        return assemble(function, arguments, web3: web3, options: options, onBlock: onBlock).then(on: queue) { transaction throws -> Promise<TransactionSendingResult> in
            var cleanedOptions = Web3Options()
            cleanedOptions.from = options.from
            cleanedOptions.to = options.to
            return web3.eth.sendTransactionPromise(transaction, options: cleanedOptions, password: password)
        }
    }
    public func call(_ function: String, _ arguments: Any..., web3: Web3 = .default, options: Web3Options? = nil, onBlock: String = "latest") -> Promise<Web3DataResponse> {
        return call(function, arguments, web3: web3, options: options, onBlock: onBlock)
    }
    public func call(_ function: String, _ arguments: [Any], web3: Web3 = .default, options: Web3Options? = nil, onBlock: String = "latest") -> Promise<Web3DataResponse> {
        let options = web3.options.merge(with: options)
        let function = try! SolidityFunction(function: function)
        let data = function.encode(arguments as! [SolidityDataRepresentable])
        let assembledTransaction = EthereumTransaction(to: self, data: data, options: options)
        let queue = web3.requestDispatcher.queue
        return Promise<Web3DataResponse> { seal in
            var optionsForCall = Web3Options()
            optionsForCall.from = options.from
            optionsForCall.to = options.to
            optionsForCall.value = options.value
            web3.eth.callPromise(assembledTransaction, options: optionsForCall, onBlock: onBlock)
                .done(on: queue) { seal.fulfill(Web3DataResponse($0)) }
                .catch(on: queue, seal.reject)
        }
    }
    
    public func estimateGas(_ function: String, _ arguments: Any..., web3: Web3 = .default, options: Web3Options? = nil, onBlock: String = "latest") -> Promise<BigUInt> {
        return estimateGas(function, arguments, web3: web3, options: options, onBlock: onBlock)
    }
    public func estimateGas(_ function: String, _ arguments: [Any], web3: Web3 = .default, options: Web3Options? = nil, onBlock: String = "latest") -> Promise<BigUInt> {
        let options = web3.options.merge(with: options)
        let function = try! SolidityFunction(function: function)
        let data = function.encode(arguments as! [SolidityDataRepresentable])
        let assembledTransaction = EthereumTransaction(to: self, data: data, options: options)
        let queue = web3.requestDispatcher.queue
        return Promise<BigUInt> { seal in
            var optionsForGasEstimation = Web3Options()
            optionsForGasEstimation.from = options.from
            optionsForGasEstimation.to = options.to
            optionsForGasEstimation.value = options.value
            web3.eth.estimateGasPromise(assembledTransaction, options: optionsForGasEstimation, onBlock: onBlock)
                .done(on: queue, seal.fulfill)
                .catch(on: queue, seal.reject)
        }
    }
}
