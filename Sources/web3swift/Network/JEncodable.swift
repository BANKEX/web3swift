//
//  JEncodable.swift
//  Tests
//
//  Created by Dmitry on 18/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit
import BigInt

protocol JEncodable {
    func jsonRpcValue(with network: NetworkProvider) -> Any
}

extension Int: JEncodable {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return self
    }
}
extension BigUInt: JEncodable {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return "0x" + String(self, radix: 16, uppercase: false)
    }
}
extension Address: JEncodable {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return address
    }
}
extension Bool: JEncodable {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return self
    }
}
extension String: JEncodable {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return self
    }
}
extension BlockNumber: JEncodable {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return promise(network: network).jsonRpcValue(with: network)
    }
}
extension Data: JEncodable {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return hex.withHex
    }
}
extension Promise: JEncodable where T: JEncodable {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return map { $0 as Any }
    }
}
extension Dictionary: JEncodable where Value: JEncodable {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return mapValues { $0.jsonRpcValue(with: network) }
    }
}
class JDictionary: JEncodable {
    var dictionary = [String: JEncodable]()
    
    init() {}
    func at(_ key: String) -> JsonRpcDictionaryKey {
        return JsonRpcDictionaryKey(parent: self, key: key)
    }
    func set(_ key: String, _ value: JEncodable?) -> Self {
        return self
    }
    func set(_ key: String, _ value: JEncodable) -> Self {
        dictionary[key] = value
        return self
    }
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return dictionary.mapValues { $0.jsonRpcValue(with: network) }
    }
}
class JArray: JEncodable {
    var array = [JEncodable]()
    
    init() {}
    init(_ array: [JEncodable]) {
        guard !array.isEmpty else { return }
        self.array = array
    }
    func nilIfEmpty() -> Self? {
        return array.isEmpty ? nil : self
    }
    func append(_ element: JEncodable) -> Self {
        array.append(element)
        return self
    }
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return array.map { $0.jsonRpcValue(with: network) }
    }
}
struct JsonRpcDictionaryKey {
    var parent: JDictionary
    var key: String
    func set(_ value: JEncodable) {
        parent.dictionary[key] = value
    }
    // do nothing
    func set(_ value: JEncodable?) {}
    func dictionary(_ build: (JDictionary)->()) {
        let dictionary = JDictionary()
        build(dictionary)
        set(dictionary)
    }
}
