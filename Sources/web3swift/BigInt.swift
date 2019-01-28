//
//  UInt256.swift
//  web3swift-iOS
//
//  Created by Dmitry on 11/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation
import CoreBlockchain

extension BigUInt {
    /// - Parameter string: String number. can be: "0.023", "123123123.12312312312"
    /// - Parameter units: Units that contains decimals
    public init?(_ string: String, units: Web3Units) {
        self.init(string, decimals: units.decimals)
    }
    
    /// - Parameter string: String number. can be: "0.023", "123123123.12312312312"
    /// - Parameter decimals: Number of decimals that string should be multiplyed by
    public init?(_ string: String, decimals: Int) {
        let separators = CharacterSet(charactersIn: ".,")
        let components = string.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: separators)
        guard components.count == 1 || components.count == 2 else { return nil }
        let unitDecimals = decimals
        guard var mainPart = BigUInt(components[0], radix: 10) else { return nil }
        mainPart *= BigUInt(10).power(unitDecimals)
        if components.count == 2 {
            let numDigits = components[1].count
            guard numDigits <= unitDecimals else { return nil }
            guard let afterDecPoint = BigUInt(components[1], radix: 10) else { return nil }
            let extraPart = afterDecPoint * BigUInt(10).power(unitDecimals - numDigits)
            mainPart += extraPart
        }
        self = mainPart
    }
    /// Formats a BigUInt object to String. The supplied number is first divided into integer and decimal part based on "toUnits",
    /// then limit the decimal part to "decimals" symbols and uses a "decimalSeparator" as a separator.
    /// default: decimals: 18, decimalSeparator: ".", options: .stripZeroes
    public func string(units: Web3Units, decimals: Int = 18, decimalSeparator: String = ".", options: NumberToStringOptions = .default) -> String {
        return string(unitDecimals: units.decimals, decimals: decimals, decimalSeparator: decimalSeparator, options: options)
    }
    
    /// Formats a BigUInt object to String. The supplied number is first divided into integer and decimal part based on "toUnits",
    /// then limit the decimal part to "decimals" symbols and uses a "decimalSeparator" as a separator.
    /// Fallbacks to scientific format if higher precision is required.
    /// default: decimals: 18, decimalSeparator: ".", options: .stripZeroes
    public func string(unitDecimals: Int, decimalSeparator: String = ".", options: NumberToStringOptions = .default) -> String {
        return string(unitDecimals: unitDecimals, decimals: 18, decimalSeparator: decimalSeparator, options: options)
    }
}

extension BigInt {
    /// Returns .description to not confuse
    public func string() -> String {
        return description
    }
    /// Formats a BigInt object to String. The supplied number is first divided into integer and decimal part based on "units",
    /// then limit the decimal part to "decimals" symbols and uses a "decimalSeparator" as a separator.
    /// Fallbacks to scientific format if higher precision is required.
    /// default: decimals: 18, decimalSeparator: ".", options: .stripZeroes
    public func string(unitDecimals: Int, decimalSeparator: String = ".", options: StringOptions = .default) -> String {
        return string(unitDecimals: unitDecimals, decimals: 18, decimalSeparator: decimalSeparator, options: options)
//        let formatted = magnitude.string(unitDecimals: unitDecimals, decimals: decimals, decimalSeparator: decimalSeparator, options: options)
//        switch sign {
//        case .plus:
//            return formatted
//        case .minus:
//            return "-" + formatted
//        }
    }
    
    /// Formats a BigInt object to String. The supplied number is first divided into integer and decimal part based on "units",
    /// then limit the decimal part to "decimals" symbols and uses a "decimalSeparator" as a separator.
    /// default: decimals: 18, decimalSeparator: ".", options: .stripZeroes
    public func string(units: Web3Units, decimals: Int = 18, decimalSeparator: String = ".", options: StringOptions = .default) -> String {
        return string(unitDecimals: units.decimals, decimals: decimals, decimalSeparator: decimalSeparator, options: options)
    }
}

/// Represents human readable string as wei
/// Used in requests, where it automatically converts to wei units
public struct NaturalUnits {
    /// Error for init with string
    public enum Error: Swift.Error {
        /// Cannot convert \(string) to number
        case cannotConvert(String)
        
        /// Printable / user displayable description
        public var localizedDescription: String {
            switch self {
            case let .cannotConvert(string):
                return "Cannot convert \(string) to number"
            }
        }
    }
    /// String value
    public let string: String
    /// Init with string like "0.1", "1123123123", "123123.123123123123"
    /// - Throws: Error.cannotConvert if it cannot convert to string to BigUInt with 18 decimals
    public init(_ string: String) throws {
        guard BigUInt(string, decimals: 18) != nil else { throw Error.cannotConvert(string) }
        self.string = string
    }
    /// Init with int value
    public init(_ int: Int) {
        self.string = int.description
    }
    /// - Parameter decimals: Number of decimals
    /// - Returns: Wei units with decimals
    public func number(with decimals: Int) -> BigUInt {
        return BigUInt(string, decimals: decimals) ?? 0
    }
}
