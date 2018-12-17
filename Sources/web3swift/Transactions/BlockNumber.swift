//
//  Block.swift
//  web3swift
//
//  Created by Dmitry on 14/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

enum BlockNumberType {
    case exact, earliest, latest, pending
}

/// WIP
struct BlockNumber {
    var type: BlockNumberType
    var offset: BigInt = 0
    init(type: BlockNumberType, offset: BigInt = 0) {
        self.type = type
        self.offset = offset
    }
    init(_ string: String) {
        switch string {
        case "latest":
            type = .latest
        case "pending":
            type = .pending
        case "earliest":
            type = .earliest
        default:
            type = .exact
            offset = try! BigInt(DictionaryReader(string).uint256())
        }
    }
    
    func promise(network: NetworkProvider) -> Promise<String> {
        // WIP
        let (promise, resolver) = Promise<String>.pending()
        return promise
    }
    
    static var latest: BlockNumber {
        return BlockNumber(type: .latest)
    }
    static var earliest: BlockNumber {
        return BlockNumber(type: .earliest)
    }
    static var pending: BlockNumber {
        return BlockNumber(type: .pending)
    }
    
    static func - (l: BlockNumber, r: BigInt) -> BlockNumber {
        var v = l
        v.offset -= r
        return v
    }
    static func + (l: BlockNumber, r: BigInt) -> BlockNumber {
        var v = l
        v.offset -= r
        return v
    }
}

extension BlockNumber: ExpressibleByIntegerLiteral {
    init(integerLiteral value: Int) {
        type = .exact
        offset = BigInt(value)
    }
}

extension BlockNumber: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.init(value)
    }
}
