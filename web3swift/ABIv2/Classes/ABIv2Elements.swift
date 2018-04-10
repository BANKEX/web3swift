//
//  ABIElements.swift
//  web3swift
//
//  Created by Alexander Vlasov on 06.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

extension ABIv2 {
    // JSON Decoding
    public struct Input: Decodable {
        var name: String?
        var type: String
        var indexed: Bool?
        var components: [Input]?
    }
    
    public struct Output: Decodable {
        var name: String?
        var type: String
        var components: [Output]?
    }

    public struct Record: Decodable {
        var name: String?
        var type: String?
        var payable: Bool?
        var constant: Bool?
        var stateMutability: String?
        var inputs: [ABIv2.Input]?
        var outputs: [ABIv2.Output]?
        var anonymous: Bool?
    }
    
    public enum Element {
        public enum ArraySize { //bytes for convenience
            case staticSize(UInt64)
            case dynamicSize
            case notArray
        }
        
        case function(Function)
        case constructor(Constructor)
        case fallback(Fallback)
        case event(Event)
        
        public struct InOut {
            let name: String
            let type: ParameterType
        }
        
        public struct Function {
            let name: String?
            let inputs: [InOut]
            let outputs: [InOut]
            let constant: Bool
            let payable: Bool
        }
        
        public struct Constructor {
            let inputs: [InOut]
            let constant: Bool
            let payable: Bool
        }
        
        public struct Fallback {
            let constant: Bool
            let payable: Bool
        }
        
        public struct Event {
            let name: String
            let inputs: [Input]
            let anonymous: Bool
            
            struct Input {
                let name: String
                let type: ParameterType
                let indexed: Bool
            }
        }
    }
}

extension ABIv2.Element {
    func encodeParameters(_ parameters: [AnyObject]) -> Data? {
        switch self {
        case .constructor(_):
            return nil
        case .event(_):
            return nil
        case .fallback(_):
            return nil
        case .function(let function):
            guard parameters.count == function.inputs.count else {return nil}
            let signature = function.methodEncoding
            guard let data = ABIv2Encoder.encode(types: function.inputs, values: parameters) else {return nil}
            return signature + data
        }
    }
}

extension ABIv2.Element {
    func decodeReturnData(_ data: Data) -> [String:Any]? {
        switch self {
        case .constructor(_):
            return nil
        case .event(_):
            return nil
        case .fallback(_):
            return nil
        case .function(let function):
            if (data.count == 0 && function.outputs.count == 1) {
                let name = "0"
                let value = function.outputs[0].type.emptyValue
                var returnArray = [String:Any]()
                returnArray[name] = value
                if function.outputs[0].name != "" {
                    returnArray[function.outputs[0].name] = value
                }
                return returnArray
            }
            
            guard function.outputs.count*32 <= data.count else {return nil}
            var returnArray = [String:Any]()
            var i = 0;
            guard let values = ABIv2Decoder.decode(types: function.outputs, data: data) else {return nil}
            for output in function.outputs{
                let name = "\(i)"
                returnArray[name] = values[i]
                if output.name != "" {
                    returnArray[output.name] = values[i]
                }
                i = i + 1
            }
            return returnArray
        }
    }
}

extension ABIv2.Element.Event {
    func decodeReturnedLogs(_ eventLog: EventLog) -> [String:Any]? {
        guard let eventContent = ABIv2Decoder.decodeLog(event: self, eventLog: eventLog) else {return nil}
        return eventContent
    }
}


