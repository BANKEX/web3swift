//
//  DictionaryReader.swift
//  web3swift-iOS
//
//  Created by Dmitry on 28/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

extension BigUInt {
    private typealias Error = DictionaryReader.Error
    init(dictionary value: Any) throws {
        if let string = value as? String {
            if string.isHex {
                guard let number = BigUInt(string.withoutHex, radix: 16) else { throw Error.unconvertible(value: string, expected: "BigInt") }
                self = number
            } else {
                guard let number = BigUInt(string) else { throw Error.unconvertible(value: string, expected: "BigInt") }
                self = number
            }
        } else if let value = value as? Int {
            self = BigUInt(value)
        } else {
            throw Error.unconvertible(value: value, expected: "BigInt")
        }
    }
}

/**
 Dictionary Reader
 
 Used for easy dictionary parsing
 */
public class DictionaryReader {
    /// Errors
    public enum Error: Swift.Error {
        /// Throws if key cannot be found in a dictionary
        case notFound(key: String, dictionary: [String: Any])
        /// Throws if value cannot be converted to desired type
        case unconvertible(value: Any, expected: String)
        /// Printable / user displayable description
        public var localizedDescription: String {
            switch self {
            case let .notFound(key, dictionary):
                return "Cannot find object at key \(key): \(dictionary)"
            case let .unconvertible(value, expected):
                return "Cannot convert \(value) to \(expected)"
            }
        }
    }
    /// Raw value
    public var raw: Any
    /// Init with any value
    public init(_ data: Any) {
        self.raw = data
    }
    
    func unconvertible(to expected: String) -> Error {
        return Error.unconvertible(value: raw, expected: expected)
    }
    
    /// Tries to represent raw as dictionary and gets value at key from it
    /// - Parameter key: Dictionary key
    /// - Returns: DictionaryReader with found value
    /// - Throws: DictionaryReader.Error(if unconvertible to [String: Any] or if key not found in dictionary)
    public func at(_ key: String) throws -> DictionaryReader {
        guard let data = raw as? [String: Any] else { throw unconvertible(to: "[String: Any]") }
        guard let value = data[key] else { throw Error.notFound(key: key, dictionary: data) }
        return DictionaryReader(value)
    }
    
    /// Tries to represent raw as dictionary and calls forEach on it.
    /// Same as [String: Any]().map { key, value in ... }
    /// - Parameter block: callback for every key and value of dictionary
    /// - Throws: DictionaryReader.Error(if unconvertible to [String: Any])
    public func dictionary(body: (DictionaryReader, DictionaryReader) throws -> ()) throws {
        guard let data = raw as? [String: Any] else { throw unconvertible(to: "[String: Any]") }
        try data.forEach {
            try body(DictionaryReader($0), DictionaryReader($1))
        }
    }
    
    /// Tries to represent raw as array and calls forEach on it.
    /// Same as [Any]().forEach { value in ... }
    /// - Parameter body: Callback for every value in array
    /// - Throws: DictionaryReader.Error(if unconvertible to [Any])
    public func array(body: (DictionaryReader)throws->()) throws {
        guard let data = raw as? [Any] else { throw unconvertible(to: "[Any]") }
        try data.forEach {
            try body(DictionaryReader($0))
        }
    }

    /// Tries to represent raw as string then string as address
    /// - Returns: Address
    /// - Throws: DictionaryReader.Error.unconvertible
    public func address() throws -> Address {
        let string = try self.string()
        guard string.count >= 42 else { throw unconvertible(to: "Address") }
        guard string != "0x" && string != "0x0" else { return .contractDeployment }
        let address = Address(String(string[..<42]))
        // already checked for size. so don't need to check again for address.isValid
        // guard address.isValid else { throw Error.unconvertible }
        return address
    }
    
    /// Tries to represent raw as string
    /// - Returns: Address
    /// - Throws: DictionaryReader.Error.unconvertible
    public func string() throws -> String {
        if let value = raw as? String {
            return value
        } else if let value = raw as? Int {
            return value.description
        } else {
            throw unconvertible(to: "String")
        }
    }
    
    /// Tries to represent raw as data or as hex string then as data
    /// - Throws: DictionaryReader.Error.unconvertible
    public func data() throws -> Data {
        if let value = raw as? Data {
            return value
        } else {
            return try Data(hex: string().withoutHex)
        }
    }
    
    /// Tries to represent raw as BigUInt.
    ///
    /// Can convert:
    /// - "0x12312312"
    /// - 0x123123
    /// - "123123123"
    /// - Throws: DictionaryReader.Error.unconvertible
    public func uint256() throws -> BigUInt {
        if let value = raw as? String {
            if value.isHex {
                guard let value = BigUInt(value.withoutHex, radix: 16) else { throw unconvertible(to: "BigUInt") }
                return value
            } else {
                guard let value = BigUInt(value) else { throw unconvertible(to: "BigUInt") }
                return value
            }
        } else if let value = raw as? Int {
            return BigUInt(value)
        } else {
            throw unconvertible(to: "BigUInt")
        }
    }
    
    /// Tries to represent raw as Int.
    ///
    /// Can convert:
    /// - "0x12312312"
    /// - 0x123123
    /// - "123123123"
    /// - Throws: DictionaryReader.Error.unconvertible
    public func int() throws -> Int {
        if let value = raw as? Int {
            return value
        } else if let value = raw as? String {
            if value.isHex {
                guard let value = Int(value.withoutHex, radix: 16) else { throw unconvertible(to: "Int") }
                return value
            } else {
                guard let value = Int(value) else { throw unconvertible(to: "Int") }
                return value
            }
        } else {
            throw unconvertible(to: "Int")
        }
    }
    
    func json() throws -> Data {
        return try JSONSerialization.data(withJSONObject: raw, options: .prettyPrinted)
    }
}

extension Dictionary where Key == String, Value == Any {
    func notFound(at key: String) -> Error {
        return DictionaryReader.Error.notFound(key: key, dictionary: self)
    }
    var json: Data {
        return try! JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
    }
    var jsonDescription: String {
        return json.string
    }
    /// - Parameter key: Dictionary key
    /// - Returns: DictionaryReader with found value
    /// - Throws: DictionaryReader.Error(if key not found in dictionary)
    public func at(_ key: String) throws -> DictionaryReader {
        guard let value = self[key] else { throw notFound(at: key) }
        return DictionaryReader(value)
    }
}

