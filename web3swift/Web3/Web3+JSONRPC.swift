//
//  Web3+JSONRPC.swift
//  web3swift
//
//  Created by Alexander Vlasov on 21.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation

/// Global counter object to enumerate JSON RPC requests.
public struct Counter {
    public static var counter = UInt64(1)
    public static var lockQueue = DispatchQueue(label: "counterQueue")
    public static func increment() -> UInt64 {
        var c: UInt64 = 0
        lockQueue.sync {
            c = Counter.counter
            Counter.counter = Counter.counter + 1
        }
        return c
    }
}


/// JSON RPC request structure for serialization and deserialization purposes.
public struct JsonRpcRequest: Encodable {
    var jsonrpc: String = "2.0"
    var method: JsonRpcMethod
    var params: JsonRpcParams?
    var id: UInt64 = Counter.increment()

    enum CodingKeys: String, CodingKey {
        case jsonrpc
        case method
        case params
        case id
    }
    public init(method: JsonRpcMethod) {
        self.method = method
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        try container.encode(method.api, forKey: .method)
        try container.encode(params, forKey: .params)
        try container.encode(id, forKey: .id)
    }

    public var isValid: Bool {
        return method.parameters == params?.params.count
    }
}

/// JSON RPC batch request structure for serialization and deserialization purposes.
public struct JsonRpcRequestBatch: Encodable {
    var requests: [JsonRpcRequest]

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(requests)
    }
}

/// JSON RPC response structure for serialization and deserialization purposes.
public struct JsonRpcResponse: Decodable {
    public var id: Int
    public var jsonrpc = "2.0"
    public var result: Any?
    public var error: ErrorMessage?
    public var message: String?
    
    public func response() throws -> DictionaryReader {
        if let error = error {
            throw Web3Error.nodeError(error.message)
        } else if let result = result {
            return DictionaryReader(result)
        } else {
            throw Web3Error.nodeError("No response found")
        }
    }

    enum JSONRPCresponseKeys: String, CodingKey {
        case id
        case jsonrpc
        case result
        case error
    }

    public init(id: Int, jsonrpc: String, result: Any?, error: ErrorMessage?) {
        self.id = id
        self.jsonrpc = jsonrpc
        self.result = result
        self.error = error
    }

    public struct ErrorMessage: Decodable {
        public var code: Int
        public var message: String
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: JSONRPCresponseKeys.self)
        let id: Int = try container.decode(Int.self, forKey: .id)
        let jsonrpc: String = try container.decode(String.self, forKey: .jsonrpc)
        let errorMessage = try container.decodeIfPresent(ErrorMessage.self, forKey: .error)
        if errorMessage != nil {
            self.init(id: id, jsonrpc: jsonrpc, result: nil, error: errorMessage)
            return
        }
        var result: Any?
        
        if let rawValue = try? container.decodeIfPresent(String.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent(Int.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent(Bool.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent(EventLog.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent(Block.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent(TransactionReceipt.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent(TransactionDetails.self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([EventLog].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([Block].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([TransactionReceipt].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([TransactionDetails].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([Bool].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([Int].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String: String].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String: Int].self, forKey: .result) {
            result = rawValue
        } else if let rawValue = try? container.decodeIfPresent([String: Any].self, forKey: .result) {
            result = rawValue
        }
        self.init(id: id, jsonrpc: jsonrpc, result: result, error: nil)
    }

    /// Get the JSON RCP reponse value by deserializing it into some native <T> class.
    ///
    /// Returns nil if serialization fails
    public func getValue<T>() -> T? {
        let slf = T.self
        if slf == BigUInt.self {
            guard let string = self.result as? String else { return nil }
            guard let value = BigUInt(string.withoutHex, radix: 16) else { return nil }
            return value as? T
        } else if slf == BigInt.self {
            guard let string = self.result as? String else { return nil }
            guard let value = BigInt(string.withoutHex, radix: 16) else { return nil }
            return value as? T
        } else if slf == Data.self {
            guard let string = self.result as? String else { return nil }
            guard let value = Data.fromHex(string) else { return nil }
            return value as? T
        } else if slf == EthereumAddress.self {
            guard let string = self.result as? String else { return nil }
            let value = EthereumAddress(string)
            guard value.isValid else { return nil }
            return value as? T
        } else if slf == [BigUInt].self {
            guard let string = self.result as? [String] else { return nil }
            let values = string.compactMap { (str) -> BigUInt? in
                return BigUInt(str.withoutHex, radix: 16)
            }
            return values as? T
        } else if slf == [BigInt].self {
            guard let string = self.result as? [String] else { return nil }
            let values = string.compactMap { (str) -> BigInt? in
                return BigInt(str.withoutHex, radix: 16)
            }
            return values as? T
        } else if slf == [Data].self {
            guard let string = self.result as? [String] else { return nil }
            let values = string.compactMap { (str) -> Data? in
                return Data.fromHex(str)
            }
            return values as? T
        } else if slf == [EthereumAddress].self {
            guard let string = self.result as? [String] else { return nil }
            let values = string.compactMap { (str) -> EthereumAddress? in
                let address = EthereumAddress(str)
                guard address.isValid else { return nil }
                return address
            }
            return values as? T
        }
        guard let value = self.result as? T else { return nil }
        return value
    }
}

/// JSON RPC batch response structure for serialization and deserialization purposes.
public struct JsonRpcResponseBatch: Decodable {
    var responses: [JsonRpcResponse]

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let responses = try container.decode([JsonRpcResponse].self)
        self.responses = responses
    }
}

/// Transaction parameters JSON structure for interaction with Ethereum node.
public struct TransactionParameters: Codable {
    public var data: String?
    public var from: String?
    public var gas: String?
    public var gasPrice: String?
    public var to: String?
    public var value: String? = "0x0"

    public init(from _from: String?, to _to: String?) {
        from = _from
        to = _to
    }
}

/// Event filter parameters JSON structure for interaction with Ethereum node.
public struct EventFilterParameters: Codable {
    public var fromBlock: String?
    public var toBlock: String?
    public var topics: [[String?]?]?
    public var address: [String?]?
}

/// Raw JSON RCP 2.0 internal flattening wrapper.
public struct JsonRpcParams: Encodable {
    public var params = [Any]()

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for par in params {
            if let p = par as? TransactionParameters {
                try container.encode(p)
            } else if let p = par as? String {
                try container.encode(p)
            } else if let p = par as? Bool {
                try container.encode(p)
            } else if let p = par as? EventFilterParameters {
                try container.encode(p)
            }
        }
    }
}
