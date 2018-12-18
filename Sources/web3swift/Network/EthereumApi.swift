//
//  EthereumApi.swift
//  Tests
//
//  Created by Dmitry on 17/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit
import BigInt

private extension Int {
    var hex: String { return "0x" + String(self, radix: 16, uppercase: false) }
}
private extension BigUInt {
    var hex: String { return "0x" + String(self, radix: 16, uppercase: false) }
}

private func bool(_ data: DictionaryReader) throws -> Bool {
    return try data.bool()
}
private func data(_ data: DictionaryReader) throws -> Data {
    return try data.data()
}
private func string(_ data: DictionaryReader) throws -> String {
    return try data.string()
}
private func int(_ data: DictionaryReader) throws -> Int {
    return try data.int()
}
private func uint256(_ data: DictionaryReader) throws -> BigUInt {
    return try data.uint256()
}
private func address(_ data: DictionaryReader) throws -> Address {
    return try data.address()
}
private func block(_ data: DictionaryReader) throws -> BlockInfo? {
    guard !data.isNull() else { return nil }
    return try BlockInfo(data)
}
private func transaction(_ data: DictionaryReader) throws -> TransactionInfo? {
    guard !data.isNull() else { return nil }
    return try TransactionInfo(data)
}
private func transactionReceipt(_ data: DictionaryReader) throws -> TransactionReceiptInfo? {
    guard !data.isNull() else { return nil }
    return try TransactionReceiptInfo(data)
}
private extension Promise where T == DictionaryReader {
    func bool() -> Promise<Bool> {
        return map(web3swift.bool)
    }
    func data() -> Promise<Data> {
        return map(web3swift.data)
    }
    func string() -> Promise<String> {
        return map(web3swift.string)
    }
    func int() -> Promise<Int> {
        return map(web3swift.int)
    }
    func uint256() -> Promise<BigUInt> {
        return map(web3swift.uint256)
    }
    func address() -> Promise<Address> {
        return map(web3swift.address)
    }
    func block() -> Promise<BlockInfo?> {
        return map(web3swift.block)
    }
    func transaction() -> Promise<TransactionInfo?> {
        return map(web3swift.transaction)
    }
    func transactionReceipt() -> Promise<TransactionReceiptInfo?> {
        return map(web3swift.transactionReceipt)
    }
    func array<T>(_ convert: @escaping (DictionaryReader)throws->(T)) -> Promise<[T]> {
        return map { try $0.array().map(convert) }
    }
}

/**
 WIP
 https://github.com/ethereum/wiki/wiki/JSON-RPC
 */
class JsonRpcApi {
    var network: NetworkProvider
    init(network: NetworkProvider) {
        self.network = network
    }
    
    private func blockNumber(_ block: BlockNumber) -> Promise<String> {
        return block.promise(network: network)
    }
    
    func web3_clientVersion() -> Promise<Int> {
        return network.send("web3_clientVersion").int()
    }
    func web3_sha3(_ data: Data) -> Promise<Data> {
        return network.send("web3_sha3", data.hex).data()
    }
    func net_version() -> Promise<String> {
        return network.send("net_version").string()
    }
    func net_listening() -> Promise<Bool> {
        return network.send("net_listening").bool()
    }
    func net_peerCount() -> Promise<Int> {
        return network.send("net_peerCount").int()
    }
    func eth_protocolVersion() -> Promise<String> {
        return network.send("eth_protocolVersion").string()
    }
    struct SyncingStatus {
        let startingBlock: Int
        let currentBlock: Int
        let highestBlock: Int
        init?(_ data: DictionaryReader) throws {
            startingBlock = try data.at("startingBlock").int()
            currentBlock = try data.at("currentBlock").int()
            highestBlock = try data.at("highestBlock").int()
        }
    }
    func eth_syncing() -> Promise<SyncingStatus?> {
        return network.send("eth_syncing").map {
            let bool = (try? $0.bool()) ?? true
            guard bool else { return nil }
            return try SyncingStatus($0)
        }
    }
    func eth_coinbase() -> Promise<Address> {
        return network.send("eth_coinbase").address()
    }
    func eth_mining() -> Promise<Bool> {
        return network.send("eth_mining").bool()
    }
    func eth_hashrate() -> Promise<Int> {
        return network.send("eth_hashrate").int()
    }
    func eth_gasPrice() -> Promise<BigUInt> {
        return network.send("eth_gasPrice").uint256()
    }
    func eth_accounts() -> Promise<[Address]> {
        return network.send("eth_accounts").array(address)
    }
    func eth_getBalance(address: Address, block: BlockNumber) -> Promise<BigUInt> {
        return network.send("eth_getBalance", address, block).uint256()
    }
    func eth_getStorageAt(_ address: Address, position: BigUInt, block: BlockNumber) -> Promise<Data> {
        return network.send("eth_getStorageAt", address, position, block).data()
    }
    func eth_getTransactionCount(_ address: Address, block: BlockNumber) -> Promise<BigUInt> {
        return network.send("eth_getTransactionCount", address, block).uint256()
    }
    func eth_getBlockTransactionCountByHash(_ hash: Data) -> Promise<BigUInt> {
        return network.send("eth_getBlockTransactionCountByHash", hash).uint256()
    }
    func eth_getBlockTransactionCountByNumber(_ block: BlockNumber) -> Promise<BigUInt> {
        return network.send("eth_getBlockTransactionCountByNumber", block).uint256()
    }
    func eth_getUncleCountByBlockHash(_ hash: Data) -> Promise<BigUInt> {
        return network.send("eth_getUncleCountByBlockHash", hash).uint256()
    }
    func eth_getUncleCountByBlockNumber(_ block: BlockNumber) -> Promise<BigUInt> {
        return network.send("eth_getUncleCountByBlockNumber", block).uint256()
    }
    func eth_getCode(address: Address, block: BlockNumber) -> Promise<Data> {
        return network.send("eth_getCode", address, block).data()
    }
    func eth_sign(address: Address, data: Data) -> Promise<Data> {
        return network.send("eth_sign", address, data).data()
    }
    func eth_sendTransaction(from: Address, to: Address, gas: BigUInt?, gasPrice: BigUInt?, value: BigUInt?, data: Data, nonce: BigUInt?) -> Promise<Data> {
        let dictionary = JsonRpcDictionary()
            .set("from", from)
            .set("to", to)
            .set("gas", gas)
            .set("gasPrice", gasPrice)
            .set("value", value)
            .set("data", data)
            .set("nonce", nonce)
        return network.send("eth_sendTransaction", dictionary).data()
    }
    func eth_sendRawTransaction(data: Data) -> Promise<Data> {
        return network.send("eth_sendRawTransaction", data).data()
    }
    func eth_call(from: Address?, to: Address, gas: BigUInt?, gasPrice: BigUInt?, value: BigUInt?, data: Data?) -> Promise<Data> {
        let dictionary = JsonRpcDictionary()
            .set("from", from)
            .set("to", to)
            .set("gas", gas)
            .set("gasPrice", gasPrice)
            .set("value", value)
            .set("data", data)
        return network.send("eth_call", dictionary).data()
    }
    func eth_estimateGas(from: Address?, to: Address, gas: BigUInt?, gasPrice: BigUInt?, value: BigUInt?, data: Data?) -> Promise<BigUInt> {
        let dictionary = JsonRpcDictionary()
            .set("from", from)
            .set("to", to)
            .set("gas", gas)
            .set("gasPrice", gasPrice)
            .set("value", value)
            .set("data", data)
        return network.send("eth_estimateGas", dictionary).uint256()
    }
    
    func eth_getBlockByHash(_ hash: Data, _ fullInformation: Bool) -> Promise<BlockInfo?> {
        return network.send("eth_getBlockByHash", hash, fullInformation).block()
    }
    func eth_getBlockByNumber(_ number: BigUInt, _ fullInformation: Bool) -> Promise<BlockInfo?> {
        return network.send("eth_getBlockByNumber", number, fullInformation).block()
    }
    func eth_getTransactionByHash(_ hash: Data) -> Promise<TransactionInfo?> {
        return network.send("eth_getTransactionByHash", hash).transaction()
    }
    func eth_getTransactionByBlockHashAndIndex(_ blockHash: Data, _ index: BigUInt) -> Promise<TransactionInfo?> {
        return network.send("eth_getTransactionByBlockHashAndIndex", blockHash, index).transaction()
    }
    func eth_getTransactionByBlockNumberAndIndex(_ number: BlockNumber, _ index: BigUInt) -> Promise<TransactionInfo?> {
        return network.send("eth_getTransactionByBlockNumberAndIndex", number, index).transaction()
    }
    func eth_getTransactionReceipt(_ hash: Data) -> Promise<TransactionReceiptInfo?> {
        return network.send("eth_getTransactionReceipt", hash).transactionReceipt()
    }
    func eth_getUncleByBlockHashAndIndex(_ hash: Data, _ index: BigUInt) -> Promise<BlockInfo?> {
        return network.send("eth_getUncleByBlockHashAndIndex", hash, index).block()
    }
    func eth_getUncleByBlockNumberAndIndex(_ number: BigUInt, _ index: BigUInt) -> Promise<BlockInfo?> {
        return network.send("eth_getUncleByBlockNumberAndIndex", number, index).block()
    }
    func eth_newFilter(from: BlockNumber, to: BlockNumber, address: Address, topics: TopicFilters) -> Promise<BigUInt> {
        return network.send("net_listening", from, to, address, topics).uint256()
    }
    func eth_newBlockFilter() -> Promise<BigUInt> {
        return network.send("eth_newBlockFilter").uint256()
    }
    func eth_newPendingTransactionFilter() -> Promise<BigUInt> {
        return network.send("eth_newPendingTransactionFilter").uint256()
    }
    func eth_uninstallFilter(_ id: BigUInt) -> Promise<Bool> {
        return network.send("eth_uninstallFilter", id).bool()
    }
//    func eth_getFilterChanges(_ id: BigUInt) -> Promise<> {
//        return network.send("eth_getFilterChanges").
//    }
//    func net_listening() -> Promise<> {
//        return network.send("net_listening").
//    }
//    func net_listening() -> Promise<> {
//        return network.send("net_listening").
//    }
//    func net_listening() -> Promise<> {
//        return network.send("net_listening").
//    }
//    func net_listening() -> Promise<> {
//        return network.send("net_listening").
//    }
}
    
//eth_protocolVersion
//eth_syncing
//eth_coinbase
//eth_mining
//eth_hashrate
//eth_gasPrice
//eth_accounts
//eth_blockNumber
//eth_getBalance
//eth_getStorageAt
//eth_getTransactionCount
//eth_getBlockTransactionCountByHash
//eth_getBlockTransactionCountByNumber
//eth_getUncleCountByBlockHash
//eth_getUncleCountByBlockNumber
//eth_getCode
//eth_sign
//eth_sendTransaction
//eth_sendRawTransaction
//eth_call
//eth_estimateGas
//eth_getBlockByHash
//eth_getBlockByNumber
//eth_getTransactionByHash
//eth_getTransactionByBlockHashAndIndex
//eth_getTransactionByBlockNumberAndIndex
//eth_getTransactionReceipt
//eth_getUncleByBlockHashAndIndex
//eth_getUncleByBlockNumberAndIndex
//eth_getCompilers
//eth_compileLLL
//eth_compileSolidity
//eth_compileSerpent
//eth_newFilter

//eth_newBlockFilter
//eth_newPendingTransactionFilter
//eth_uninstallFilter
//eth_getFilterChanges
//eth_getFilterLogs
//eth_getLogs
//eth_getWork
//eth_submitWork
//eth_submitHashrate
//eth_getProof

//db_putString
//db_getString
//db_putHex
//db_getHex

//shh_post
//shh_version
//shh_newIdentity
//shh_hasIdentity
//shh_newGroup
//shh_addToGroup
//shh_newFilter
//shh_uninstallFilter
//shh_getFilterChanges
//shh_getMessages
//}




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
    let transactions: [Data]
    /// uncles: Array - Array of uncle hashes.
    let uncles: [Data]
    init(_ json: DictionaryReader) throws {
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
        transactions = try json.at("transactions").array(data)
        uncles = try json.at("uncles").array(data)
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
    init(_ json: DictionaryReader) throws {
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
    init(_ json: DictionaryReader) throws {
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
    init(_ json: DictionaryReader) throws {
        blockHash = try json.at("blockHash").data()
        blockNumber = try json.at("blockNumber").uint256()
        transactionIndex = try json.at("transactionIndex").uint256()
    }
}

class TransactionReceiptInfo {
    /// transactionHash : DATA, 32 Bytes - hash of the transaction.
    let transactionHash: Data
    /// transactionIndex: QUANTITY - integer of the transaction's index position in the block.
    let transactionIndex: BigUInt
    /// blockHash: DATA, 32 Bytes - hash of the block where this transaction was in.
    let blockHash: Data
    /// blockNumber: QUANTITY - block number where this transaction was in.
    let blockNumber: BigUInt
    /// from: DATA, 20 Bytes - address of the sender.
    let from: Address
    /// to: DATA, 20 Bytes - address of the receiver. null when it's a contract creation transaction.
    let to: Address?
    /// cumulativeGasUsed : QUANTITY - The total amount of gas used when this transaction was executed in the block.
    let cumulativeGasUsed: BigUInt
    /// gasUsed : QUANTITY - The amount of gas used by this specific transaction alone.
    let gasUsed: BigUInt
    /// contractAddress : DATA, 20 Bytes - The contract address created, if the transaction was a contract creation, otherwise null.
    let contractAddress: Address?
    /// logs: Array - Array of log objects, which this transaction generated.
    let logs: [TransactionLog]
    /// logsBloom: DATA, 256 Bytes - Bloom filter for light clients to quickly retrieve related logs.
    let logsBloom: Data
    
    /// It also returns either :
    /// root : DATA 32 bytes of post-transaction stateroot (pre Byzantium)
    let root: Data?
    /// status: QUANTITY either 1 (success) or 0 (failure)
    let status: Int?
    init(_ json: DictionaryReader) throws {
        transactionHash = try json.at("transactionHash").data()
        transactionIndex = try json.at("transactionIndex").uint256()
        blockHash = try json.at("blockHash").data()
        blockNumber = try json.at("blockNumber").uint256()
        from = try json.at("from").address()
        to = try json.optional("to")?.address()
        cumulativeGasUsed = try json.at("cumulativeGasUsed").uint256()
        gasUsed = try json.at("gasUsed").uint256()
        contractAddress = try json.optional("contractAddress")?.address()
        logs = try json.at("logs").array(TransactionLog.init)
        logsBloom = try json.at("logsBloom").data()
        root = try json.optional("root")?.data()
        status = try json.optional("status")?.int()
    }
}

class TransactionLog {
    init(_ json: DictionaryReader) throws {
        
    }
}

enum TopicFilter {
    case any, exact(Data), or(Data,Data)
}

class TopicFilters: JsonRpcInput {
    var filters = [TopicFilter]()
    init() {}
    
    func append(_ filter: TopicFilter) {
        self.filters.append(filter)
    }
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        var mapped = [Any]()
        for filter in filters {
            switch filter {
                case .any:
                mapped.append(NSNull())
            case .exact(let data):
                mapped.append(data.hex.withHex)
            case let .or(a, b):
                mapped.append([a.hex.withHex, b.hex.withHex])
            }
        }
        return mapped
    }
}


class FilterChange {
    /// For filters created with eth_newBlockFilter the return are block hashes (DATA, 32 Bytes), e.g. ["0x3454645634534..."].
    var newBlocks: [Data]?
    var newPendingTransactions: [Data]?
    
    
    /// For filters created with eth_newPendingTransactionFilter the return are transaction hashes (DATA, 32 Bytes), e.g. ["0x6345343454645..."].
    
    /// For filters created with eth_newFilter logs are objects with following params:
    
    /// removed: TAG - true when the log was removed, due to a chain reorganization. false if its a valid log.
    /// logIndex: QUANTITY - integer of the log index position in the block. null when its pending log.
    /// transactionIndex: QUANTITY - integer of the transactions index position log was created from. null when its pending log.
    /// transactionHash: DATA, 32 Bytes - hash of the transactions this log was created from. null when its pending log.
    /// blockHash: DATA, 32 Bytes - hash of the block where this log was in. null when its pending. null when its pending log.
    /// blockNumber: QUANTITY - the block number where this log was in. null when its pending. null when its pending log.
    /// address: DATA, 20 Bytes - address from which this log originated.
    /// data: DATA - contains the non-indexed arguments of the log.
    /// topics: Array of DATA - Array of 0 to 4 32 Bytes DATA of indexed log arguments. (In solidity: The first topic is the hash of the signature of the event (e.g. Deposit(address,bytes32,uint256)), except you declared the event with the anonymous specifier.)
}

class CustomFilterChange {
    
}
