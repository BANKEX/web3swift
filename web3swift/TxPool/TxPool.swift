//
//  TxPool.swift
//  web3swift-iOS
//
//  Created by Dmitry on 28/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit
import BigInt

public class TxPool {
    public static var `default`: TxPool {
        return TxPool(web3: .default)
    }
    var web3: Web3
    public init(web3: Web3) {
        self.web3 = web3
    }
    
    public func status() -> Promise<TxPoolStatus> {
        let request = JSONRPCRequestFabric.prepareRequest(.txPoolStatus, parameters: [])
        let rp = web3.dispatch(request)
        let queue = web3.requestDispatcher.queue
        return rp.map(on: queue ) { try TxPoolStatus($0.response()) }
    }
    
    public func inspect() -> Promise<TxPoolInspect> {
        let request = JSONRPCRequestFabric.prepareRequest(.txPoolInspect, parameters: [])
        let rp = web3.dispatch(request)
        let queue = web3.requestDispatcher.queue
        return rp.map(on: queue ) { try TxPoolInspect($0.response()) }
    }
    
    public func content() -> Promise<TxPoolContent> {
        let request = JSONRPCRequestFabric.prepareRequest(.txPoolContent, parameters: [])
        let rp = web3.dispatch(request)
        let queue = web3.requestDispatcher.queue
        return rp.map(on: queue ) { try TxPoolContent($0.response()) }
    }
}

extension DictionaryReader {
    func split(_ separator: String, _ expectedSize: Int) throws -> [DictionaryReader] {
        let string = try self.string()
        let array = string.components(separatedBy: separator)
        guard array.count >= expectedSize else { throw Error.unconvertable }
        return array.map { DictionaryReader($0) }
    }
}

public struct TxPoolStatus {
    public var pending: Int
    public var queued: Int
    init(_ dictionary: DictionaryReader) throws {
        pending = try dictionary.at("pending").int()
        queued = try dictionary.at("queued").int()
    }
}

public struct TxPoolInspect {
    public let pending: [InspectedTransaction]
    public let queued: [InspectedTransaction]
    init(_ dictionary: DictionaryReader) throws {
        pending = try TxPoolInspect.parse(dictionary.at("pending"))
        queued = try TxPoolInspect.parse(dictionary.at("queued"))
    }
    init() {
        pending = []
        queued = []
    }
    private static func parse(_ reader: DictionaryReader) throws -> [InspectedTransaction] {
        var array = [InspectedTransaction]()
        try reader.dictionary {
            let from = try $0.address()
            try $1.dictionary {
                let nonce = try $0.int()
                let transaction = try InspectedTransaction($1, from: from, nonce: nonce)
                array.append(transaction)
            }
        }
        return array
    }
}

public struct InspectedTransaction {
    public let from: EthereumAddress
    public let nonce: Int
    public let to: EthereumAddress
    public let value: BigUInt
    public let gasLimit: BigUInt
    public let gasPrice: BigUInt
    init(_ reader: DictionaryReader, from: EthereumAddress, nonce: Int) throws {
        self.from = from
        self.nonce = nonce
        let string = try reader.split(" ", 7)
        to = try string[0].address()
        value = try string[1].uint256()
        gasLimit = try string[4].uint256()
        gasPrice = try string[7].uint256()
    }
}

public struct TxPoolContent {
    public let pending: [TxPoolTransaction]
    public let queued: [TxPoolTransaction]
    init(_ dictionary: DictionaryReader) throws {
        pending = try TxPoolContent.parse(dictionary.at("pending"))
        queued = try TxPoolContent.parse(dictionary.at("queued"))
    }
    init() {
        pending = []
        queued = []
    }
    private static func parse(_ reader: DictionaryReader) throws -> [TxPoolTransaction] {
        var array = [TxPoolTransaction]()
        try reader.dictionary {
            let from = try $0.address()
            try $1.dictionary {
                let nonce = try $0.int()
                let transaction = try TxPoolTransaction($1, from: from, nonce: nonce)
                array.append(transaction)
            }
        }
        return array
    }
}

public struct TxPoolTransaction {
    public let from: EthereumAddress
    public let nonce: Int
    public let to: EthereumAddress
    public let value: BigUInt
    public let gasLimit: BigUInt
    public let gasPrice: BigUInt
    public let input: Data
    public let hash: Data
    public let v: BigUInt
    public let r: BigUInt
    public let s: BigUInt
    public let blockHash: Data
    public let transactionIndex: BigUInt
    init(_ reader: DictionaryReader, from: EthereumAddress, nonce: Int) throws {
        self.from = from
        self.nonce = nonce
        input = try reader.at("input").data()
        gasPrice = try reader.at("gasPrice").uint256()
        s = try reader.at("s").uint256()
        to = try reader.at("to").address()
        value = try reader.at("value").uint256()
        gasLimit = try reader.at("gas").uint256()
        hash = try reader.at("hash").data()
        v = try reader.at("v").uint256()
        transactionIndex = try reader.at("transactionIndex").uint256()
        r = try reader.at("r").uint256()
        blockHash = try reader.at("blockHash").data()
        /* some response:
         "input" : "0xa9059cbb000000000000000000000000c85780130f5877a501c24702440c9e0bb65dea680000000000000000000000000000000000000000000000000000000000000064",
         "gasPrice" : "0x1",
         "s" : "0x224219cd7eefea7a6a4affbf85ca96b4183af5b049bed1c0f9c428b31935bac6",
         "nonce" : "0xea80",
         "to" : "0xd65ef7346144e9ad3b53c69a58b7cb27d02c0ded",
         "value" : "0x0",
         "gas" : "0xc952",
         "from" : "0xa607f816acce53552afb0098d8b0750890b48fbd",
         "hash" : "0x403bd25aec9c86593bc8993b1510b55aa17f2c7bff896ef4a71bf2aa7958b14f",
         "v" : "0xbf9",
         "transactionIndex" : "0x0",
         "r" : "0x30caf905be371d4088b9e7a22d940350ff3d7f22fb36a24b558bea7ace6de66e",
         "blockHash" : "0x0000000000000000000000000000000000000000000000000000000000000000" */
    }
}

