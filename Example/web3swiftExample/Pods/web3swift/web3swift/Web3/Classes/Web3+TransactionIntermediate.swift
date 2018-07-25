//
//  Web3+TransactionIntermediate.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import enum Result.Result
import BigInt
import PromiseKit
fileprivate typealias PromiseResult = PromiseKit.Result

extension web3.web3contract {

    public class TransactionIntermediate{
        public var transaction:EthereumTransaction
        public var contract: ContractProtocol
        public var method: String
        public var options: Web3Options? = Web3Options.defaultOptions()
        var web3: web3
        public init (transaction: EthereumTransaction, web3 web3Instance: web3, contract: ContractProtocol, method: String, options: Web3Options?) {
            self.transaction = transaction
            self.web3 = web3Instance
            self.contract = contract
            self.contract.options = options
            self.method = method
            self.options = Web3Options.merge(web3.options, with: options)
            if self.web3.provider.network != nil {
                self.transaction.chainID = self.web3.provider.network?.chainID
            }
        }
        
        @available(*, deprecated)
        public func setNonce(_ nonce: BigUInt) throws {
            self.transaction.nonce = nonce
            if (self.web3.provider.network != nil) {
                self.transaction.chainID = self.web3.provider.network?.chainID
            }
        }
        
        @available(*, deprecated)
        public func send(password: String = "BANKEXFOUNDATION", options: Web3Options? = nil, onBlock: String = "pending", callback: @escaping Callback, queue: OperationQueue = OperationQueue.main) {
            guard let operation = ContractSendOperation.init(web3, queue: web3.queue, intermediate: self, options: options, onBlock: onBlock, password: password) else {
                guard let dispatchQueue =  queue.underlyingQueue else {return}
                return dispatchQueue.async {
                    callback(Result<AnyObject, Web3Error>.failure(Web3Error.dataError))
                }
            }
            operation.next = OperationChainingType.callback(callback, queue)
            self.web3.queue.addOperation(operation)
        }
        
        public func send(password: String = "BANKEXFOUNDATION", options: Web3Options? = nil, onBlock: String = "pending") -> Result<TransactionSendingResult, Web3Error> {
            do {
                let result = try self.sendPromise(password: password, options: options, onBlock: onBlock).wait()
                return Result(result)
            } catch {
                if let err = error as? Web3Error {
                    return Result.failure(err)
                }
                return Result.failure(Web3Error.generalError(error))
            }
        }
        
//        public func send(password: String = "BANKEXFOUNDATION", options: Web3Options? = nil, onBlock: String = "pending") -> Result<[String:String], Web3Error> {
//
//            var externalResult: Result<[String:String], Web3Error>!
//            let semaphore = DispatchSemaphore(value: 0)
//            let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//                switch res {
//                case .success(let result):
//                    guard let unwrappedResult = result as? String else {
//                        externalResult = Result.failure(Web3Error.dataError)
//                        break
//                    }
//                    let resultDict = ["txhash" : unwrappedResult] as [String: String]
//                    externalResult = Result<[String:String], Web3Error>(resultDict)
//                case .failure(let error):
//                    externalResult = Result.failure(error)
//                    break
//                }
//                semaphore.signal()
//            }
//            send(password: password, options: options, onBlock: onBlock, callback: callback, queue: self.web3.queue)
//            _ = semaphore.wait(timeout: .distantFuture)
//            return externalResult
//
////            do {
////                guard var mergedOptions = Web3Options.merge(self.options, with: options) else
////                {
////                    return Result.failure(Web3Error.inputError("Invalid options supplied"))
////                }
////                guard let from = mergedOptions.from else
////                {
////                    return Result.failure(Web3Error.inputError("Invalid options supplied"))
////                }
////                let nonceResult = self.web3.eth.getTransactionCount(address: from, onBlock: onBlock)
////                if case .failure(let err) = nonceResult {
////                    return Result.failure(err)
////                }
////                try self.setNonce(nonceResult.value!)
////                let estimatedGasResult = self.estimateGas(options: mergedOptions)
////                if case .failure(let err) = estimatedGasResult {
////                    return Result.failure(err)
////                }
////                if mergedOptions.gasLimit == nil {
////                    mergedOptions.gasLimit = estimatedGasResult.value!
////                } else {
////                    if (mergedOptions.gasLimit! < estimatedGasResult.value!) {
////                        if (options?.gasLimit != nil && options!.gasLimit != nil && options!.gasLimit! >=  estimatedGasResult.value!) {
////                            mergedOptions.gasLimit = estimatedGasResult.value!
////                        } else {
////                            return Result.failure(Web3Error.inputError("Estimated gas is larger than the gas limit"))
////                        }
////                    }
////                }
////                var transaction = self.transaction
////                if mergedOptions.gasLimit != nil {
////                    transaction.gasLimit = mergedOptions.gasLimit!
////                    self.transaction = transaction
////                }
////                self.options = mergedOptions
////                if let keystoreManager = self.web3.provider.attachedKeystoreManager {
////                    try Web3Signer.signTX(transaction: &self.transaction, keystore: keystoreManager, account: from, password: password)
////                    print(self.transaction)
////                    return self.web3.eth.sendRawTransaction(self.transaction)
////                } else {
////                    return self.web3.eth.sendTransaction(self.transaction, options: mergedOptions)
////                }
////            }
////            catch {
////                return Result.failure(Web3Error.generalError(error))
////            }
//        }
        
        
        public func call(options: Web3Options?, onBlock: String = "latest") -> Result<[String:Any], Web3Error> {
            do {
                let result = try self.callPromise(options: options, onBlock: onBlock).wait()
                return Result(result)
            } catch {
                if let err = error as? Web3Error {
                    return Result.failure(err)
                }
                return Result.failure(Web3Error.generalError(error))
            }
        }
        
        
//        public func call(options: Web3Options?, onBlock: String = "latest") -> Result<[String:Any], Web3Error> {
//
//            var externalResult: Result<[String:Any], Web3Error>!
//            let semaphore = DispatchSemaphore(value: 0)
//            let callback = { (res: Result<AnyObject, Web3Error>) -> () in
//                switch res {
//                case .success(let result):
//                    guard let unwrappedResult = result as? [String:Any] else {
//                        externalResult = Result.failure(Web3Error.dataError)
//                        break
//                    }
//                    externalResult = Result<[String:Any], Web3Error>(unwrappedResult)
//                case .failure(let error):
//                    externalResult = Result.failure(error)
//                    break
//                }
//                semaphore.signal()
//            }
//            call(options: options, onBlock: onBlock, callback: callback, queue: self.web3.queue)
//            _ = semaphore.wait(timeout: .distantFuture)
//            return externalResult
//
//
//
////            let mergedOptions = Web3Options.merge(self.options, with: options)
////            guard let request = EthereumTransaction.createRequest(method: JSONRPCmethod.call, transaction: self.transaction, onBlock: onBlock, options: mergedOptions) else
////            {
////                return Result.failure(Web3Error.inputError("Transaction or options are malformed"))
////            }
////            let response = self.web3.provider.send(request: request)
////            let result = ResultUnwrapper.getResponse(response)
////            switch result {
////                case .failure(let error):
////                    return Result.failure(error)
////                case .success(let payload):
////                    guard let resultString = payload as? String else {
////                        return Result.failure(Web3Error.dataError)
////                    }
////                    if (self.method == "fallback") {
////                        let resultAsBigUInt = BigUInt(resultString.stripHexPrefix(), radix : 16)
////                        return Result(["result": resultAsBigUInt as Any])
////                    }
////                    guard let responseData = Data.fromHex(resultString) else
////                    {
////                        return Result.failure(Web3Error.dataError)
////                    }
////                    guard let decodedData = contract.decodeReturnData(self.method, data: responseData) else
////                    {
////                        return Result.failure(Web3Error.dataError)
////                    }
////                    return Result(decodedData)
////            }
//        }
        
        @available(*, deprecated)
        public func call(options: Web3Options?, onBlock: String = "latest", callback: @escaping Callback, queue: OperationQueue = OperationQueue.main) {
//            let mergedOptions = Web3Options.merge(self.options, with: options)
//            self.options = mergedOptions
            guard let operation = ContractCallOperation(web3, queue: web3.queue, intermediate: self, onBlock: onBlock, options: options) else {
                guard let dispatchQueue =  queue.underlyingQueue else {return}
                return dispatchQueue.async {
                    callback(Result<AnyObject, Web3Error>.failure(Web3Error.dataError))
                }
            }
            operation.next = OperationChainingType.callback(callback, queue)
            self.web3.queue.addOperation(operation)
        }
        
        public func estimateGas(options: Web3Options?, onBlock: String = "latest") -> Result<BigUInt, Web3Error> {
            do {
                let result = try self.estimateGasPromise(options: options, onBlock: onBlock).wait()
                return Result(result)
            } catch {
                if let err = error as? Web3Error {
                    return Result.failure(err)
                }
                return Result.failure(Web3Error.generalError(error))
            }
        }
        
//        public func estimateGas(options: Web3Options?, onBlock: String = "latest") -> Result<BigUInt, Web3Error> {
//            let mergedOptions = Web3Options.merge(self.options, with: options)
//            return self.web3.eth.estimateGas(self.transaction, options: mergedOptions, onBlock: onBlock)
//        }
        
        @available(*, deprecated)
        public func estimateGas(options: Web3Options?, onBlock: String = "latest", callback: @escaping Callback, queue: OperationQueue = OperationQueue.main) {
            let mergedOptions = Web3Options.merge(self.options, with: options)
            self.options = mergedOptions
            guard let operation = ContractEstimateGasOperation.init(web3, queue: web3.queue, intermediate: self, onBlock: onBlock) else {
                guard let dispatchQueue =  queue.underlyingQueue else {return}
                return dispatchQueue.async {
                    callback(Result<AnyObject, Web3Error>.failure(Web3Error.dataError))
                }
            }
            operation.next = OperationChainingType.callback(callback, queue)
            self.web3.queue.addOperation(operation)
        }
        
        func assemble(password:String = "BANKEXFOUNDATION", options: Web3Options? = nil, onBlock: String = "pending") -> Result<EthereumTransaction, Web3Error> {
            do {
                let result = try self.assemblePromise(password:password, options: options, onBlock: onBlock).wait()
                return Result(result)
            } catch {
                if let err = error as? Web3Error {
                    return Result.failure(err)
                }
                return Result.failure(Web3Error.generalError(error))
            }
        }
   
    }
}

extension web3.web3contract.TransactionIntermediate {
    
    func assemblePromise(password:String = "BANKEXFOUNDATION", options: Web3Options? = nil, onBlock: String = "pending") -> Promise<EthereumTransaction> {
        var assembledTransaction : EthereumTransaction = self.transaction
        let queue = self.web3.requestDispatcher.queue
        let returnPromise = Promise<EthereumTransaction> { seal in
            guard let mergedOptions = Web3Options.merge(self.options, with: options) else {
                seal.reject(Web3Error.inputError("Provided options are invalid"))
                return
            }
            guard let from = mergedOptions.from else {
                seal.reject(Web3Error.inputError("No 'from' field provided"))
                return
            }
            var optionsForGasEstimation = Web3Options()
            optionsForGasEstimation.from = mergedOptions.from
            optionsForGasEstimation.to = mergedOptions.to
            optionsForGasEstimation.value = mergedOptions.value
            let getNoncePromise : Promise<BigUInt> = self.web3.eth.getTransactionCountPromise(address: from, onBlock: onBlock)
            let gasEstimatePromise : Promise<BigUInt> = self.web3.eth.estimateGasPromise(assembledTransaction, options: optionsForGasEstimation, onBlock: onBlock)
            let gasPricePromise : Promise<BigUInt> = self.web3.eth.getGasPricePromise()
            var promisesToFulfill: [Promise<BigUInt>] = [getNoncePromise, gasPricePromise, gasPricePromise]
            when(resolved: getNoncePromise, gasEstimatePromise, gasPricePromise).map(on: queue, { (results:[PromiseResult<BigUInt>]) throws -> EthereumTransaction in
                
                promisesToFulfill.removeAll()
                guard case .fulfilled(let nonce) = results[0] else {
                    throw Web3Error.processingError("Failed to fetch nonce")
                }
                guard case .fulfilled(let gasEstimate) = results[1] else {
                    throw Web3Error.processingError("Failed to fetch gas estimate")
                }
                guard case .fulfilled(let gasPrice) = results[2] else {
                    throw Web3Error.processingError("Failed to fetch gas price")
                }
                guard let estimate = Web3Options.smartMergeGasLimit(originalOptions: options, extraOptions: nil, gasEstimage: gasEstimate) else {
                    throw Web3Error.processingError("Failed to calculate gas estimate that satisfied options")
                }
                assembledTransaction.nonce = nonce
                assembledTransaction.gasLimit = estimate
                if assembledTransaction.gasPrice == 0 {
                    assembledTransaction.gasPrice = gasPrice
                }
                return assembledTransaction
            }).done(on: queue) {tx in
                    seal.fulfill(tx)
                }.catch(on: queue) {err in
                    seal.reject(err)
            }
        }
        return returnPromise
    }
    
    func sendPromise(password:String = "BANKEXFOUNDATION", options: Web3Options? = nil, onBlock: String = "pending") -> Promise<TransactionSendingResult>{
            let queue = self.web3.requestDispatcher.queue
            return self.assemblePromise(password: password, options: options, onBlock: onBlock).then(on: queue) { transaction throws -> Promise<TransactionSendingResult> in
                guard let mergedOptions = Web3Options.merge(self.options, with: options) else {
                    throw Web3Error.inputError("Provided options are invalid")
                }
                var cleanedOptions = Web3Options()
                cleanedOptions.from = mergedOptions.from
                cleanedOptions.to = mergedOptions.to
                return self.web3.eth.sendTransactionPromise(transaction, options: cleanedOptions, password: password)
            }
        }
    
//        var assembledTransaction : EthereumTransaction = self.transaction
//        let returnPromise = Promise<TransactionSendingResult> { seal in
//            guard let mergedOptions = Web3Options.merge(self.options, with: options) else {
//                seal.reject(Web3Error.inputError("Provided options are invalid"))
//                return
//            }
//            guard let from = mergedOptions.from else {
//                seal.reject(Web3Error.inputError("No 'from' field provided"))
//                return
//            }
//            var optionsForGasEstimation = Web3Options()
//            optionsForGasEstimation.from = mergedOptions.from
//            optionsForGasEstimation.to = mergedOptions.to
//            optionsForGasEstimation.value = mergedOptions.value
//            let getNoncePromise : Promise<BigUInt> = self.web3.eth.getTransactionCountPromise(address: from, onBlock: onBlock)
//            let gasEstimatePromise : Promise<BigUInt> = self.web3.eth.estimateGasPromise(assembledTransaction, options: optionsForGasEstimation, onBlock: onBlock)
//            let gasPricePromise : Promise<BigUInt> = self.web3.eth.getGasPricePromise()
//            var promisesToFulfill: [Promise<BigUInt>] = [getNoncePromise, gasPricePromise, gasPricePromise]
//            when(resolved: getNoncePromise, gasEstimatePromise, gasPricePromise).map(on: queue, { (results:[PromiseResult<BigUInt>]) throws -> EthereumTransaction in
//
//                promisesToFulfill.removeAll()
//                guard case .fulfilled(let nonce) = results[0] else {
//                    throw Web3Error.processingError("Failed to fetch nonce")
//                }
//                guard case .fulfilled(let gasEstimate) = results[1] else {
//                    throw Web3Error.processingError("Failed to fetch gas estimate")
//                }
//                guard case .fulfilled(let gasPrice) = results[2] else {
//                    throw Web3Error.processingError("Failed to fetch gas price")
//                }
//                guard let estimate = Web3Options.smartMergeGasLimit(originalOptions: options, extraOptions: nil, gasEstimage: gasEstimate) else {
//                    throw Web3Error.processingError("Failed to calculate gas estimate that satisfied options")
//                }
//                assembledTransaction.nonce = nonce
//                assembledTransaction.gasLimit = estimate
//                if assembledTransaction.gasPrice == 0 {
//                    assembledTransaction.gasPrice = gasPrice
//                }
//                return assembledTransaction
//            }).then(on: queue) { transaction -> Promise<TransactionSendingResult> in
//                var cleanedOptions = Web3Options()
//                cleanedOptions.from = mergedOptions.from
//                cleanedOptions.to = mergedOptions.to
//                return self.web3.eth.sendTransactionPromise(assembledTransaction, options: cleanedOptions)
//            }.done(on: queue) {transactionSendingResult in
//                seal.fulfill(transactionSendingResult)
//            }.catch(on: queue) {err in
//                seal.reject(err)
//            }
//        }
//        return returnPromise
//    }
    
    func callPromise(options: Web3Options? = nil, onBlock: String = "latest") -> Promise<[String: Any]>{
        let assembledTransaction : EthereumTransaction = self.transaction
        let queue = self.web3.requestDispatcher.queue
        let returnPromise = Promise<[String:Any]> { seal in
            guard let mergedOptions = Web3Options.merge(self.options, with: options) else {
                seal.reject(Web3Error.inputError("Provided options are invalid"))
                return
            }
            var optionsForCall = Web3Options()
            optionsForCall.from = mergedOptions.from
            optionsForCall.to = mergedOptions.to
            optionsForCall.value = mergedOptions.value
            let callPromise : Promise<Data> = self.web3.eth.callPromise(assembledTransaction, options: optionsForCall, onBlock: onBlock)
            callPromise.done(on: queue) {(data:Data) throws in
                    do {
                        if (self.method == "fallback") {
                            let resultHex = data.toHexString().addHexPrefix()
                            seal.fulfill(["result": resultHex as Any])
                            return
                        }
                        guard let decodedData = self.contract.decodeReturnData(self.method, data: data) else
                        {
                            throw Web3Error.processingError("Can not decode returned parameters")
                        }
                        seal.fulfill(decodedData)
                    } catch{
                        seal.reject(error)
                    }
                }.catch(on: queue) {err in
                    seal.reject(err)
            }
        }
        return returnPromise
    }
    
    func estimateGasPromise(options: Web3Options? = nil, onBlock: String = "latest") -> Promise<BigUInt>{
        let assembledTransaction : EthereumTransaction = self.transaction
        let queue = self.web3.requestDispatcher.queue
        let returnPromise = Promise<BigUInt> { seal in
            guard let mergedOptions = Web3Options.merge(self.options, with: options) else {
                seal.reject(Web3Error.inputError("Provided options are invalid"))
                return
            }
            var optionsForGasEstimation = Web3Options()
            optionsForGasEstimation.from = mergedOptions.from
            optionsForGasEstimation.to = mergedOptions.to
            optionsForGasEstimation.value = mergedOptions.value
            let promise = self.web3.eth.estimateGasPromise(assembledTransaction, options: optionsForGasEstimation, onBlock: onBlock)
            promise.done(on: queue) {(estimate: BigUInt) in
                    seal.fulfill(estimate)
                }.catch(on: queue) {err in
                    seal.reject(err)
            }
        }
        return returnPromise
    }
}
