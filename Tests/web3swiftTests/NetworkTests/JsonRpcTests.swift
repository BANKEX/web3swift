//
//  JsonRpcTests.swift
//  Tests
//
//  Created by Dmitry on 17/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import XCTest
import PromiseKit
import BigInt
@testable import web3swift

class TestCallRequest: Request {
    init() {
        super.init(method: "eth_call")
    }
    override func request() -> [Any] {
        return [[
            "data": "0x06fdde03",
            "to":"0x45245bc59219eeaaf6cd3f382e078a461ff9de7b",
            "value":"0x0",
            "gasPrice":"0x0"
            ], "latest"]
    }
    override func response(data: AnyReader) throws {
        let expected = "0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000001e2242414e4b4558222070726f6a656374207574696c69747920746f6b656e0000"
        try data.string().equals(expected)
    }
}

class JsonRpcTests: XCTestCase {
    func testRequest() throws {
        let request = TestCallRequest()
        URLSession.shared.send(request: request, to: .infura(.mainnet))
        _ = try! request.promise.wait()
    }
    func testGetBlockByNumber() throws {
        let a = DispatchSemaphore(value: 0)
        getBlock(number: 436) { block, error in
            a.signal()
        }
        a.wait()
    }
}

func getBlock(number: BigUInt, completion: @escaping (BlockInfo?, Error?)->()) {
    var data = [String: Any]()
    data["method"] = "eth_getBlockByNumber"
    data["jsonrpc"] = "2.0"
    data["params"] = [String(number, radix: 16).withHex, true]
    data["id"] = 1
    
    let url = URL(string: "https://mainnet.infura.io")!
    var request = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    request.httpBody = try! JSONSerialization.data(withJSONObject: data, options: [])
    
    let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue())
    session.dataTask(with: request) { data, _, error in
        if let data = data {
            do {
                let response = try JSONSerialization.jsonObject(with: data, options: [])
                let reader = DictionaryReader(response)
                let block = try BlockInfo(reader.at("result"))
                completion(block,nil)
            } catch {
                completion(nil,error)
            }
        } else {
            completion(nil,error)
        }
    }.resume()
}



class BlockInfo {
    /// null when its pending block.
    let processed: ProcessedBlockInfo?
    /// parentHash: DATA, 32 Bytes - hash of the parent block.
    let parentHash: Data
    /// sha3Uncles: DATA, 32 Bytes - SHA3 of the uncles data in the block.
    let sha3Uncles: Data
    /// transactionsRoot: DATA, 32 Bytes - the root of the transaction trie of the block.
    let transactionsRoot: Data
    /// stateRoot: DATA, 32 Bytes - the root of the final state trie of the block.
    let stateRoot: Data
    /// receiptsRoot: DATA, 32 Bytes - the root of the receipts trie of the block.
    let receiptsRoot: Data
    /// miner: DATA, 20 Bytes - the address of the beneficiary to whom the mining rewards were given.
    let miner: Address
    /// difficulty: QUANTITY - integer of the difficulty for this block.
    let difficulty: BigUInt
    /// totalDifficulty: QUANTITY - integer of the total difficulty of the chain until this block.
    let totalDifficulty: BigUInt
    /// extraData: DATA - the "extra data" field of this block.
    let extraData: Data
    /// size: QUANTITY - integer the size of this block in bytes.
    let size: BigUInt
    /// gasLimit: QUANTITY - the maximum gas allowed in this block.
    let gasLimit: BigUInt
    /// gasUsed: QUANTITY - the total used gas by all transactions in this block.
    let gasUsed: BigUInt
    /// timestamp: QUANTITY - the unix timestamp for when the block was collated.
    let timestamp: BigUInt
    /// transactions: Array - Array of transaction objects, or 32 Bytes transaction hashes depending on the last given parameter.
    let transactions: [TransactionInfo]
    /// uncles: Array - Array of uncle hashes.
    let uncles: [Data]
    init(_ json: AnyReader) throws {
        processed = try? ProcessedBlockInfo(json)
        parentHash = try json.at("parentHash").data()
        sha3Uncles = try json.at("sha3Uncles").data()
        transactionsRoot = try json.at("transactionsRoot").data()
        stateRoot = try json.at("stateRoot").data()
        receiptsRoot = try json.at("receiptsRoot").data()
        miner = try json.at("miner").address()
        difficulty = try json.at("difficulty").uint256()
        totalDifficulty = try json.at("totalDifficulty").uint256()
        extraData = try json.at("extraData").data()
        size = try json.at("size").uint256()
        gasLimit = try json.at("gasLimit").uint256()
        gasUsed = try json.at("gasUsed").uint256()
        timestamp = try json.at("timestamp").uint256()
        transactions = try json.at("transactions").array(TransactionInfo.init)
        uncles = try json.at("uncles").array { try $0.data() }
    }
}
class ProcessedBlockInfo {
    /// number: QUANTITY - the block number. null when its pending block.
    let number: BigUInt
    /// hash: DATA, 32 Bytes - hash of the block. null when its pending block.
    let hash: Data
    /// nonce: DATA, 8 Bytes - hash of the generated proof-of-work. null when its pending block.
    let nonce: UInt64
    /// logsBloom: DATA, 256 Bytes - the bloom filter for the logs of the block. null when its pending block.
    let logsBloom: Data
    init(_ json: AnyReader) throws {
        number = try json.at("number").uint256()
        hash = try json.at("hash").data()
        nonce = try json.at("nonce").uint64()
        logsBloom = try json.at("logsBloom").data()
    }
}
class TransactionInfo {
    /// null when its pending.
    let processed: ProcessedTransactionInfo?
    /// from: DATA, 20 Bytes - address of the sender.
    let from: Address
    /// gas: QUANTITY - gas provided by the sender.
    let gas: BigUInt
    /// gasPrice: QUANTITY - gas price provided by the sender in Wei.
    let gasPrice: BigUInt
    /// hash: DATA, 32 Bytes - hash of the transaction.
    let hash: Data
    /// input: DATA - the data send along with the transaction.
    let input: Data
    /// nonce: QUANTITY - the number of transactions made by the sender prior to this one.
    let nonce: BigUInt
    /// to: DATA, 20 Bytes - address of the receiver. null when its a contract creation transaction.
    let to: Address
    /// value: QUANTITY - value transferred in Wei.
    let value: BigUInt
    /// v: QUANTITY - ECDSA recovery id
    let v: BigUInt
    /// r: DATA, 32 Bytes - ECDSA signature r
    let r: Data
    /// s: DATA, 32 Bytes - ECDSA signature s
    let s: Data
    init(_ json: AnyReader) throws {
        processed = try? ProcessedTransactionInfo(json)
        from = try json.at("from").address()
        gas = try json.at("gas").uint256()
        gasPrice = try json.at("gasPrice").uint256()
        hash = try json.at("hash").data()
        input = try json.at("input").data()
        nonce = try json.at("nonce").uint256()
        to = try json.at("to").address()
        value = try json.at("value").uint256()
        v = try json.at("v").uint256()
        r = try json.at("r").data()
        s = try json.at("s").data()
    }
}
class ProcessedTransactionInfo {
    /// blockHash: DATA, 32 Bytes - hash of the block where this transaction was in. null when its pending.
    let blockHash: Data
    /// blockNumber: QUANTITY - block number where this transaction was in. null when its pending.
    let blockNumber: BigUInt
    /// transactionIndex: QUANTITY - integer of the transaction's index position in the block. null when its pending.
    let transactionIndex: BigUInt
    init(_ json: AnyReader) throws {
        blockHash = try json.at("blockHash").data()
        blockNumber = try json.at("blockNumber").uint256()
        transactionIndex = try json.at("transactionIndex").uint256()
    }
}
