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
        var dictionary = [String: JsonRpcInput]()
        dictionary["from"] = from
        dictionary["to"] = to
        dictionary["gas"] = gas
        dictionary["gasPrice"] = gasPrice
        dictionary["value"] = value
        dictionary["data"] = data
        dictionary["nonce"] = nonce
        return network.send("eth_sendTransaction", dictionary as! JsonRpcInput).data()
    }
    func eth_sendRawTransaction(data: Data) -> Promise<Data> {
        return network.send("eth_sendRawTransaction", data).data()
    }
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
