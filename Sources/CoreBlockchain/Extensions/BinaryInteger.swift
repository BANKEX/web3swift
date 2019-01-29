//
//  BinaryInteger.swift
//  web3swift
//
//  Created by Dmitry on 28/01/2019.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import Foundation

/// Number to string convertion options
public struct NumberToStringOptions: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    /// Fallback to scientific number. (like `1.0e-16`)
    public static let fallbackToScientific = NumberToStringOptions(rawValue: 0b1)
    /// Removes last zeroes (will print `1.123` instead of `1.12300000000000`)
    public static let stripZeroes = NumberToStringOptions(rawValue: 0b10)
    /// Default options: [.stripZeroes]
    public static let `default`: NumberToStringOptions = [.stripZeroes]
}

public extension FixedWidthInteger {
    /// - Parameter string: String number. can be: "0.023", "123123123.12312312312"
    /// - Parameter decimals: Number of decimals that string should be multiplyed by
    public init?(_ string: String, decimals: Int) {
        let separators = CharacterSet(charactersIn: ".,")
        let components = string.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: separators)
        guard components.count == 1 || components.count == 2 else { return nil }
        let unitDecimals = decimals
        guard var mainPart = Self.init(components[0], radix: 10) else { return nil }
        mainPart *= Self(10).power(unitDecimals)
        if components.count == 2 {
            let numDigits = components[1].count
            guard numDigits <= unitDecimals else { return nil }
            guard let afterDecPoint = Self.init(components[1], radix: 10) else { return nil }
            let extraPart = afterDecPoint * Self(10).power(unitDecimals - numDigits)
            mainPart += extraPart
        }
        self = mainPart
    }
}

// MARK:- To String with radix
public extension BinaryInteger {
    func power(_ exponent: Int) -> Self {
        if exponent == 0 { return 1 }
        if exponent == 1 { return self }
        if exponent < 0 {
            precondition(self != 0)
            return self == 1 ? 1 : 0
        }
        let signum = self.signum()
        var b = self * signum
        if b <= 1 { return self }
        var result = Self(1)
        var e = exponent
        while e > 0 {
            if e & 1 == 1 {
                result *= b
            }
            e >>= 1
            b *= b
        }
        if signum == -1 && exponent & 1 != 0 {
            return result * -1
        } else {
            return result
        }
    }
    /// Formats Number to String. The supplied number is first divided into integer and decimal part based on "toUnits",
    /// then limit the decimal part to "decimals" symbols and uses a "decimalSeparator" as a separator.
    /// Fallbacks to scientific format if higher precision is required.
    /// default: decimals: 18, decimalSeparator: ".", options: .stripZeroes
    public func string(unitDecimals: Int, decimals: Int, decimalSeparator: String = ".", options: NumberToStringOptions = .default) -> String {
        guard self != 0 else { return "0" }
        var toDecimals = decimals
        if unitDecimals < toDecimals {
            toDecimals = unitDecimals
        }
        
        let divisor = Self(10).power(unitDecimals)
        let (quotient, remainder) = (self * signum()).quotientAndRemainder(dividingBy: divisor)
        var fullRemainder = String(remainder)
        let fullPaddedRemainder = fullRemainder.leftPadding(toLength: unitDecimals, withPad: "0")
        let remainderPadded = fullPaddedRemainder[0 ..< toDecimals]
        let offset = remainderPadded.reversed().firstIndex(where: { $0 != "0" })?.base
        
        if let offset = offset {
            if toDecimals == 0 {
                return sign + String(quotient)
            } else if options.contains(.stripZeroes) {
                return sign + String(quotient) + decimalSeparator + remainderPadded[..<offset]
            } else {
                return sign + String(quotient) + decimalSeparator + remainderPadded
            }
        } else if quotient != 0 || !options.contains(.fallbackToScientific) {
            return sign + String(quotient)
        } else {
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
                    } else if numOfRemainingDecimals > decimals {
                        let end = firstDigit+1+decimals > fullPaddedRemainder.count ? fullPaddedRemainder.count : firstDigit+1+decimals
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
            return sign + fullRemainder + "e-" + String(firstDigit)
        }
    }
    
    private var sign: String {
        return signum() == -1 ? "-" : ""
    }
}
private func _charsPerWord(forRadix radix: Int) -> (chars: Int, power: UInt) {
    var power: UInt = 1
    var overflow = false
    var count = 0
    while !overflow {
        let (p, o) = power.multipliedReportingOverflow(by: UInt(radix))
        overflow = o
        if !o || p == 0 {
            count += 1
            power = p
        }
    }
    return (count, power)
}








//@inlinable
//internal func _ascii16(_ c: Unicode.Scalar) -> UTF16.CodeUnit {
//    _internalInvariant(c.value >= 0 && c.value <= 0x7F, "not ASCII")
//    return UTF16.CodeUnit(c.value)
//}
//
//@inlinable
//@inline(__always)
//internal func _asciiDigit<CodeUnit : UnsignedInteger, Result : BinaryInteger>(
//    codeUnit u_: CodeUnit, radix: Result
//    ) -> Result? {
//    let digit = _ascii16("0")..._ascii16("9")
//    let lower = _ascii16("a")..._ascii16("z")
//    let upper = _ascii16("A")..._ascii16("Z")
//    
//    let u = UInt16(truncatingIfNeeded: u_)
//    let d: UInt16
//    if _fastPath(digit ~= u) { d = u &- digit.lowerBound }
//    else if _fastPath(upper ~= u) { d = u &- upper.lowerBound &+ 10 }
//    else if _fastPath(lower ~= u) { d = u &- lower.lowerBound &+ 10 }
//    else { return nil }
//    guard _fastPath(d < radix) else { return nil }
//    return Result(truncatingIfNeeded: d)
//}
//
//@inlinable
//@inline(__always)
//internal
//func _parseUnsignedASCII<T: IteratorProtocol, R: BinaryInteger>(first: T.Element, rest: inout T, radix: R, positive: Bool) -> R?
//    where T.Element : UnsignedInteger {
//        let r0 = _asciiDigit(codeUnit: first, radix: radix)
//        guard _fastPath(r0 != nil), var result = r0 else { return nil }
//        if !positive {
//            let (result0, overflow0)
//                = (0 as R).subtractingReportingOverflow(result)
//            guard _fastPath(!overflow0) else { return nil }
//            result = result0
//        }
//        
//        while let u = rest.next() {
//            let d0 = _asciiDigit(codeUnit: u, radix: radix)
//            guard _fastPath(d0 != nil), let d = d0 else { return nil }
//            let (result1, overflow1) = result.multipliedReportingOverflow(by: radix)
//            let (result2, overflow2) = positive
//                ? result1.addingReportingOverflow(d)
//                : result1.subtractingReportingOverflow(d)
//            guard _fastPath(!overflow1 && !overflow2)
//                else { return nil }
//            result = result2
//        }
//        return result
//}
//
////
//// TODO (TODO: JIRA): This needs to be completely rewritten. It's about 20KB of
//// always-inline code, most of which are MOV instructions.
////
//@inlinable
//@inline(__always)
//internal
//func _parseASCII<C: IteratorProtocol, R: BinaryInteger>(codeUnits: inout C, radix: R) -> R?
//    where C.Element : UnsignedInteger {
//        let c0_ = codeUnits.next()
//        guard _fastPath(c0_ != nil), let c0 = c0_ else { return nil }
//        if _fastPath(c0 != _ascii16("+") && c0 != _ascii16("-")) {
//            return _parseUnsignedASCII(
//                first: c0, rest: &codeUnits, radix: radix, positive: true)
//        }
//        let c1_ = codeUnits.next()
//        guard _fastPath(c1_ != nil), let c1 = c1_ else { return nil }
//        if _fastPath(c0 == _ascii16("-")) {
//            return _parseUnsignedASCII(
//                first: c1, rest: &codeUnits, radix: radix, positive: false)
//        }
//        else {
//            return _parseUnsignedASCII(
//                first: c1, rest: &codeUnits, radix: radix, positive: true)
//        }
//}
//
//extension BinaryInteger {
//    @inline(never)
//    @usableFromInline
//    internal static func _parseASCIISlowPath<
//        CodeUnits : IteratorProtocol, Result: BinaryInteger
//        >(
//        codeUnits: inout CodeUnits, radix: Result
//        ) -> Result?
//        where CodeUnits.Element : UnsignedInteger {
//            return _parseASCII(codeUnits: &codeUnits, radix: radix)
//    }
//    public init?<S : StringProtocol>(_ text: S, radix: Int = 10) {
//        _precondition(2...36 ~= radix, "Radix not in range 2...36")
//        
//        if let str = text as? String, str._guts.isFastUTF8 {
//            guard let ret = str._guts.withFastUTF8 ({ utf8 -> Self? in
//                var iter = utf8.makeIterator()
//                return _parseASCII(codeUnits: &iter, radix: Self(radix))
//            }) else {
//                return nil
//            }
//            self = ret
//            return
//        }
//        
//        // TODO(String performance): We can provide fast paths for common radices,
//        // native UTF-8 storage, etc.
//        var iter = text.utf8.makeIterator()
//        guard let ret = Self._parseASCIISlowPath(
//            codeUnits: &iter, radix: Self(radix)
//            ) else { return nil }
//        
//        self = ret
//    }
//}
