//
//  NetworkId.swift
//  web3swift
//
//  Created by Dmitry on 09/01/2019.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

/// Enum for the most-used Ethereum networks. Network ID is crucial for EIP155 support
public struct NetworkId {
    /// Network id number
    public var rawValue: BigUInt
    /// NetworkId(1) init
    public init(_ rawValue: BigUInt) {
        self.rawValue = rawValue
    }
    
    /// Init with int value
    public init(_ rawValue: Int) {
        self.rawValue = BigUInt(rawValue)
    }
    
    /// Returns array of all known networks (mainnet, ropsten, rinkeby and kovan)
    public var all: [NetworkId] {
        return [.mainnet, .ropsten, .rinkeby, .kovan]
    }
    
    /// Default networkid (.mainnet)
    public static var `default`: NetworkId = .mainnet
    /// - Returns: 1
    public static var mainnet: NetworkId { return 1 }
    /// - Returns: 3
    public static var ropsten: NetworkId { return 3 }
    /// - Returns: 4
    public static var rinkeby: NetworkId { return 4 }
    /// - Returns: 42
    public static var kovan: NetworkId { return 42 }
}

extension NetworkId: RawRepresentable {
    /// RawRepresentable init
    public init(rawValue: BigUInt) {
        self.rawValue = rawValue
    }
}

extension NetworkId: CustomStringConvertible {
    /// Returns network name
    public var description: String {
        switch rawValue {
        case 1: return "mainnet"
        case 3: return "ropsten"
        case 4: return "rinkeby"
        case 42: return "kovan"
        default: return ""
        }
    }
}

extension NetworkId: ExpressibleByIntegerLiteral {
    /// Literal type used for ExpressibleByIntegerLiteral
    public typealias IntegerLiteralType = Int
    /// ExpressibleByIntegerLiteral init so you can do
    /// ```
    /// let networkId: NetworkId = 1
    /// ```
    public init(integerLiteral value: Int) {
        rawValue = BigUInt(value)
    }
}
