//
//  JsonRpcInput.swift
//  Tests
//
//  Created by Dmitry on 18/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit
import BigInt

protocol JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any
}

extension Int: JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return self
    }
}
extension BigUInt: JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return "0x" + String(self, radix: 16, uppercase: false)
    }
}
extension Address: JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return address
    }
}
extension Bool: JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return self
    }
}
extension String: JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return self
    }
}
extension BlockNumber: JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return promise(network: network).jsonRpcValue(with: network)
    }
}
extension Data: JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return hex.withHex
    }
}
extension Promise: JsonRpcInput where T: JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return map { $0 as Any }
    }
}
extension Dictionary: JsonRpcInput where Value: JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return mapValues { $0.jsonRpcValue(with: network) }
    }
}
class JsonRpcDictionary: JsonRpcInput {
    var dictionary = [String: JsonRpcInput]()
    
    init() {}
    func at(_ key: String) -> JsonRpcDictionaryKey {
        return JsonRpcDictionaryKey(parent: self, key: key)
    }
    func set(_ key: String, _ value: JsonRpcInput?) -> Self {
        return self
    }
    func set(_ key: String, _ value: JsonRpcInput) -> Self {
        dictionary[key] = value
        return self
    }
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return dictionary.mapValues { $0.jsonRpcValue(with: network) }
    }
}
struct JsonRpcDictionaryKey {
    var parent: JsonRpcDictionary
    var key: String
    func set(_ value: JsonRpcInput) {
        parent.dictionary[key] = value
    }
    // do nothing
    func set(_ value: JsonRpcInput?) {}
    func dictionary(_ build: (JsonRpcDictionary)->()) {
        let dictionary = JsonRpcDictionary()
        build(dictionary)
        set(dictionary)
    }
}
