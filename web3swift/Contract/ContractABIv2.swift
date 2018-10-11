//
//  ContractABIv2.swift
//  web3swift
//
//  Created by Alexander Vlasov on 04.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

public struct ContractV2: ContractProtocol {
    
    public var allEvents: [String] {
        return events.keys.compactMap({ (s) -> String in
            return s
        })
    }
    
    public var allMethods: [String] {
        return methods.keys.compactMap({ (s) -> String in
            return s
        })
    }
    
    public struct EventFilter {
        public var parameterName: String
        public var parameterValues: [AnyObject]
    }
    
    public var address: EthereumAddress?
    var _abi: [ABIv2.Element]
    public var methods: [String: ABIv2.Element] {
        var toReturn = [String: ABIv2.Element]()
        for m in self._abi {
            switch m {
            case .function(let function):
                guard let name = function.name else { continue }
                toReturn[name] = m
            default:
                continue
            }
        }
        return toReturn
    }
    
    public var constructor: ABIv2.Element? {
        var toReturn : ABIv2.Element? = nil
        for m in self._abi {
            if toReturn != nil {
                break
            }
            switch m {
            case .constructor(_):
                toReturn = m
                break
            default:
                continue
            }
        }
        if toReturn == nil {
            let defaultConstructor = ABIv2.Element.constructor(ABIv2.Element.Constructor.init(inputs: [], constant: false, payable: false))
            return defaultConstructor
        }
        return toReturn
    }
    
    public var events: [String: ABIv2.Element.Event] {
        var toReturn = [String: ABIv2.Element.Event]()
        for m in self._abi {
            switch m {
            case .event(let event):
                let name = event.name
                toReturn[name] = event
            default:
                continue
            }
        }
        return toReturn
    }
    
    public var options: Web3Options = .default
    
    public init(_ abiString: String, at address: EthereumAddress? = nil) throws {
        let jsonData = abiString.data(using: .utf8)
        let abi = try JSONDecoder().decode([ABIv2.Record].self, from: jsonData!)
        let abiNative = try abi.map({ (record) -> ABIv2.Element in
            return try record.parse()
        })
        _abi = abiNative
        self.address = address
    }
    
    public init(abi: [ABIv2.Element]) {
        _abi = abi
    }
    
    public init(abi: [ABIv2.Element], at: EthereumAddress) {
        _abi = abi
        address = at
    }
    
    public enum MethodError: Error {
        case noAddress
        case noGasLimit
        case noGasPrice
        case noConstructor
        case notFound
        case cannotEncodeDataWithGivenParameters
    }
    
    public func deploy(bytecode: Data, args: Any..., extraData: Data = Data(), options: Web3Options?) throws -> EthereumTransaction {
        return try deploy(bytecode: bytecode, parameters: args, extraData: extraData, options: options)
    }
    public func deploy(bytecode: Data, parameters: [Any], extraData: Data = Data(), options: Web3Options?) throws -> EthereumTransaction {
        let to: EthereumAddress = .contractDeployment
        let options = self.options.merge(with: options)
        guard let gasLimit = options.gasLimit else { throw MethodError.noGasLimit }
        guard let gasPrice = options.gasPrice else { throw MethodError.noGasPrice }
        let value = options.value ?? 0
        
        guard let constructor = self.constructor else { throw MethodError.noConstructor }
        guard let encodedData = constructor.encodeParameters(parameters as [AnyObject]) else { throw MethodError.cannotEncodeDataWithGivenParameters }
        var fullData = bytecode
        if encodedData != Data() {
            fullData.append(encodedData)
        } else if extraData != Data() {
            fullData.append(extraData)
        }
        return EthereumTransaction(gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: fullData)
    }
    
    public func method(_ name: String, args: Any..., extraData: Data = Data(), options: Web3Options?) throws -> EthereumTransaction {
        return try method(name, parameters: args, extraData: extraData, options: options)
    }
    
    public func method(_ method: String, parameters: [Any], extraData: Data = Data(), options: Web3Options?) throws -> EthereumTransaction {
        var to: EthereumAddress
        let options = self.options.merge(with: options)
        if let address = address {
            to = address
        } else if let address = options.to, address.isValid {
            to = address
        } else {
            throw MethodError.noAddress
        }
        guard let gasLimit = options.gasLimit else { throw MethodError.noGasLimit }
        guard let gasPrice = options.gasPrice else { throw MethodError.noGasPrice }
        let value = options.value ?? 0
        
        if (method == "fallback") {
            return EthereumTransaction(gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: extraData)
        } else {
            guard let abiMethod = methods[method] else { throw MethodError.notFound }
            guard let encodedData = abiMethod.encodeParameters(parameters as [AnyObject]) else { throw MethodError.cannotEncodeDataWithGivenParameters }
            return EthereumTransaction(gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: encodedData)
        }
    }
    
    public func parseEvent(_ eventLog: EventLog) -> (eventName:String?, eventData:[String:Any]?) {
        for (eName, ev) in self.events {
            if (!ev.anonymous) {
                if eventLog.topics[0] != ev.topic {
                    continue
                }
                else {
                    let parsed = ev.decodeReturnedLogs(eventLog)
                    if parsed != nil {
                        return (eName, parsed!)
                    }
                }
            } else {
                let parsed = ev.decodeReturnedLogs(eventLog)
                if parsed != nil {
                    return (eName, parsed!)
                }
            }
        }
        return (nil, nil)
    }
    
    public func testBloomForEventPrecence(eventName: String, bloom: EthereumBloomFilter) -> Bool? {
        guard let event = events[eventName] else { return nil }
        if event.anonymous {
            return true
        }
        let eventOfSuchTypeIsPresent = bloom.test(topic: event.topic)
        return eventOfSuchTypeIsPresent
    }
    
    public func decodeReturnData(_ method: String, data: Data) -> [String: Any]? {
        guard method != "fallback" else { return [:] }
        guard let function = methods[method] else { return nil }
        guard case .function(_) = function else { return nil }
        return function.decodeReturnData(data)
    }
    
    public func decodeInputData(_ method: String, data: Data) -> [String: Any]? {
        guard method != "fallback" else { return nil }
        guard let function = methods[method] else { return nil }
        switch function {
        case .function(_):
            return function.decodeInputData(data)
        case .constructor(_):
            return function.decodeInputData(data)
        default:
            return nil
        }
    }
    
    public func decodeInputData(_ data: Data) -> [String:Any]? {
        guard data.count % 32 == 4 else { return nil }
        let methodSignature = data[0..<4]
        let foundFunction = self._abi.filter { (m) -> Bool in
            switch m {
            case .function(let function):
                return function.methodEncoding == methodSignature
            default:
                return false
            }
        }
        guard foundFunction.count == 1 else {
            return nil
        }
        let function = foundFunction[0]
        return function.decodeInputData(Data(data[4 ..< data.count]))
    }
}
