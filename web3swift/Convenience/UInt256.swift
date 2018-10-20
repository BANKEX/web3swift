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
