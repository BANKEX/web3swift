//
//  UInt256.swift
//  web3swift-iOS
//
//  Created by Dmitry on 11/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation

extension BigUInt {
    public init?(_ string: String, units: Web3Units) {
        self.init(string, decimals: units.decimals)
    }

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
    ///
    /// Returns nil of formatting is not possible to satisfy.
    public func string(units: Web3Units = .eth, decimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String {
        return string(numberDecimals: units.decimals, formattingDecimals: decimals, decimalSeparator: decimalSeparator, fallbackToScientific: fallbackToScientific)
    }
    
    /// Formats a BigUInt object to String. The supplied number is first divided into integer and decimal part based on "toUnits",
    /// then limit the decimal part to "decimals" symbols and uses a "decimalSeparator" as a separator.
    /// Fallbacks to scientific format if higher precision is required.
    ///
    /// Returns nil of formatting is not possible to satisfy.
    public func string(numberDecimals: Int = 18, formattingDecimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String {
        guard self != 0 else { return "0" }
        let unitDecimals = numberDecimals
        var toDecimals = formattingDecimals
        if unitDecimals < toDecimals {
            toDecimals = unitDecimals
        }
        let divisor = BigUInt(10).power(unitDecimals)
        let (quotient, remainder) = quotientAndRemainder(dividingBy: divisor)
        var fullRemainder = String(remainder)
        let fullPaddedRemainder = fullRemainder.leftPadding(toLength: unitDecimals, withPad: "0")
        let remainderPadded = fullPaddedRemainder[0 ..< toDecimals]
        if remainderPadded == String(repeating: "0", count: toDecimals) {
            if quotient != 0 {
                return String(quotient)
            } else if fallbackToScientific {
                var firstDigit = 0
                for char in fullPaddedRemainder {
                    if char == "0" {
                        firstDigit = firstDigit + 1
                    } else {
                        let firstDecimalUnit = String(fullPaddedRemainder[firstDigit ..< firstDigit+1])
                        var remainingDigits = ""
                        let numOfRemainingDecimals = fullPaddedRemainder.count - firstDigit - 1
                        if numOfRemainingDecimals <= 0 {
                            remainingDigits = ""
                        } else if numOfRemainingDecimals > formattingDecimals {
                            let end = firstDigit+1+formattingDecimals > fullPaddedRemainder.count ? fullPaddedRemainder.count : firstDigit+1+formattingDecimals
                            remainingDigits = String(fullPaddedRemainder[firstDigit+1 ..< end])
                        } else {
                            remainingDigits = String(fullPaddedRemainder[firstDigit+1 ..< fullPaddedRemainder.count])
                        }
                        fullRemainder = firstDecimalUnit
                        if !remainingDigits.isEmpty {
                            fullRemainder += decimalSeparator + remainingDigits
                        }
                        firstDigit = firstDigit + 1
                        break
                    }
                }
                return fullRemainder + "e-" + String(firstDigit)
            }
        }
        if toDecimals == 0 {
            return String(quotient)
        } else {
            return String(quotient) + decimalSeparator + remainderPadded
        }
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
    public func string(numberDecimals: Int, formattingDecimals: Int = 4, decimalSeparator: String = ".", fallbackToScientific: Bool = false) -> String {
        
        let formatted = magnitude.string(numberDecimals: numberDecimals, formattingDecimals: formattingDecimals, decimalSeparator: decimalSeparator, fallbackToScientific: fallbackToScientific)
        switch sign {
        case .plus:
            return formatted
        case .minus:
            return "-" + formatted
        }
    }
    
    /// Formats a BigInt object to String. The supplied number is first divided into integer and decimal part based on "units",
    /// then limit the decimal part to "decimals" symbols and uses a "decimalSeparator" as a separator.
    public func string(units: Web3Units, decimals: Int = 4, decimalSeparator: String = ".") -> String {
        
        let formatted = magnitude.string(numberDecimals: units.decimals, formattingDecimals: decimals, decimalSeparator: decimalSeparator)
        switch sign {
        case .plus:
            return formatted
        case .minus:
            return "-" + formatted
        }
    }
}

public struct NaturalUnits {
    public enum Error: Swift.Error {
        case cannotConvert(String)
        public var localizedDescription: String {
            switch self {
            case let .cannotConvert(string):
                return "Cannot convert \(string) to number"
            }
        }
    }
    public let string: String = ""
    public init(_ string: String) throws {
        guard BigUInt("0.1", decimals: 18) != nil else { throw Error.cannotConvert(string) }
        
    }
    public func number(with decimals: Int) -> BigUInt {
        return BigUInt(string, decimals: decimals) ?? 0
    }
}
