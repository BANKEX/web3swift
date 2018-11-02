//
//  SolidityTypes.swift
//  web3swift
//
//  Created by Dmitry on 16/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

public enum AbiError: Error {
    /// Unsupported types: function, tuple
    case unsupportedType
}

/*
 types:
 uint8, uint16, uint32, uint64, uint128, uint256
 int8, int16, int32, int64, int128, int256
 function, address, bool, string
 bytes
 bytes1...32
 
 array: type[]
 array: type[1...]
 tuple(type1,type2,type3...)
 example: tuple(uint256,address,tuple(address,bytes32,uint256[64]))
 */

public enum ArraySize { // bytes for convenience
    case `static`(Int)
    case dynamic
    case notArray
}

public class SolidityType: Equatable, CustomStringConvertible {
    public var isStatic: Bool { return true }
    public var isArray: Bool { return false }
    public var isTuple: Bool { return false }
    public var arraySize: ArraySize { return .notArray }
    public var subtype: SolidityType? { return nil }
    public var memoryUsage: Int { return 32 }
    public var `default`: Data { return Data(count: memoryUsage) }
    public var description: String { return "" }
    public var isValid: Bool { return true }
    public var isSupported: Bool { return true }
    public static func == (lhs: SolidityType, rhs: SolidityType) -> Bool {
        return lhs.description == rhs.description
    }
    public enum Error: Swift.Error {
        case corrupted
    }
    
    public class SolidityUInt: SolidityType {
        var bits: Int
        init(bits: Int) {
            self.bits = bits
            super.init()
        }
        public override var description: String { return "uint\(bits)" }
        public override var isValid: Bool {
            switch bits {
            case 8,16,32,64,128,256: return true
            default: return false
            }
        }
    }
    public class SolidityInt: SolidityUInt {
        public override var description: String { return "int\(bits)" }
    }
    public class SolidityAddress: SolidityType {
        public override var description: String { return "address" }
    }
    
    /// Unsupported
    public class SolidityFunctionType: SolidityType {
        public override var description: String { return "function" }
        public override var isSupported: Bool { return false }
    }
    public class SolidityBool: SolidityType {
        public override var description: String { return "bool" }
    }
    public class SolidityBytes: SolidityType {
        public override var description: String { return "bytes\(count)" }
        public override var isValid: Bool { return count > 0 && count <= 32 }
        var count: Int
        init(count: Int) {
            self.count = count
            super.init()
        }
    }
    public class SolidityStaticArray: SolidityType {
        public override var description: String { return "\(type)[\(count)]" }
        public override var isStatic: Bool { return type.isStatic }
        public override var isArray: Bool { return true }
        public override var subtype: SolidityType? { return type }
        public override var arraySize: ArraySize { return .static(count) }
        public override var isValid: Bool { return type.isValid }
        public override var memoryUsage: Int {
            return 32 * count
        }
        var count: Int
        var type: SolidityType
        init(count: Int, type: SolidityType) {
            self.count = count
            self.type = type
            super.init()
        }
    }
    public class SolidityDynamicBytes: SolidityType {
        public override var description: String { return "bytes" }
        public override var memoryUsage: Int { return 0 }
        public override var isStatic: Bool { return false }
    }
    public class SolidityString: SolidityType {
        public override var description: String { return "string" }
        public override var isStatic: Bool { return false }
        public override var memoryUsage: Int { return 0 }
    }
    public class SolidityDynamicArray: SolidityType {
        public override var description: String { return "\(type)[]" }
        public override var memoryUsage: Int { return 0 }
        public override var isStatic: Bool { return type.isStatic }
        public override var isArray: Bool { return true }
        public override var subtype: SolidityType? { return type }
        public override var arraySize: ArraySize { return .dynamic }
        public override var isValid: Bool { return type.isValid }
        var type: SolidityType
        init(type: SolidityType) {
            self.type = type
            super.init()
        }
    }
    
    /// Unsupported
    public class SolidityTuple: SolidityType {
        public override var description: String { return "tuple(\(types.map { $0.description }.joined(separator: ",")))" }
        public override var isStatic: Bool { return types.allSatisfy { $0.isStatic } }
        public override var isTuple: Bool { return true }
        public override var isSupported: Bool { return false }
        public override var memoryUsage: Int {
            guard isStatic else { return 32 }
            return types.reduce(0, { $0 + $1.memoryUsage })
        }
        public override var isValid: Bool { return types.allSatisfy { $0.isValid } }
        var types: [SolidityType]
        init(types: [SolidityType]) {
            self.types = types
            super.init()
        }
    }
}

// MARK:- String to SolidityType
extension SolidityType {
    private static var knownTypes: [String: SolidityType] = [
        "function": SolidityFunctionType(),
        "address": SolidityAddress(),
        "string": SolidityString(),
        "bool": SolidityBool()
    ]
    private static func scan(tuple string: String, from index: Int) throws -> SolidityType {
        guard string.last! == ")" else { throw Error.corrupted }
        guard string[..<index] == "tuple" else { throw Error.corrupted }
        let string = string[index+1..<string.count-1]
        let array = try string.split(separator: ",").map { try scan(type: String($0)) }
        return SolidityTuple(types: array)
    }
    private static func scan(arraySize string: String, from index: Int) throws -> SolidityType {
        guard string.last! == "]" else { throw Error.corrupted }
        let prefix = string[..<index]
        guard let type = knownTypes[String(prefix)] else { throw Error.corrupted }
        // type.isValid == true
        let string = string[index+1..<string.count-1]
        if string.isEmpty {
            return SolidityDynamicArray(type: type)
        } else {
            guard let count = Int(string) else { throw Error.corrupted }
            guard count > 0 else { throw Error.corrupted }
            return SolidityStaticArray(count: count, type: type)
        }
    }
    private static func scan(bytesArray string: String, from index: Int) throws -> SolidityType {
        guard let count = Int(string[index...]) else { throw Error.corrupted }
        let type = SolidityBytes(count: count)
        guard type.isValid else { throw Error.corrupted }
        return type
    }
    private static func scan(number string: String, from index: Int) throws -> SolidityType {
        let prefix = string[..<index]
        let isSigned: Bool
        switch prefix {
        case "uint":
            isSigned = false
        case "int":
            isSigned = true
        default: throw Error.corrupted
        }
        let i = index+1
        for (index2,character) in string[i...].enumerated() {
            switch character {
            case "[":
                guard let number = Int(string[index...index+index2]) else { throw Error.corrupted }
                let type = isSigned ? SolidityInt(bits: number) : SolidityUInt(bits: number)
                guard type.isValid else { throw Error.corrupted }
                guard string.last! == "]" else { throw Error.corrupted }
                // type.isValid == true
                let string = string[index+index2+2..<string.count-1]
                if string.isEmpty {
                    return SolidityDynamicArray(type: type)
                } else {
                    guard let count = Int(string) else { throw Error.corrupted }
                    guard count > 0 else { throw Error.corrupted }
                    let array = SolidityStaticArray(count: count, type: type)
                    guard array.isValid else { throw Error.corrupted }
                    return array
                }
            case "0"..."9":
                guard index2 < 3 else { throw Error.corrupted }
                continue
            default: throw Error.corrupted
            }
        }
        guard let number = Int(string[index...]) else { throw Error.corrupted }
        let type = isSigned ? SolidityInt(bits: number) : SolidityUInt(bits: number)
        guard type.isValid else { throw Error.corrupted }
        return type
    }
    public static func scan(type string: String) throws -> SolidityType {
        for (index,character) in string.enumerated() {
            switch character {
            case "(":
                return try scan(tuple: string, from: index)
            case "[":
                return try scan(arraySize: string, from: index)
            case "0"..."9":
                let prefix = string[..<index]
                if prefix == "bytes" {
                    return try scan(bytesArray: string, from: index)
                } else {
                    return try scan(number: string, from: index)
                }
            default: continue
            }
        }
        if string == "bytes" {
            return SolidityDynamicBytes()
        } else if let type = knownTypes[String(string)] {
            return type
        } else {
            throw Error.corrupted
        }
    }
}


/// Converts:
///     "balanceOf(address)"
///     "transfer(address,address,uint256)"
///     "transfer(address, address, uint256)"
///     "transfer(address, address, uint256)"
///     "transfer (address, address, uint)"
///     "  transfer  (  address  ,  address  ,  uint256  )  "
/// To:
///     function.name: String
///     function.types: [SolidityType]
///
/// Mainthread-friendly
/// Performance:
///     transfer(uint256,address) // ~184k ops
///     transfer(uint256,address,address,bytes32,uint256[32]) // performance ~100k ops

public class SolidityFunction: CustomStringConvertible {
    public enum Error: Swift.Error {
        case corrupted
        case emptyFunctionName
    }
    public let name: String
    public let types: [SolidityType]
    public let function: String
    public lazy var hash: Data = self.function.keccak256()[0..<4]
    public init(function: String) throws {
        let function = function.replacingOccurrences(of: " ", with: "")
        self.function = function
        guard let index = function.index(of: "(") else { throw Error.corrupted }
        name = String(function[..<index])
        guard name.count > 0 else { throw Error.emptyFunctionName }
        guard function.hasSuffix(")") else { throw Error.corrupted }
        let arguments = function[function.index(after: index)..<function.index(before: function.endIndex)]
        self.types = try arguments.split(separator: ",").map { try SolidityType.scan(type: String($0)) }
    }
    public func encode(_ arguments: SolidityDataRepresentable...) -> Data {
        return encode(arguments)
    }
    public func encode(_ arguments: [SolidityDataRepresentable]) -> Data {
        let data = SolidityDataWriter()
        data.write(header: hash)
        for i in 0..<types.count {
            let type = types[i]
            if i < arguments.count {
                data.write(value: arguments[i], type: type)
            } else {
                data.write(type: type)
            }
        }
        return data.done()
    }
    public var description: String {
        return "\(name)(\(types.map{ $0.description }.joined(separator: ",")))"
    }
}
