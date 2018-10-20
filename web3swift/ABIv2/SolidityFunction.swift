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
extension EthereumAddress: SolidityDataRepresentable {
    public var solidityData: Data { return addressData.setLengthLeft(32)! }
}
extension Data: SolidityDataRepresentable {
    public var solidityData: Data { return self }
}
extension String: SolidityDataRepresentable {
    public var solidityData: Data { return data }
}
extension Array where Element == SolidityDataRepresentable {
    func data(function: String) -> Data {
        return reduce(into: function.keccak256()[0..<4], { $0.append($1.solidityData) })
    }
}

extension EthereumAddress {
    public func assemble(_ function: String, _ arguments: [Any], web3: Web3 = .default, options: Web3Options? = nil, onBlock: String = "pending") -> Promise<EthereumTransaction> {
        let options = web3.options.merge(with: options)
        
        let data = arguments.compactMap { value in
            return value as? SolidityDataRepresentable
            }.data(function: function)
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
        let data = arguments.compactMap { $0 as? SolidityDataRepresentable }.data(function: function)
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
        let data = arguments.compactMap { $0 as? SolidityDataRepresentable }.data(function: function)
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

//public class UnsafeSolidityFunction {
//    public let name: String
//    public init(_ name: String) {
//        self.name = name
//    }
//    public var hash: Data {
//        return name.data.sha3(.keccak256)[0..<4]
//    }
//    public func data(with arguments: [SolidityDataRepresentable]) -> Data {
//        return arguments.reduce(into: hash, { $0.append($1.solidityData) })
//    }
//    public func data(with arguments: SolidityDataRepresentable...) -> Data {
//        return data(with: arguments)
//    }
//}

//protocol SolidityConvertable {
//    func write(type: SolidityType) throws
//}
//enum SolidityType {
//    case address
//    case 
//}

//extension String {
//    var solidityType: String {
//        switch self {
//        case "uint":
//            return "uint256"
//        case "int":
//            return "int256"
//        default:
//            return self
//        }
//    }
//}
//

//class SafeSolidityFunction: CustomStringConvertible {
//    enum Error: Swift.Error {
//        case corrupted
//        case emptyFunctionName
//    }
//    let name: String
//    let arguments: [String]
//    init(function: String) throws {
//        var function = function.trimmingCharacters(in: .whitespacesAndNewlines)
//        guard let index = function.index(of: "(") else { throw Error.corrupted }
//        name = function[..<index].trimmingCharacters(in: .whitespacesAndNewlines)
//        guard name.count > 0 else { throw Error.emptyFunctionName }
//        guard function.hasSuffix(")") else { throw Error.corrupted }
//        function.removeLast()
//        let arguments = function[function.index(after: index)...]
//        self.arguments = arguments.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
//    }
//    var description: String {
//        return "\(name)(\(arguments.joined(separator: ",")))"
//    }
//}

/*
 converts:
 "balanceOf(address)"
 "transfer(address,address,uint256)"
 "transfer(address, address, uint256)"
 "transfer(address, address, uint256)"
 "transfer (address, address, uint)"
 "  transfer  (  address  ,  address  ,  uint256  )  "
 to
 .name: String
 .arguments: [String]
 */
