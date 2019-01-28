//
//  UInt256.swift
//  AppleBigInt
//
//  Created by Dmitry on 06/12/2018.
//

import Foundation

public struct UInt256: ExpressibleByIntegerLiteral {
    public var raw: (UInt64,UInt64,UInt64,UInt64)
    
    public init() {
        raw = (0,0,0,0)
    }
    public init(_ a: UInt64, _ b: UInt64, _ c: UInt64, _ d: UInt64) {
        raw = (a,b,c,d)
    }
    public init(repeating word: UInt64) {
        raw = (word,word,word,word)
    }
    public init(integerLiteral value: UInt64) {
        raw = (value,0,0,0)
    }
    public init<T>(clamping source: T) where T : BinaryInteger {
        if source.signum() == -1 {
            self.init()
        } else if source.bitWidth > 256 {
            self.init(repeating: .max)
        } else {
            self.init(source)
        }
    }
    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        if source.trailingZeroBitCount == 0 {
            raw = (.max,.max,.max,.max)
            write(source)
        } else {
            raw = (0,0,0,0)
            write(source)
        }
    }
    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        self.init(source)
    }
    
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        raw = (UInt64(source),0,0,0)
    }
    
    public init(_ data: Data) {
        raw = (0,0,0,0)
        let count = Swift.min(data.count,32)
        let input = •••data
        let output = ••••self
        for i in 0..<count {
            output[31-i] = input[i];
        }
    }
    public var data: Data {
        return data(stripZeroes: false)
    }
    public func data(stripZeroes: Bool) -> Data {
        if stripZeroes {
            let size = bitWidth / 8
            var data = Data(count: size)
            data.withUnsafeMutableBytes { (a: UnsafeMutablePointer<UInt8>) in
                withUnsafeBytes(of: self) { p in
                    for i in 0..<size {
                        a[size-i] = p[i];
                    }
                }
            }
            return data
        } else {
            var data = Data(count: 32)
            
            data.withUnsafeMutableBytes { (a: UnsafeMutablePointer<UInt8>) in
                withUnsafeBytes(of: self) { p in
                    for i in 0..<32 {
                        a[31-i] = p[i];
                    }
                }
            }
            return data
        }
    }
    
    public typealias IntegerLiteralType = UInt64
    
    public var isZero: Bool {
        return raw.0 == 0 && raw.1 == 0 && raw.2 == 0 && raw.3 == 0
    }
    public mutating func zero() {
        raw = (0,0,0,0)
    }
    public typealias Word = UInt64
    
    
}

// MARK:- UnsignedInteger
extension UInt256: UnsignedInteger {
    public static func ^= (lhs: inout UInt256, rhs: UInt256) {
        lhs.raw.0 ^= rhs.raw.0
        lhs.raw.1 ^= rhs.raw.1
        lhs.raw.2 ^= rhs.raw.2
        lhs.raw.3 ^= rhs.raw.3
    }
    
    public static func |= (lhs: inout UInt256, rhs: UInt256) {
        lhs.raw.0 |= rhs.raw.0
        lhs.raw.1 |= rhs.raw.1
        lhs.raw.2 |= rhs.raw.2
        lhs.raw.3 |= rhs.raw.3
    }
    public static func &= (lhs: inout UInt256, rhs: UInt256) {
        lhs.raw.0 &= rhs.raw.0
        lhs.raw.1 &= rhs.raw.1
        lhs.raw.2 &= rhs.raw.2
        lhs.raw.3 &= rhs.raw.3
    }
    
    public var words: [UInt] {
        let count = 32 / MemoryLayout<UInt>.size
        var array = Array(repeating: UInt(0), count: count)
        let src = withUnsafeBytes(of: self) { $0.baseAddress! }
        memcpy(&array, src, 32)
        return array
    }
    
    public typealias Words = [UInt]
}

// MARK:- BinaryInteger
extension UInt256: BinaryInteger {
    
}

// MARK:- Numeric
extension UInt256: Numeric {
    public init?<T>(exactly source: T) where T : BinaryInteger {
        self.init(source)
    }
    
    public init<T>(_ source: T) where T : BinaryInteger {
        raw = (0,0,0,0)
        write(source)
    }
    
    public mutating func write<T: BinaryInteger>(_ source: T) {
        let dst = UnsafeMutableRawPointer(&raw)
        let src = UnsafeRawPointer(Array(source.words))
        
        let bitWidth = source.bitWidth
        if bitWidth > 256 {
            memcpy(dst, src, 32)
        } else {
            memcpy(dst, src, bitWidth/8)
        }
    }
    
    
    public static func *=(lhs: inout UInt256, rhs: UInt256) {
        // If either `lhs` or `rhs` is zero, the result is zero.
        guard !lhs.isZero && !rhs.isZero else {
            lhs.zero()
            return
        }
        
        var newData: (UInt64,UInt64,UInt64,UInt64) = (0,0,0,0)
        
        let a = lhs.raw
        let b = rhs.raw
        
        var carry: Word = 0
        
        carry = 0
        
        var product = a.0.multipliedFullWidth(by: b.0)
        (carry, newData.0) = Word.addingFullWidth(
            newData.0, product.low, carry)
        carry = product.high &+ carry
        
        product = a.0.multipliedFullWidth(by: b.1)
        (carry, newData.1) = Word.addingFullWidth(
            newData.1, product.low, carry)
        carry = product.high &+ carry
        
        product = a.0.multipliedFullWidth(by: b.2)
        (carry, newData.2) = Word.addingFullWidth(
            newData.2, product.low, carry)
        carry = product.high &+ carry
        
        product = a.0.multipliedFullWidth(by: b.3)
        (carry, newData.3) = Word.addingFullWidth(
            newData.3, product.low, carry)
        carry = product.high &+ carry
        
        
        // 1
        
        carry = 0
        
        product = a.1.multipliedFullWidth(by: b.0)
        (carry, newData.1) = Word.addingFullWidth(
            newData.1, product.low, carry)
        carry = product.high &+ carry
        
        product = a.1.multipliedFullWidth(by: b.1)
        (carry, newData.2) = Word.addingFullWidth(
            newData.2, product.low, carry)
        carry = product.high &+ carry
        
        product = a.1.multipliedFullWidth(by: b.2)
        (carry, newData.3) = Word.addingFullWidth(
            newData.3, product.low, carry)
        
        //
        
        carry = 0
        
        product = a.2.multipliedFullWidth(by: b.0)
        (carry, newData.2) = Word.addingFullWidth(
            newData.2, product.low, carry)
        carry = product.high &+ carry
        
        product = a.2.multipliedFullWidth(by: b.1)
        (carry, newData.3) = Word.addingFullWidth(
            newData.3, product.low, carry)
        
        //
        
        
        carry = 0
        
        product = a.3.multipliedFullWidth(by: b.0)
        (carry, newData.3) = Word.addingFullWidth(
            newData.3, product.low, carry)
        
        //
        
        lhs.raw = newData
    }
    
    @discardableResult
    public mutating func _internalDivide(by rhs: UInt256) -> UInt256 {
        precondition(!rhs.isZero, "Divided by zero")
        
        // Handle quick cases that don't require division:
        // If `abs(self) < abs(rhs)`, the result is zero, remainder = self
        // If `abs(self) == abs(rhs)`, the result is 1 or -1, remainder = 0
        switch _compareMagnitude(to: rhs) {
        case .lessThan:
            defer { self = 0 }
            return self
        case .equal:
            self = 1
            return 0
        default:
            break
        }
        
        var tempSelf = self
        let n = tempSelf.bitWidth - rhs.bitWidth
        var quotient: UInt256 = 0
        var tempRHS = rhs << n
        var tempQuotient: UInt256 = 1 << n
        
        for _ in 0...n {
            if tempRHS._compareMagnitude(to: tempSelf) != .greaterThan {
                tempSelf -= tempRHS
                quotient += tempQuotient
            }
            tempRHS >>= 1
            tempQuotient >>= 1
        }
        
        self = quotient
        return tempSelf
    }
    
    public mutating func _unsignedAdd(_ rhs: UInt256) {
        // Add the words up to the common count, carrying any overflows
        var carry: Word = 0
        (carry, raw.0) = Word.addingFullWidth(raw.0, rhs.raw.0, carry)
        (carry, raw.1) = Word.addingFullWidth(raw.1, rhs.raw.1, carry)
        (carry, raw.2) = Word.addingFullWidth(raw.2, rhs.raw.2, carry)
        (carry, raw.3) = Word.addingFullWidth(raw.3, rhs.raw.3, carry)
    }
    
    public mutating func _unsignedSubtract(_ rhs: UInt256) {
        var carry: Word = 0
        (carry, raw.0) = raw.0.subtractingWithBorrow(rhs.raw.0, carry)
        (carry, raw.1) = raw.1.subtractingWithBorrow(rhs.raw.1, carry)
        (carry, raw.2) = raw.2.subtractingWithBorrow(rhs.raw.2, carry)
        (carry, raw.3) = raw.3.subtractingWithBorrow(rhs.raw.3, carry)
        assert(carry == 0)
    }
    
    /// leadingZeroBitCount
    public var bitWidth: Int {
        if raw.3 != 0 { return 256 - raw.3.leadingZeroBitCount }
        if raw.2 != 0 { return 192 - raw.2.leadingZeroBitCount }
        if raw.1 != 0 { return 128 - raw.1.leadingZeroBitCount }
        return 64 - raw.0.leadingZeroBitCount
    }
    
    /// The number of sequential zeros in the least-significant position of this
    /// value's binary representation.
    ///
    /// The numbers 1 and zero have zero trailing zeros.
    public var trailingZeroBitCount: Int {
        if raw.0 != 0 { return raw.0.trailingZeroBitCount }
        if raw.1 != 0 { return 64 + raw.1.trailingZeroBitCount }
        if raw.2 != 0 { return 128 + raw.2.trailingZeroBitCount }
        if raw.3 != 0 { return 192 + raw.3.trailingZeroBitCount }
        return 256
    }
    
    public static func +=(lhs: inout UInt256, rhs: UInt256) {
        lhs._unsignedAdd(rhs)
    }
    
    public static func &+ (lhs: UInt256, rhs: UInt256) -> UInt256 {
        var lhs = lhs
        lhs.add(rhs)
        return lhs
    }
    
    public mutating func add(_ b: UInt256) {
        var carry = false
        
        var (d, c) = self.raw.0.addingReportingOverflow(b.raw.0)
        if carry {
            let (d2, c2) = d.addingReportingOverflow(1)
            self.raw.0 = d2
            carry = c || c2
        } else {
            self.raw.0 = d
            carry = c
        }
        
        (d, c) = self.raw.1.addingReportingOverflow(b.raw.1)
        if carry {
            let (d2, c2) = d.addingReportingOverflow(1)
            self.raw.1 = d2
            carry = c || c2
        } else {
            self.raw.1 = d
            carry = c
        }
        
        (d, c) = self.raw.2.addingReportingOverflow(b.raw.2)
        if carry {
            let (d2, c2) = d.addingReportingOverflow(1)
            self.raw.2 = d2
            carry = c || c2
        } else {
            self.raw.2 = d
            carry = c
        }
        
        (d, c) = self.raw.3.addingReportingOverflow(b.raw.3)
        if carry {
            let (d2, c2) = d.addingReportingOverflow(1)
            self.raw.3 = d2
            carry = c || c2
        } else {
            self.raw.3 = d
            carry = c
        }
    }
    
    public static func -=(lhs: inout UInt256, rhs: UInt256) {
        
        // Comare `lhs` and `rhs` so we can use `_unsignedSubtract` to subtract
        // the smaller magnitude from the larger magnitude.
        switch lhs._compareMagnitude(to: rhs) {
        case .equal:
            lhs = 0
        case .greaterThan:
            lhs._unsignedSubtract(rhs)
        case .lessThan:
            // x - y == -y + x == -(y - x)
            var result = rhs
            result._unsignedSubtract(lhs)
            result = ~result
//            result.isNegative = !lhs.isNegative
            lhs = result
        }
    }
    
    public static func /=(lhs: inout UInt256, rhs: UInt256) {
        lhs._internalDivide(by: rhs)
    }
    
    public static func %=(lhs: inout UInt256, rhs: UInt256) {
        lhs = lhs._internalDivide(by: rhs)
    }
    
    public static prefix func ~(lhs: UInt256) -> UInt256 {
        var a = lhs
        a.raw.0 = ~a.raw.0
        a.raw.1 = ~a.raw.1
        a.raw.2 = ~a.raw.2
        a.raw.3 = ~a.raw.3
        return a
    }
    
    public static func +(_ lhs: UInt256, _ rhs: UInt256) -> UInt256 {
        var lhs = lhs
        lhs += rhs
        return lhs
    }
    
    public static func -(_ lhs: UInt256, _ rhs: UInt256) -> UInt256 {
        var lhs = lhs
        lhs -= rhs
        return lhs
    }
    
    public static func *(_ lhs: UInt256, _ rhs: UInt256) -> UInt256 {
        var lhs = lhs
        lhs *= rhs
        return lhs
    }
    //    var __mask = Array(repeating: Word.max, count: 256 / MemoryLayout<Word>.size)
    
    public static func /(_ lhs: UInt256, _ rhs: UInt256) -> UInt256 {
        var lhs = lhs
        lhs /= rhs
        return lhs
    }
    
    public static func %(_ lhs: UInt256, _ rhs: UInt256) -> UInt256 {
        var lhs = lhs
        lhs %= rhs
        return lhs
    }
}

extension UInt256 {
    mutating func _shiftLeft(byWords: Int) {
        switch byWords {
        case 0: return
        case 1:
            raw.3 = raw.2
            raw.2 = raw.1
            raw.1 = raw.0
            raw.0 = 0
        case 2:
            raw.3 = raw.1
            raw.2 = raw.0
            raw.1 = 0
            raw.0 = 0
        case 3:
            raw.3 = raw.0
            raw.2 = 0
            raw.1 = 0
            raw.0 = 0
        default:
            zero()
        }
    }
    
    mutating func _shiftRight(byWords: Int) {
        switch byWords {
        case 0: return
        case 1:
            raw.0 = raw.1
            raw.1 = raw.2
            raw.2 = raw.3
            raw.3 = 0
        case 2:
            raw.0 = raw.2
            raw.1 = raw.3
            raw.2 = 0
            raw.3 = 0
        case 3:
            raw.0 = raw.3
            raw.1 = 0
            raw.2 = 0
            raw.3 = 0
        default:
            zero()
        }
    }
    
    public static func <<= <RHS : BinaryInteger>(lhs: inout UInt256, rhs: RHS) {
        guard rhs != 0 else { return }
        guard rhs > 0 else {
            lhs >>= 0 - rhs
            return
        }

        let wordWidth = RHS(Word.bitWidth)

        // We can add `rhs / bits` extra words full of zero at the low end.
        let extraWords = Int(rhs / wordWidth)

        // Each existing word will need to be shifted left by `rhs % bits`.
        // For each pair of words, we'll use the high `offset` bits of the
        // lower word and the low `Word.bitWidth - offset` bits of the higher
        // word.
        let highOffset = Int(rhs % wordWidth)
        let lowOffset = Word.bitWidth - highOffset


        lhs._shiftLeft(byWords: extraWords)
        // If there's no offset, we're finished, as `rhs` was a multiple of
        // `Word.bitWidth`.
        guard highOffset != 0 else { return }

        lhs.raw.3 = lhs.raw.3 << highOffset | lhs.raw.2 >> lowOffset
        lhs.raw.2 = lhs.raw.2 << highOffset | lhs.raw.1 >> lowOffset
        lhs.raw.1 = lhs.raw.1 << highOffset | lhs.raw.0 >> lowOffset
        lhs.raw.0 = lhs.raw.0 << highOffset
    }
    
    public static func >>= <RHS : BinaryInteger>(lhs: inout UInt256, rhs: RHS) {
        guard rhs != 0 else { return }
        guard rhs > 0 else {
            lhs <<= 0 - rhs
            return
        }

        let wordWidth = RHS(Word.bitWidth)
        // We can remove `rhs / bits` full words at the low end.
        // If that removes the entirety of `_data`, we're done.
        let wordsToRemove = Int(rhs / wordWidth)
        lhs._shiftRight(byWords: wordsToRemove)

        // Each existing word will need to be shifted right by `rhs % bits`.
        // For each pair of words, we'll use the low `offset` bits of the
        // higher word and the high `UInt256.Word.bitWidth - offset` bits of
        // the lower word.
        let lowOffset = Int(rhs % wordWidth)
        let highOffset = Word.bitWidth - lowOffset

        // If there's no offset, we're finished, as `rhs` was a multiple of
        // `Word.bitWidth`.
        guard lowOffset != 0 else { return }
        
        // Shift everything right by `offset` bits.
        lhs.raw.0 = lhs.raw.0 >> lowOffset | lhs.raw.1 << highOffset
        lhs.raw.1 = lhs.raw.1 >> lowOffset | lhs.raw.2 << highOffset
        lhs.raw.2 = lhs.raw.2 >> lowOffset | lhs.raw.3 << highOffset
        lhs.raw.3 >>= lowOffset
    }
}

// MARK:- Comparable
extension UInt256: Comparable {
    /// Returns whether the magnitude of this instance is less than, greather
    /// than, or equal to the magnitude of the given value.
    func _compareMagnitude(to rhs: UInt256) -> _ComparisonResult {
        // Equal number of words: compare from most significant word
        if raw.3 < rhs.raw.3 { return .lessThan }
        if raw.3 > rhs.raw.3 { return .greaterThan }
        if raw.2 < rhs.raw.2 { return .lessThan }
        if raw.2 > rhs.raw.2 { return .greaterThan }
        if raw.1 < rhs.raw.1 { return .lessThan }
        if raw.1 > rhs.raw.1 { return .greaterThan }
        if raw.0 < rhs.raw.0 { return .lessThan }
        if raw.0 > rhs.raw.0 { return .greaterThan }
        return .equal
    }
    enum _ComparisonResult {
        case lessThan, equal, greaterThan
    }
    public static func ==(lhs: UInt256, rhs: UInt256) -> Bool {
        return lhs._compareMagnitude(to: rhs) == .equal
    }
    
    public static func < (lhs: UInt256, rhs: UInt256) -> Bool {
        return lhs._compareMagnitude(to: rhs) == .lessThan
    }
}

// MARK:- Hashable
extension UInt256: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(raw.0)
        hasher.combine(raw.1)
        hasher.combine(raw.2)
        hasher.combine(raw.3)
    }
}


private extension FixedWidthInteger {
    /// Returns the high and low parts of a potentially overflowing addition.
    func addingFullWidth(_ other: Self) ->
        (high: Self, low: Self) {
            let sum = self.addingReportingOverflow(other)
            return (sum.overflow ? 1 : 0, sum.partialValue)
    }
    
    /// Returns the high and low parts of two seqeuential potentially overflowing
    /// additions.
    static func addingFullWidth(_ x: Self, _ y: Self, _ z: Self) ->
        (high: Self, low: Self) {
            let xy = x.addingReportingOverflow(y)
            let xyz = xy.partialValue.addingReportingOverflow(z)
            let high: Self = (xy.overflow ? 1 : 0) +
                (xyz.overflow ? 1 : 0)
            return (high, xyz.partialValue)
    }
    
    /// Returns a tuple containing the value that would be borrowed from a higher
    /// place and the partial difference of this value and `rhs`.
    func subtractingWithBorrow(_ rhs: Self) ->
        (borrow: Self, partialValue: Self) {
            let difference = subtractingReportingOverflow(rhs)
            return (difference.overflow ? 1 : 0, difference.partialValue)
    }
    
    /// Returns a tuple containing the value that would be borrowed from a higher
    /// place and the partial value of `x` and `y` subtracted from this value.
    func subtractingWithBorrow(_ x: Self, _ y: Self) ->
        (borrow: Self, partialValue: Self) {
            let firstDifference = subtractingReportingOverflow(x)
            let secondDifference =
                firstDifference.partialValue.subtractingReportingOverflow(y)
            let borrow: Self = (firstDifference.overflow ? 1 : 0) +
                (secondDifference.overflow ? 1 : 0)
            return (borrow, secondDifference.partialValue)
    }
}

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
