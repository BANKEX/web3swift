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
        init?(_ data: AnyReader) throws {
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
        return network.send("eth_accounts").array(_address)
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
        let dictionary = JDictionary()
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
        let dictionary = JDictionary()
            .set("from", from)
            .set("to", to)
            .set("gas", gas)
            .set("gasPrice", gasPrice)
            .set("value", value)
            .set("data", data)
        return network.send("eth_call", dictionary).data()
    }
    func eth_estimateGas(from: Address?, to: Address, gas: BigUInt?, gasPrice: BigUInt?, value: BigUInt?, data: Data?) -> Promise<BigUInt> {
        let dictionary = JDictionary()
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
    func eth_newFilter(_ options: [FilterOptions]) -> Promise<BigUInt> {
        return network.send("eth_newFilter", JArray(options)).uint256()
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
    func eth_getFilterChanges(_ id: BigUInt) -> Promise<FilterChanges> {
        return network.send("eth_getFilterChanges", id).filterChanges()
    }
    func eth_getFilterLogs(_ id: BigUInt) -> Promise<FilterChanges> {
        return network.send("eth_getFilterLogs", id).filterChanges()
    }
    func eth_getLogs(_ logs: [FilterLogOptions]) -> Promise<FilterChanges> {
        return network.send("eth_getLogs", JArray(logs)).filterChanges()
    }
    func eth_getWork() -> Promise<WorkInfo> {
        return network.send("eth_getWork").work()
    }
    func eth_submitWork(nonce: UInt64, headerPowHash: Data, mixDigest: Data) -> Promise<Bool> {
        return network.send("eth_submitWork", BigUInt(nonce), headerPowHash, mixDigest).bool()
    }
    func eth_submitHashrate(hashRate: Data, id: Data) -> Promise<Bool> {
        return network.send("eth_submitHashrate", hashRate, id).bool()
    }
    func eth_getProof(address: Address, keys: [Data], block: BlockNumber) -> Promise<ProofInfo> {
        return network.send("eth_getProof", address, JArray(keys), block).proof()
    }
    func shh_version() -> Promise<String> {
        return network.send("shh_version").string()
    }
    func shh_post(from: Data, to: Data, topics: [Data], payload: Data, priority: BigUInt, ttl: BigUInt) -> Promise<Bool> {
        let request = JDictionary()
            .set("from", from)
            .set("to", to)
            .set("topics", JArray(topics))
            .set("payload", payload)
            .set("priority", priority)
            .set("ttl", ttl)
        return network.send("shh_post", request).bool()
    }
    func shh_newIdentity() -> Promise<Data> {
        return network.send("shh_newIdentity").data()
    }
    func shh_newGroup() -> Promise<Data> {
        return network.send("shh_newGroup").data()
    }
    func shh_addToGroup() -> Promise<Bool> {
        return network.send("shh_addToGroup").bool()
    }
    func shh_newFilter(to: Data, topics: TopicFilters) -> Promise<BigUInt> {
        return network.send("shh_newFilter").uint256()
    }
    func shh_uninstallFilter(id: BigUInt) -> Promise<Bool> {
        return network.send("shh_uninstallFilter").bool()
    }
    func shh_getFilterChanges(id: BigUInt) -> Promise<[ShhMessage]> {
        return network.send("shh_getFilterChanges", id).shhMessages()
    }
    func shh_getMessages(id: BigUInt) -> Promise<[ShhMessage]> {
        return network.send("shh_getMessages").shhMessages()
    }
}

private extension Int {
    var hex: String { return "0x" + String(self, radix: 16, uppercase: false) }
}
private extension BigUInt {
    var hex: String { return "0x" + String(self, radix: 16, uppercase: false) }
}

private func _bool(_ data: AnyReader) throws -> Bool {
    return try data.bool()
}
private func _data(_ data: AnyReader) throws -> Data {
    return try data.data()
}
private func _string(_ data: AnyReader) throws -> String {
    return try data.string()
}
private func _int(_ data: AnyReader) throws -> Int {
    return try data.int()
}
private func _uint256(_ data: AnyReader) throws -> BigUInt {
    return try data.uint256()
}
private func _address(_ data: AnyReader) throws -> Address {
    return try data.address()
}
private func _block(_ data: AnyReader) throws -> BlockInfo? {
    guard !data.isNull() else { return nil }
    return try BlockInfo(data)
}
private func _transaction(_ data: AnyReader) throws -> TransactionInfo? {
    guard !data.isNull() else { return nil }
    return try TransactionInfo(data)
}
private func _transactionReceipt(_ data: AnyReader) throws -> TransactionReceiptInfo? {
    guard !data.isNull() else { return nil }
    return try TransactionReceiptInfo(data)
}
private func _filterChanges(_ data: AnyReader) throws -> FilterChanges {
    return try FilterChanges(data)
}
private func _work(_ data: AnyReader) throws -> WorkInfo {
    return try WorkInfo(data)
}
private func _proof(_ data: AnyReader) throws -> ProofInfo {
    return try ProofInfo(data)
}
private func _shhMessage(_ data: AnyReader) throws -> ShhMessage {
    return try ShhMessage(data)
}
private extension Promise where T == AnyReader {
    func bool() -> Promise<Bool> {
        return map(_bool)
    }
    func data() -> Promise<Data> {
        return map(_data)
    }
    func string() -> Promise<String> {
        return map(_string)
    }
    func int() -> Promise<Int> {
        return map(_int)
    }
    func uint256() -> Promise<BigUInt> {
        return map(_uint256)
    }
    func address() -> Promise<Address> {
        return map(_address)
    }
    func block() -> Promise<BlockInfo?> {
        return map(_block)
    }
    func transaction() -> Promise<TransactionInfo?> {
        return map(_transaction)
    }
    func transactionReceipt() -> Promise<TransactionReceiptInfo?> {
        return map(_transactionReceipt)
    }
    func filterChanges() -> Promise<FilterChanges> {
        return map(_filterChanges)
    }
    func work() -> Promise<WorkInfo> {
        return map(_work)
    }
    func proof() -> Promise<ProofInfo> {
        return map(_proof)
    }
    func shhMessages() -> Promise<[ShhMessage]> {
        return array(_shhMessage)
    }
    func array<T>(_ convert: @escaping (AnyReader)throws->(T)) -> Promise<[T]> {
        return map { try $0.array().map(convert) }
    }
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
        uncles = try json.at("uncles").array(_data)
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
    init(_ json: AnyReader) throws {
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
    init(_ json: AnyReader) throws {
        
    }
}

enum TopicFilter {
    case any, exact(Data), or(Data,Data)
}

class TopicFilters: JEncodable {
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


class FilterChanges {
    /// For filters created with eth_newBlockFilter the return are block hashes (DATA, 32 Bytes), e.g. ["0x3454645634534..."].
    var newBlocks = [Data]()
    
    /// For filters created with eth_newPendingTransactionFilter the return are transaction hashes (DATA, 32 Bytes), e.g. ["0x6345343454645..."].
    var newPendingTransactions = [Data]()
    
    /// For filters created with eth_newFilter logs are objects with following params:
    var newFilter = [FilterChange]()
    
    init(_ json: AnyReader) throws {
        let array = try json.array()
        guard !array.isEmpty else { return }
        if array[0].raw is String {
            newBlocks = try array.map { try $0.data() }
            newPendingTransactions = newBlocks
        } else {
            newFilter = try array.map(FilterChange.init)
        }
    }
}

class FilterChange {
    /// removed: TAG - true when the log was removed, due to a chain reorganization. false if its a valid log.
    let removed: Bool
    /// logIndex: QUANTITY - integer of the log index position in the block. null when its pending log.
    let logIndex: BigUInt
    /// transactionIndex: QUANTITY - integer of the transactions index position log was created from. null when its pending log.
    let transactionIndex: BigUInt
    /// transactionHash: DATA, 32 Bytes - hash of the transactions this log was created from. null when its pending log.
    let transactionHash: Data
    /// blockHash: DATA, 32 Bytes - hash of the block where this log was in. null when its pending. null when its pending log.
    let blockHash: Data
    /// blockNumber: QUANTITY - the block number where this log was in. null when its pending. null when its pending log.
    let blockNumber: BigUInt
    /// address: DATA, 20 Bytes - address from which this log originated.
    let address: Address
    /// data: DATA - contains the non-indexed arguments of the log.
    let data: Data
    /// topics: Array of DATA - Array of 0 to 4 32 Bytes DATA of indexed log arguments. (In solidity: The first topic is the hash of the signature of the event (e.g. Deposit(address,bytes32,uint256)), except you declared the event with the anonymous specifier.)
    let topics: [Data]
    init(_ json: AnyReader) throws {
        removed = try json.at("removed").bool()
        logIndex = try json.at("logIndex").uint256()
        transactionIndex = try json.at("transactionIndex").uint256()
        transactionHash = try json.at("transactionHash").data()
        blockHash = try json.at("blockHash").data()
        blockNumber = try json.at("v").uint256()
        address = try json.at("address").address()
        data = try json.at("data").data()
        topics = try json.at("topics").array(_data)
    }
}




class FilterOptions: JEncodable {
    /// fromBlock: QUANTITY|TAG - (optional, default: "latest") Integer block number, or "latest" for the last mined block or "pending", "earliest" for not yet mined transactions.
    var from: BlockNumber?
    
    /// toBlock: QUANTITY|TAG - (optional, default: "latest") Integer block number, or "latest" for the last mined block or "pending", "earliest" for not yet mined transactions.
    var to: BlockNumber?
    
    /// address: DATA|Array, 20 Bytes - (optional) Contract address or a list of addresses from which logs should originate.
    var address = [Address]()
    
    /// topics: Array of DATA, - (optional) Array of 32 Bytes DATA topics. Topics are order-dependent. Each topic can also be an array of DATA with "or" options.
    var topics = [Address]()
    
    init() {}
    
    var dictionary: JDictionary {
        return JDictionary()
            .set("from", from)
            .set("to", to)
            .set("address", JArray(address).nilIfEmpty())
            .set("topics", JArray(topics).nilIfEmpty())
    }
    
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return dictionary
    }
}

class FilterLogOptions: FilterOptions {
    /// blockhash: DATA, 32 Bytes - (optional) With the addition of EIP-234 (Geth >= v1.8.13 or Parity >= v2.1.0), blockHash is a new filter option which restricts the logs returned to the single block with the 32-byte hash blockHash. Using blockHash is equivalent to fromBlock = toBlock = the block number with hash blockHash. If blockHash is present in the filter criteria, then neither fromBlock nor toBlock are allowed.
    var blockHash: Data?
    override var dictionary: JDictionary {
        return super.dictionary.set("blockHash", blockHash)
    }
}

class WorkInfo {
    /// DATA, 32 Bytes - current block header pow-hash
    let currentBlockHeader: Data
    /// DATA, 32 Bytes - the seed hash used for the DAG.
    let seedHash: Data
    /// DATA, 32 Bytes - the boundary condition ("target"), 2^256 / difficulty.
    let boundaryCondition: Data
    
    init(_ json: AnyReader) throws {
        let array = try json.array()
        currentBlockHeader = try array.at(0).data()
        seedHash = try array.at(1).data()
        boundaryCondition = try array.at(2).data()
    }
}

class ProofInfo {
    /// balance: QUANTITY - the balance of the account. See eth_getBalance
    let balance: BigUInt
    /// codeHash: DATA, 32 Bytes - hash of the code of the account. For a simple Account without code it will return "0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470"
    let codeHash: Data
    
    /// nonce: QUANTITY, - nonce of the account. See eth_getTransactionCount
    let nonce: BigUInt
    
    /// storageHash: DATA, 32 Bytes - SHA3 of the StorageRoot. All storage will deliver a MerkleProof starting with this rootHash.
    let storageHash: Data
    
    /// accountProof: ARRAY - Array of rlp-serialized MerkleTree-Nodes, starting with the stateRoot-Node, following the path of the SHA3 (address) as key.
    let accountProof: [Data]
    
    /// storageProof: ARRAY - Array of storage-entries as requested.
    let storageProof: [IndexedProof]
    init(_ json: AnyReader) throws {
        balance = try json.at("balance").uint256()
        codeHash = try json.at("codeHash").data()
        nonce = try json.at("nonce").uint256()
        storageHash = try json.at("storageHash").data()
        accountProof = try json.at("accountProof").array(_data)
        storageProof = try json.at("storageProof").array(IndexedProof.init)
    }
}

class IndexedProof {
    /// key: QUANTITY - the requested storage key
    let key: BigUInt
    /// value: QUANTITY - the storage value
    let value: BigUInt
    /// proof: ARRAY - Array of rlp-serialized MerkleTree-Nodes, starting with the storageHash-Node, following the path of the SHA3 (key) as path.
    let proof: [Data]
    init(_ json: AnyReader) throws {
        key = try json.at("key").uint256()
        value = try json.at("value").uint256()
        proof = try json.at("proof").array(_data)
    }
}

extension AnyReader {
    func shhAddress() throws -> ShhAddress {
        return try ShhAddress(self)
    }
}

class ShhAddress {
    let data: Data
    init(_ data: Data) {
        self.data = data
    }
    init(_ json: AnyReader) throws {
        data = try json.data()
    }
}

class ShhMessage {
    /// hash: DATA, 32 Bytes (?) - The hash of the message.
    let hash: Data
    /// from: DATA, 60 Bytes - The sender of the message, if a sender was specified.
    let from: ShhAddress
    /// to: DATA, 60 Bytes - The receiver of the message, if a receiver was specified.
    let to: ShhAddress
    /// expiry: QUANTITY - Integer of the time in seconds when this message should expire (?).
    let expiry: Int
    /// ttl: QUANTITY - Integer of the time the message should float in the system in seconds (?).
    let ttl: Int
    /// sent: QUANTITY - Integer of the unix timestamp when the message was sent.
    let sent: Int
    /// topics: Array of DATA - Array of DATA topics the message contained.
    let topics: [Data]
    /// payload: DATA - The payload of the message.
    let payload: Data
    /// workProved: QUANTITY - Integer of the work this message required before it was send (?).
    let workProved: Int
    init(_ json: AnyReader) throws {
        hash = try json.at("hash").data()
        from = try json.at("from").shhAddress()
        to = try json.at("to").shhAddress()
        expiry = try json.at("expiry").int()
        ttl = try json.at("ttl").int()
        sent = try json.at("sent").int()
        topics = try json.at("topics").array(_data)
        payload = try json.at("payload").data()
        workProved = try json.at("workProved").int()
    }
}
