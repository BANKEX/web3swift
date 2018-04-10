//
//  ContractABIv2.swift
//  web3swift
//
//  Created by Alexander Vlasov on 04.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

public struct ContractV2:ContractProtocol {
    
    public var allEvents: [String] {
        return events.keys.flatMap({ (s) -> String in
            return s
        })
    }
    public var allMethods: [String] {
        return methods.keys.flatMap({ (s) -> String in
            return s
        })
    }
    
    public struct EventFilter {
        public var parameterName: String
        public var parameterValues: [AnyObject]
    }
    
    public var address: EthereumAddress? = nil
    var _abi: [ABIv2.Element]
    public var methods: [String: ABIv2.Element] {
        var toReturn = [String: ABIv2.Element]()
        for m in self._abi {
            switch m {
            case .function(let function):
                guard let name = function.name else {continue}
                toReturn[name] = m
            default:
                continue
            }
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
    
    public var options: Web3Options? = Web3Options.defaultOptions()
    
    public init?(_ abiString: String, at: EthereumAddress? = nil) {
        do {
            let jsonData = abiString.data(using: .utf8)
            let abi = try JSONDecoder().decode([ABIv2.Record].self, from: jsonData!)
            let abiNative = try abi.map({ (record) -> ABIv2.Element in
                return try record.parse()
            })
            _abi = abiNative
            if at != nil {
                self.address = at
            }
        }
        catch{
            print(error)
            return nil
        }
    }
    
    public init(abi: [ABIv2.Element]) {
        _abi = abi
    }
    
    public init(abi: [ABIv2.Element], at: EthereumAddress) {
        _abi = abi
        address = at
    }
    
    
    public func method(_ method:String = "fallback", parameters: [AnyObject] = [AnyObject](), extraData: Data = Data(), options: Web3Options?) -> EthereumTransaction? {
        var to:EthereumAddress
        let mergedOptions = Web3Options.merge(self.options, with: options)
        if (self.address != nil) {
            to = self.address!
        } else if let toFound = mergedOptions?.to, toFound.isValid {
            to = toFound
        } else  {
            return nil
        }
        
        var gasLimit:BigUInt
        if let gasInOptions = mergedOptions?.gasLimit {
            gasLimit = gasInOptions
        } else {
            return nil
        }
        
        var gasPrice:BigUInt
        if let gasPriceInOptions = mergedOptions?.gasPrice {
            gasPrice = gasPriceInOptions
        } else {
            return nil
        }
        
        var value:BigUInt
        if let valueInOptions = mergedOptions?.value {
            value = valueInOptions
        } else {
            value = BigUInt(0)
        }
        
        if (method == "fallback") {
            let transaction = EthereumTransaction(gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: extraData)
            return transaction
        }
        let foundMethod = self.methods.filter { (key, value) -> Bool in
            return key == method
        }
        guard foundMethod.count == 1 else {return nil}
        let abiMethod = foundMethod[method]
        guard let encodedData = abiMethod?.encodeParameters(parameters) else {return nil}
        let transaction = EthereumTransaction(gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: encodedData)
        return transaction
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
        guard let event = events[eventName] else {return nil}
        if event.anonymous {
            return true
        }
        let eventOfSuchTypeIsPresent = bloom.test(topic: event.topic)
        return eventOfSuchTypeIsPresent
    }
    
    public func decodeReturnData(_ method:String, data: Data) -> [String:Any]? {
        if method == "fallback" {
            return [String:Any]()
        }
        guard let function = methods[method] else {return nil}
        guard case .function(_) = function else {return nil}
        return function.decodeReturnData(data)
    }
}
