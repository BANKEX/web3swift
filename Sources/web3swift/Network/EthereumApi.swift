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
class EthereumApi {
    var network: NetworkProvider
    init(network: NetworkProvider) {
        self.network = network
    }
    
    private func blockNumber(_ block: BlockNumber) -> Promise<String> {
        return block.promise(network: network)
    }
    
    //    Returns the current client version.
    //
    //    ##### Parameters
    //    none
    //
    //    ##### Returns
    //
    //    `String` - The current client version.
    //
    //    ##### Example
    //    ```js
    //    // Request
    //    curl -X POST --data '{"jsonrpc":"2.0","method":"web3_clientVersion","params":[],"id":67}'
    //
    //    // Result
    //    {
    //      "id":67,
    //      "jsonrpc":"2.0",
    //      "result": "Mist/v0.9.3/darwin/go1.4.1"
    //    }
    //    ```
    func web3_clientVersion() -> Promise<Int> {
        return network.send("web3_clientVersion").int()
    }
    
    /// #### web3_sha3
    ///
    /// Returns Keccak-256 (*not* the standardized SHA3-256) of the given data.
    ///
    /// ##### Parameters
    ///
    /// 1. `DATA` - the data to convert into a SHA3 hash.
    ///
    /// ```js
    /// params: [
    ///  "0x68656c6c6f20776f726c64"
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `DATA` - The SHA3 result of the given string.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"web3_sha3","params":["0x68656c6c6f20776f726c64"],"id":64}'
    ///
    /// // Result
    /// {
    ///  "id":64,
    ///  "jsonrpc": "2.0",
    ///  "result": "0xc94770007dda54cF92009BFF0dE90c06F603a09f"
    /// }
    /// ```
    func web3_sha3(_ data: Data) -> Promise<Data> {
        return network.send("web3_sha3", data.hex).data()
    }
    
    /// Returns the current network id.
    ///
    /// ##### Parameters
    /// none
    ///
    /// ##### Returns
    ///
    /// `String` - The current network id.
    /// - `"1"`: Ethereum Mainnet
    /// - `"2"`: Morden Testnet  (deprecated)
    /// - `"3"`: Ropsten Testnet
    /// - `"4"`: Rinkeby Testnet
    /// - `"42"`: Kovan Testnet
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"net_version","params":[],"id":67}'
    ///
    /// // Result
    /// {
    ///  "id":67,
    ///  "jsonrpc": "2.0",
    ///  "result": "3"
    /// }
    /// ```
    func net_version() -> Promise<String> {
        return network.send("net_version").string()
    }
    
    /// Returns `true` if client is actively listening for network connections.
    ///
    /// ##### Parameters
    /// none
    ///
    /// ##### Returns
    ///
    /// `Boolean` - `true` when listening, otherwise `false`.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"net_listening","params":[],"id":67}'
    ///
    /// // Result
    /// {
    ///  "id":67,
    ///  "jsonrpc":"2.0",
    ///  "result":true
    /// }
    /// ```
    func net_listening() -> Promise<Bool> {
        return network.send("net_listening").bool()
    }
    
    /// Returns number of peers currently connected to the client.
    ///
    /// ##### Parameters
    /// none
    ///
    /// ##### Returns
    ///
    /// `QUANTITY` - integer of the number of connected peers.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":74}'
    ///
    /// // Result
    /// {
    ///  "id":74,
    ///  "jsonrpc": "2.0",
    ///  "result": "0x2" // 2
    /// }
    /// ```
    
    func net_peerCount() -> Promise<Int> {
        return network.send("net_peerCount").int()
    }
    
    /// Returns the current ethereum protocol version.
    ///
    /// ##### Parameters
    /// none
    ///
    /// ##### Returns
    ///
    /// `String` - The current ethereum protocol version.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_protocolVersion","params":[],"id":67}'
    ///
    /// // Result
    /// {
    ///  "id":67,
    ///  "jsonrpc": "2.0",
    ///  "result": "54"
    /// }
    /// ```
    func eth_protocolVersion() -> Promise<String> {
        return network.send("eth_protocolVersion").string()
    }
    
    /// Returns an object with data about the sync status or `false`.
    ///
    ///
    /// ##### Parameters
    /// none
    ///
    /// ##### Returns
    ///
    /// `Object|Boolean`, An object with sync status data or `FALSE`, when not syncing:
    ///  - `startingBlock`: `QUANTITY` - The block at which the import started (will only be reset, after the sync reached his head)
    ///  - `currentBlock`: `QUANTITY` - The current block, same as eth_blockNumber
    ///  - `highestBlock`: `QUANTITY` - The estimated highest block
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": {
    ///    startingBlock: '0x384',
    ///    currentBlock: '0x386',
    ///    highestBlock: '0x454'
    ///  }
    /// }
    /// // Or when not syncing
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": false
    /// }
    /// ```
    func eth_syncing() -> Promise<SyncingStatus?> {
        return network.send("eth_syncing").map {
            let bool = (try? $0.bool()) ?? true
            guard bool else { return nil }
            return try SyncingStatus($0)
        }
    }
    
    /// Returns the client coinbase address.
    ///
    ///
    /// ##### Parameters
    /// none
    ///
    /// ##### Returns
    ///
    /// `DATA`, 20 bytes - the current coinbase address.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_coinbase","params":[],"id":64}'
    ///
    /// // Result
    /// {
    ///  "id":64,
    ///  "jsonrpc": "2.0",
    ///  "result": "0xc94770007dda54cF92009BFF0dE90c06F603a09f"
    /// }
    /// ```
    func eth_coinbase() -> Promise<Address> {
        return network.send("eth_coinbase").address()
    }
    
    /// Returns `true` if client is actively mining new blocks.
    ///
    /// ##### Parameters
    /// none
    ///
    /// ##### Returns
    ///
    /// `Boolean` - returns `true` of the client is mining, otherwise `false`.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_mining","params":[],"id":71}'
    ///
    /// // Result
    /// {
    ///  "id":71,
    ///  "jsonrpc": "2.0",
    ///  "result": true
    /// }
    ///
    /// ```
    func eth_mining() -> Promise<Bool> {
        return network.send("eth_mining").bool()
    }
    
    /// Returns the number of hashes per second that the node is mining with.
    ///
    /// ##### Parameters
    /// none
    ///
    /// ##### Returns
    ///
    /// `QUANTITY` - number of hashes per second.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_hashrate","params":[],"id":71}'
    ///
    /// // Result
    /// {
    ///  "id":71,
    ///  "jsonrpc": "2.0",
    ///  "result": "0x38a"
    /// }
    ///
    /// ```
    func eth_hashrate() -> Promise<Int> {
        return network.send("eth_hashrate").int()
    }
    
    /// Returns the current price per gas in wei.
    ///
    /// ##### Parameters
    /// none
    ///
    /// ##### Returns
    ///
    /// `QUANTITY` - integer of the current gas price in wei.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_gasPrice","params":[],"id":73}'
    ///
    /// // Result
    /// {
    ///  "id":73,
    ///  "jsonrpc": "2.0",
    ///  "result": "0x09184e72a000" // 10000000000000
    /// }
    /// ```
    func eth_gasPrice() -> Promise<BigUInt> {
        return network.send("eth_gasPrice").uint256()
    }
    
    /// Returns a list of addresses owned by client.
    ///
    ///
    /// ##### Parameters
    /// none
    ///
    /// ##### Returns
    ///
    /// `Array of DATA`, 20 Bytes - addresses owned by the client.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_accounts","params":[],"id":1}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": ["0xc94770007dda54cF92009BFF0dE90c06F603a09f"]
    /// }
    /// ```
    func eth_accounts() -> Promise<[Address]> {
        return network.send("eth_accounts").array(_address)
    }
    
    /// Returns the number of most recent block.
    ///
    /// ##### Parameters
    /// none
    ///
    /// ##### Returns
    ///
    /// `QUANTITY` - integer of the current block number the client is on.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
    ///
    /// // Result
    /// {
    ///  "id":83,
    ///  "jsonrpc": "2.0",
    ///  "result": "0xc94" // 1207
    /// }
    /// ```
    func eth_blockNumber() -> Promise<BigUInt> {
        return network.send("eth_blockNumber").uint256()
    }
    
    /// Returns the balance of the account of given address.
    ///
    /// ##### Parameters
    ///
    /// 1. `DATA`, 20 Bytes - address to check for balance.
    /// 2. `QUANTITY|TAG` - integer block number, or the string `"latest"`, `"earliest"` or `"pending"`, see the [default block parameter](#the-default-block-parameter)
    ///
    /// ```js
    /// params: [
    ///   '0xc94770007dda54cF92009BFF0dE90c06F603a09f',
    ///   'latest'
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `QUANTITY` - integer of the current balance in wei.
    ///
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getBalance","params":["0xc94770007dda54cF92009BFF0dE90c06F603a09f", "latest"],"id":1}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": "0x0234c8a3397aab58" // 158972490234375000
    /// }
    /// ```
    func eth_getBalance(address: Address, block: BlockNumber) -> Promise<BigUInt> {
        return network.send("eth_getBalance", address, block).uint256()
    }
    
    /// Returns the value from a storage position at a given address.
    ///
    /// ##### Parameters
    ///
    /// 1. `DATA`, 20 Bytes - address of the storage.
    /// 2. `QUANTITY` - integer of the position in the storage.
    /// 3. `QUANTITY|TAG` - integer block number, or the string `"latest"`, `"earliest"` or `"pending"`, see the [default block parameter](#the-default-block-parameter)
    ///
    /// ##### Returns
    ///
    /// `DATA` - the value at this storage position.
    ///
    /// ##### Example
    /// Calculating the correct position depends on the storage to retrieve. Consider the following contract deployed at `0x295a70b2de5e3953354a6a8344e616ed314d7251` by address `0x391694e7e0b0cce554cb130d723a9d27458f9298`.
    ///
    /// ```
    /// contract Storage {
    ///    uint pos0;
    ///    mapping(address => uint) pos1;
    ///
    ///    function Storage() {
    ///        pos0 = 1234;
    ///        pos1[msg.sender] = 5678;
    ///    }
    
    /// }
    /// ```
    ///
    /// Retrieving the value of pos0 is straight forward:
    ///
    /// ```js
    /// curl -X POST --data '{"jsonrpc":"2.0", "method": "eth_getStorageAt", "params": ["0x295a70b2de5e3953354a6a8344e616ed314d7251", "0x0", "latest"], "id": 1}' localhost:8545
    ///
    /// {"jsonrpc":"2.0","id":1,"result":"0x00000000000000000000000000000000000000000000000000000000000004d2"}
    /// ```
    ///
    /// Retrieving an element of the map is harder. The position of an element in the map is calculated with:
    /// ```js
    /// keccack(LeftPad32(key, 0), LeftPad32(map position, 0))
    /// ```
    ///
    /// This means to retrieve the storage on pos1["0x391694e7e0b0cce554cb130d723a9d27458f9298"] we need to calculate the position with:
    /// ```js
    /// keccak(decodeHex("000000000000000000000000391694e7e0b0cce554cb130d723a9d27458f9298" + "0000000000000000000000000000000000000000000000000000000000000001"))
    /// ```
    /// The geth console which comes with the web3 library can be used to make the calculation:
    /// ```js
    /// > var key = "000000000000000000000000391694e7e0b0cce554cb130d723a9d27458f9298" + "0000000000000000000000000000000000000000000000000000000000000001"
    /// undefined
    /// > web3.sha3(key, {"encoding": "hex"})
    /// "0x6661e9d6d8b923d5bbaab1b96e1dd51ff6ea2a93520fdc9eb75d059238b8c5e9"
    /// ```
    /// Now to fetch the storage:
    /// ```js
    /// curl -X POST --data '{"jsonrpc":"2.0", "method": "eth_getStorageAt", "params": ["0x295a70b2de5e3953354a6a8344e616ed314d7251", "0x6661e9d6d8b923d5bbaab1b96e1dd51ff6ea2a93520fdc9eb75d059238b8c5e9", "latest"], "id": 1}' localhost:8545
    ///
    /// {"jsonrpc":"2.0","id":1,"result":"0x000000000000000000000000000000000000000000000000000000000000162e"}
    ///
    /// ```
    func eth_getStorageAt(_ address: Address, position: BigUInt, block: BlockNumber) -> Promise<Data> {
        return network.send("eth_getStorageAt", address, position, block).data()
    }
    
    /// Returns the number of transactions *sent* from an address.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `DATA`, 20 Bytes - address.
    /// 2. `QUANTITY|TAG` - integer block number, or the string `"latest"`, `"earliest"` or `"pending"`, see the [default block parameter](#the-default-block-parameter)
    ///
    /// ```js
    /// params: [
    ///   '0xc94770007dda54cF92009BFF0dE90c06F603a09f',
    ///   'latest' // state at the latest block
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `QUANTITY` - integer of the number of transactions send from this address.
    ///
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getTransactionCount","params":["0xc94770007dda54cF92009BFF0dE90c06F603a09f","latest"],"id":1}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": "0x1" // 1
    /// }
    /// ```
    func eth_getTransactionCount(_ address: Address, block: BlockNumber) -> Promise<BigUInt> {
        return network.send("eth_getTransactionCount", address, block).uint256()
    }
    
    /// Returns the number of transactions in a block from a block matching the given block hash.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `DATA`, 32 Bytes - hash of a block.
    ///
    /// ```js
    /// params: [
    ///   '0xb903239f8543d04b5dc1ba6579132b143087c68db1b2168786408fcbce568238'
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `QUANTITY` - integer of the number of transactions in this block.
    ///
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getBlockTransactionCountByHash","params":["0xc94770007dda54cF92009BFF0dE90c06F603a09f"],"id":1}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": "0xc" // 11
    /// }
    /// ```
    func eth_getBlockTransactionCountByHash(_ hash: Data) -> Promise<BigUInt> {
        return network.send("eth_getBlockTransactionCountByHash", hash).uint256()
    }
    
    /// Returns the number of transactions in a block matching the given block number.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `QUANTITY|TAG` - integer of a block number, or the string `"earliest"`, `"latest"` or `"pending"`, as in the [default block parameter](#the-default-block-parameter).
    ///
    /// ```js
    /// params: [
    ///   '0xe8', // 232
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `QUANTITY` - integer of the number of transactions in this block.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getBlockTransactionCountByNumber","params":["0xe8"],"id":1}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": "0xa" // 10
    /// }
    /// ```
    func eth_getBlockTransactionCountByNumber(_ block: BlockNumber) -> Promise<BigUInt> {
        return network.send("eth_getBlockTransactionCountByNumber", block).uint256()
    }
    
    /// Returns the number of uncles in a block from a block matching the given block hash.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `DATA`, 32 Bytes - hash of a block.
    ///
    /// ```js
    /// params: [
    ///   '0xc94770007dda54cF92009BFF0dE90c06F603a09f'
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `QUANTITY` - integer of the number of uncles in this block.
    ///
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getUncleCountByBlockHash","params":["0xc94770007dda54cF92009BFF0dE90c06F603a09f"],"id":1}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": "0xc" // 1
    /// }
    /// ```
    func eth_getUncleCountByBlockHash(_ hash: Data) -> Promise<BigUInt> {
        return network.send("eth_getUncleCountByBlockHash", hash).uint256()
    }
    
    /// Returns the number of uncles in a block from a block matching the given block number.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `QUANTITY|TAG` - integer of a block number, or the string "latest", "earliest" or "pending", see the [default block parameter](#the-default-block-parameter).
    ///
    /// ```js
    /// params: [
    ///   '0xe8', // 232
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `QUANTITY` - integer of the number of uncles in this block.
    ///
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getUncleCountByBlockNumber","params":["0xe8"],"id":1}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": "0x1" // 1
    /// }
    /// ```
    func eth_getUncleCountByBlockNumber(_ block: BlockNumber) -> Promise<BigUInt> {
        return network.send("eth_getUncleCountByBlockNumber", block).uint256()
    }
    
    /// Returns code at a given address.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `DATA`, 20 Bytes - address.
    /// 2. `QUANTITY|TAG` - integer block number, or the string `"latest"`, `"earliest"` or `"pending"`, see the [default block parameter](#the-default-block-parameter).
    ///
    /// ```js
    /// params: [
    ///   '0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b',
    ///   '0x2'  // 2
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `DATA` - the code from the given address.
    ///
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getCode","params":["0xa94f5374fce5edbc8e2a8697c15331677e6ebf0b", "0x2"],"id":1}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": "0x600160008035811a818181146012578301005b601b6001356025565b8060005260206000f25b600060078202905091905056"
    /// }
    /// ```
    func eth_getCode(address: Address, block: BlockNumber) -> Promise<Data> {
        return network.send("eth_getCode", address, block).data()
    }
    
    /// The sign method calculates an Ethereum specific signature with: `sign(keccak256("\x19Ethereum Signed Message:\n" + len(message) + message)))`.
    ///
    /// By adding a prefix to the message makes the calculated signature recognisable as an Ethereum specific signature. This prevents misuse where a malicious DApp can sign arbitrary data (e.g. transaction) and use the signature to impersonate the victim.
    ///
    /// **Note** the address to sign with must be unlocked.
    ///
    /// ##### Parameters
    /// account, message
    ///
    /// 1. `DATA`, 20 Bytes - address.
    /// 2. `DATA`, N Bytes - message to sign.
    ///
    /// ##### Returns
    ///
    /// `DATA`: Signature
    ///
    /// ##### Example
    ///
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_sign","params":["0x9b2055d370f73ec7d8a03e965129118dc8f5bf83", "0xdeadbeaf"],"id":1}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": "0xa3f20717a250c2b0b729b7e5becbff67fdaef7e0699da4de7ca5895b02a170a12d887fd3b17bfdce3481f10bea41f45ba9f709d39ce8325427b57afcfc994cee1b"
    /// }
    /// ```
    ///
    /// An example how to use solidity ecrecover to verify the signature calculated with `eth_sign` can be found [here](https://gist.github.com/bas-vk/d46d83da2b2b4721efb0907aecdb7ebd). The contract is deployed on the testnet Ropsten and Rinkeby.
    func eth_sign(address: Address, data: Data) -> Promise<Data> {
        return network.send("eth_sign", address, data).data()
    }
    
    /// Creates new message call transaction or a contract creation, if the data field contains code.
    ///
    /// ##### Parameters
    ///
    /// 1. `Object` - The transaction object
    ///  - `from`: `DATA`, 20 Bytes - The address the transaction is send from.
    ///  - `to`: `DATA`, 20 Bytes - (optional when creating new contract) The address the transaction is directed to.
    ///  - `gas`: `QUANTITY`  - (optional, default: 90000) Integer of the gas provided for the transaction execution. It will return unused gas.
    ///  - `gasPrice`: `QUANTITY`  - (optional, default: To-Be-Determined) Integer of the gasPrice used for each paid gas
    ///  - `value`: `QUANTITY`  - (optional) Integer of the value sent with this transaction
    ///  - `data`: `DATA`  - The compiled code of a contract OR the hash of the invoked method signature and encoded parameters. For details see [Ethereum Contract ABI](https://github.com/ethereum/wiki/wiki/Ethereum-Contract-ABI)
    ///  - `nonce`: `QUANTITY`  - (optional) Integer of a nonce. This allows to overwrite your own pending transactions that use the same nonce.
    ///
    /// ```js
    /// params: [{
    ///  "from": "0xb60e8dd61c5d32be8058bb8eb970870f07233155",
    ///  "to": "0xd46e8dd67c5d32be8058bb8eb970870f07244567",
    ///  "gas": "0x76c0", // 30400
    ///  "gasPrice": "0x9184e72a000", // 10000000000000
    ///  "value": "0x9184e72a", // 2441406250
    ///  "data": "0xd46e8dd67c5d32be8d46e8dd67c5d32be8058bb8eb970870f072445675058bb8eb970870f072445675"
    /// }]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `DATA`, 32 Bytes - the transaction hash, or the zero hash if the transaction is not yet available.
    ///
    /// Use [eth_getTransactionReceipt](#eth_gettransactionreceipt) to get the contract address, after the transaction was mined, when you created a contract.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_sendTransaction","params":[{see above}],"id":1}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": "0xe670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331"
    /// }
    /// ```
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
    
    /// Creates new message call transaction or a contract creation for signed transactions.
    ///
    /// ##### Parameters
    ///
    /// 1. `DATA`, The signed transaction data.
    ///
    /// ```js
    /// params: ["0xd46e8dd67c5d32be8d46e8dd67c5d32be8058bb8eb970870f072445675058bb8eb970870f072445675"]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `DATA`, 32 Bytes - the transaction hash, or the zero hash if the transaction is not yet available.
    ///
    /// Use [eth_getTransactionReceipt](#eth_gettransactionreceipt) to get the contract address, after the transaction was mined, when you created a contract.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_sendRawTransaction","params":[{see above}],"id":1}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": "0xe670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331"
    /// }
    /// ```
    func eth_sendRawTransaction(data: Data) -> Promise<Data> {
        return network.send("eth_sendRawTransaction", data).data()
    }
    
    /// Executes a new message call immediately without creating a transaction on the block chain.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `Object` - The transaction call object
    ///  - `from`: `DATA`, 20 Bytes - (optional) The address the transaction is sent from.
    ///  - `to`: `DATA`, 20 Bytes  - The address the transaction is directed to.
    ///  - `gas`: `QUANTITY`  - (optional) Integer of the gas provided for the transaction execution. eth_call consumes zero gas, but this parameter may be needed by some executions.
    ///  - `gasPrice`: `QUANTITY`  - (optional) Integer of the gasPrice used for each paid gas
    ///  - `value`: `QUANTITY`  - (optional) Integer of the value sent with this transaction
    ///  - `data`: `DATA`  - (optional) Hash of the method signature and encoded parameters. For details see [Ethereum Contract ABI](https://github.com/ethereum/wiki/wiki/Ethereum-Contract-ABI)
    /// 2. `QUANTITY|TAG` - integer block number, or the string `"latest"`, `"earliest"` or `"pending"`, see the [default block parameter](#the-default-block-parameter)
    ///
    /// ##### Returns
    ///
    /// `DATA` - the return value of executed contract.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_call","params":[{see above}],"id":1}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": "0x"
    /// }
    /// ```
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
    
    /// Generates and returns an estimate of how much gas is necessary to allow the transaction to complete. The transaction will not be added to the blockchain. Note that the estimate may be significantly more than the amount of gas actually used by the transaction, for a variety of reasons including EVM mechanics and node performance.
    ///
    /// ##### Parameters
    ///
    /// See [eth_call](#eth_call) parameters, expect that all properties are optional. If no gas limit is specified geth uses the block gas limit from the pending block as an upper bound. As a result the returned estimate might not be enough to executed the call/transaction when the amount of gas is higher than the pending block gas limit.
    ///
    /// ##### Returns
    ///
    /// `QUANTITY` - the amount of gas used.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_estimateGas","params":[{see above}],"id":1}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": "0x5208" // 21000
    /// }
    /// ```
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
    
    /// Returns information about a block by hash.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `DATA`, 32 Bytes - Hash of a block.
    /// 2. `Boolean` - If `true` it returns the full transaction objects, if `false` only the hashes of the transactions.
    ///
    /// ```js
    /// params: [
    ///   '0xe670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331',
    ///   true
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `Object` - A block object, or `null` when no block was found:
    ///
    ///  - `number`: `QUANTITY` - the block number. `null` when its pending block.
    ///  - `hash`: `DATA`, 32 Bytes - hash of the block. `null` when its pending block.
    ///  - `parentHash`: `DATA`, 32 Bytes - hash of the parent block.
    ///  - `nonce`: `DATA`, 8 Bytes - hash of the generated proof-of-work. `null` when its pending block.
    ///  - `sha3Uncles`: `DATA`, 32 Bytes - SHA3 of the uncles data in the block.
    ///  - `logsBloom`: `DATA`, 256 Bytes - the bloom filter for the logs of the block. `null` when its pending block.
    ///  - `transactionsRoot`: `DATA`, 32 Bytes - the root of the transaction trie of the block.
    ///  - `stateRoot`: `DATA`, 32 Bytes - the root of the final state trie of the block.
    ///  - `receiptsRoot`: `DATA`, 32 Bytes - the root of the receipts trie of the block.
    ///  - `miner`: `DATA`, 20 Bytes - the address of the beneficiary to whom the mining rewards were given.
    ///  - `difficulty`: `QUANTITY` - integer of the difficulty for this block.
    ///  - `totalDifficulty`: `QUANTITY` - integer of the total difficulty of the chain until this block.
    ///  - `extraData`: `DATA` - the "extra data" field of this block.
    ///  - `size`: `QUANTITY` - integer the size of this block in bytes.
    ///  - `gasLimit`: `QUANTITY` - the maximum gas allowed in this block.
    ///  - `gasUsed`: `QUANTITY` - the total used gas by all transactions in this block.
    ///  - `timestamp`: `QUANTITY` - the unix timestamp for when the block was collated.
    ///  - `transactions`: `Array` - Array of transaction objects, or 32 Bytes transaction hashes depending on the last given parameter.
    ///  - `uncles`: `Array` - Array of uncle hashes.
    ///
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getBlockByHash","params":["0xe670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331", true],"id":1}'
    ///
    /// // Result
    /// {
    /// "id":1,
    /// "jsonrpc":"2.0",
    /// "result": {
    ///    "number": "0x1b4", // 436
    ///    "hash": "0xe670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331",
    ///    "parentHash": "0x9646252be9520f6e71339a8df9c55e4d7619deeb018d2a3f2d21fc165dde5eb5",
    ///    "nonce": "0xe04d296d2460cfb8472af2c5fd05b5a214109c25688d3704aed5484f9a7792f2",
    ///    "sha3Uncles": "0x1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347",
    ///    "logsBloom": "0xe670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331",
    ///    "transactionsRoot": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
    ///    "stateRoot": "0xd5855eb08b3387c0af375e9cdb6acfc05eb8f519e419b874b6ff2ffda7ed1dff",
    ///    "miner": "0x4e65fda2159562a496f9f3522f89122a3088497a",
    ///    "difficulty": "0x027f07", // 163591
    ///    "totalDifficulty":  "0x027f07", // 163591
    ///    "extraData": "0x0000000000000000000000000000000000000000000000000000000000000000",
    ///    "size":  "0x027f07", // 163591
    ///    "gasLimit": "0x9f759", // 653145
    ///    "gasUsed": "0x9f759", // 653145
    ///    "timestamp": "0x54e34e8e" // 1424182926
    ///    "transactions": [{...},{ ... }]
    ///    "uncles": ["0x1606e5...", "0xd5145a9..."]
    ///  }
    /// }
    /// ```
    
    func eth_getBlockByHash(_ hash: Data, _ fullInformation: Bool) -> Promise<BlockInfo?> {
        return network.send("eth_getBlockByHash", hash, fullInformation).block()
    }
    
    /// Returns information about a block by block number.
    ///
    /// ##### Parameters
    ///
    /// 1. `QUANTITY|TAG` - integer of a block number, or the string `"earliest"`, `"latest"` or `"pending"`, as in the [default block parameter](#the-default-block-parameter).
    /// 2. `Boolean` - If `true` it returns the full transaction objects, if `false` only the hashes of the transactions.
    ///
    /// ```js
    /// params: [
    ///   '0x1b4', // 436
    ///   true
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// See [eth_getBlockByHash](#eth_getblockbyhash)
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["0x1b4", true],"id":1}'
    /// ```
    ///
    /// Result see [eth_getBlockByHash](#eth_getblockbyhash)
    func eth_getBlockByNumber(_ number: BigUInt, _ fullInformation: Bool) -> Promise<BlockInfo?> {
        return network.send("eth_getBlockByNumber", number, fullInformation).block()
    }
    
    /// Returns the information about a transaction requested by transaction hash.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `DATA`, 32 Bytes - hash of a transaction
    ///
    /// ```js
    /// params: [
    ///   "0x88df016429689c079f3b2f6ad39fa052532c56795b733da78a91ebe6a713944b"
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `Object` - A transaction object, or `null` when no transaction was found:
    ///
    ///  - `blockHash`: `DATA`, 32 Bytes - hash of the block where this transaction was in. `null` when its pending.
    ///  - `blockNumber`: `QUANTITY` - block number where this transaction was in. `null` when its pending.
    ///  - `from`: `DATA`, 20 Bytes - address of the sender.
    ///  - `gas`: `QUANTITY` - gas provided by the sender.
    ///  - `gasPrice`: `QUANTITY` - gas price provided by the sender in Wei.
    ///  - `hash`: `DATA`, 32 Bytes - hash of the transaction.
    ///  - `input`: `DATA` - the data send along with the transaction.
    ///  - `nonce`: `QUANTITY` - the number of transactions made by the sender prior to this one.
    ///  - `to`: `DATA`, 20 Bytes - address of the receiver. `null` when its a contract creation transaction.
    ///  - `transactionIndex`: `QUANTITY` - integer of the transaction's index position in the block. `null` when its pending.
    ///  - `value`: `QUANTITY` - value transferred in Wei.
    ///  - `v`: `QUANTITY` - ECDSA recovery id
    ///  - `r`: `DATA`, 32 Bytes - ECDSA signature r
    ///  - `s`: `DATA`, 32 Bytes - ECDSA signature s
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getTransactionByHash","params":["0x88df016429689c079f3b2f6ad39fa052532c56795b733da78a91ebe6a713944b"],"id":1}'
    ///
    /// // Result
    /// {
    ///  "jsonrpc":"2.0",
    ///  "id":1,
    ///  "result":{
    ///    "blockHash":"0x1d59ff54b1eb26b013ce3cb5fc9dab3705b415a67127a003c3e61eb445bb8df2",
    ///    "blockNumber":"0x5daf3b", // 6139707
    ///    "from":"0xa7d9ddbe1f17865597fbd27ec712455208b6b76d",
    ///    "gas":"0xc350", // 50000
    ///    "gasPrice":"0x4a817c800", // 20000000000
    ///    "hash":"0x88df016429689c079f3b2f6ad39fa052532c56795b733da78a91ebe6a713944b",
    ///    "input":"0x68656c6c6f21",
    ///    "nonce":"0x15", // 21
    ///    "to":"0xf02c1c8e6114b1dbe8937a39260b5b0a374432bb",
    ///    "transactionIndex":"0x41", // 65
    ///    "value":"0xf3dbb76162000", // 4290000000000000
    ///    "v":"0x25", // 37
    ///    "r":"0x1b5e176d927f8e9ab405058b2d2457392da3e20f328b16ddabcebc33eaac5fea",
    ///    "s":"0x4ba69724e8f69de52f0125ad8b3c5c2cef33019bac3249e2c0a2192766d1721c"
    ///  }
    /// }
    /// ```
    func eth_getTransactionByHash(_ hash: Data) -> Promise<TransactionInfo?> {
        return network.send("eth_getTransactionByHash", hash).transaction()
    }
    
    /// Returns information about a transaction by block hash and transaction index position.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `DATA`, 32 Bytes - hash of a block.
    /// 2. `QUANTITY` - integer of the transaction index position.
    ///
    /// ```js
    /// params: [
    ///   '0xe670ec64341771606e55d6b4ca35a1a6b75ee3d5145a99d05921026d1527331',
    ///   '0x0' // 0
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// See [eth_getTransactionByHash](#eth_gettransactionbyhash)
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getTransactionByBlockHashAndIndex","params":["0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b", "0x0"],"id":1}'
    /// ```
    ///
    /// Result see [eth_getTransactionByHash](#eth_gettransactionbyhash)
    func eth_getTransactionByBlockHashAndIndex(_ blockHash: Data, _ index: BigUInt) -> Promise<TransactionInfo?> {
        return network.send("eth_getTransactionByBlockHashAndIndex", blockHash, index).transaction()
    }
    
    /// Returns information about a transaction by block number and transaction index position.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `QUANTITY|TAG` - a block number, or the string `"earliest"`, `"latest"` or `"pending"`, as in the [default block parameter](#the-default-block-parameter).
    /// 2. `QUANTITY` - the transaction index position.
    ///
    /// ```js
    /// params: [
    ///   '0x29c', // 668
    ///   '0x0' // 0
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// See [eth_getTransactionByHash](#eth_gettransactionbyhash)
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getTransactionByBlockNumberAndIndex","params":["0x29c", "0x0"],"id":1}'
    /// ```
    ///
    /// Result see [eth_getTransactionByHash](#eth_gettransactionbyhash)
    func eth_getTransactionByBlockNumberAndIndex(_ number: BlockNumber, _ index: BigUInt) -> Promise<TransactionInfo?> {
        return network.send("eth_getTransactionByBlockNumberAndIndex", number, index).transaction()
    }
    
    /// Returns the receipt of a transaction by transaction hash.
    ///
    /// **Note** That the receipt is not available for pending transactions.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `DATA`, 32 Bytes - hash of a transaction
    ///
    /// ```js
    /// params: [
    ///   '0xb903239f8543d04b5dc1ba6579132b143087c68db1b2168786408fcbce568238'
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `Object` - A transaction receipt object, or `null` when no receipt was found:
    ///
    ///  - `transactionHash `: `DATA`, 32 Bytes - hash of the transaction.
    ///  - `transactionIndex`: `QUANTITY` - integer of the transaction's index position in the block.
    ///  - `blockHash`: `DATA`, 32 Bytes - hash of the block where this transaction was in.
    ///  - `blockNumber`: `QUANTITY` - block number where this transaction was in.
    ///  - `from`: `DATA`, 20 Bytes - address of the sender.
    ///  - `to`: `DATA`, 20 Bytes - address of the receiver. null when it's a contract creation transaction.
    ///  - `cumulativeGasUsed `: `QUANTITY ` - The total amount of gas used when this transaction was executed in the block.
    ///  - `gasUsed `: `QUANTITY ` - The amount of gas used by this specific transaction alone.
    ///  - `contractAddress `: `DATA`, 20 Bytes - The contract address created, if the transaction was a contract creation, otherwise `null`.
    ///  - `logs`: `Array` - Array of log objects, which this transaction generated.
    ///  - `logsBloom`: `DATA`, 256 Bytes - Bloom filter for light clients to quickly retrieve related logs.
    ///
    /// It also returns _either_ :
    ///
    ///  - `root` : `DATA` 32 bytes of post-transaction stateroot (pre Byzantium)
    ///  - `status`: `QUANTITY` either `1` (success) or `0` (failure)
    ///
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getTransactionReceipt","params":["0xb903239f8543d04b5dc1ba6579132b143087c68db1b2168786408fcbce568238"],"id":1}'
    ///
    /// // Result
    /// {
    /// "id":1,
    /// "jsonrpc":"2.0",
    /// "result": {
    ///     transactionHash: '0xb903239f8543d04b5dc1ba6579132b143087c68db1b2168786408fcbce568238',
    ///     transactionIndex:  '0x1', // 1
    ///     blockNumber: '0xb', // 11
    ///     blockHash: '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b',
    ///     cumulativeGasUsed: '0x33bc', // 13244
    ///     gasUsed: '0x4dc', // 1244
    ///     contractAddress: '0xb60e8dd61c5d32be8058bb8eb970870f07233155', // or null, if none was created
    ///     logs: [{
    ///         // logs as returned by getFilterLogs, etc.
    ///     }, ...],
    ///     logsBloom: "0x00...0", // 256 byte bloom filter
    ///     status: '0x1'
    ///  }
    /// }
    /// ```
    func eth_getTransactionReceipt(_ hash: Data) -> Promise<TransactionReceiptInfo?> {
        return network.send("eth_getTransactionReceipt", hash).transactionReceipt()
    }
    
    /// Returns information about a uncle of a block by hash and uncle index position.
    ///
    ///
    /// ##### Parameters
    ///
    ///
    /// 1. `DATA`, 32 Bytes - hash a block.
    /// 2. `QUANTITY` - the uncle's index position.
    ///
    /// ```js
    /// params: [
    ///   '0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b',
    ///   '0x0' // 0
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// See [eth_getBlockByHash](#eth_getblockbyhash)
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getUncleByBlockHashAndIndex","params":["0xc6ef2fc5426d6ad6fd9e2a26abeab0aa2411b7ab17f30a99d3cb96aed1d1055b", "0x0"],"id":1}'
    /// ```
    ///
    /// Result see [eth_getBlockByHash](#eth_getblockbyhash)
    ///
    /// **Note**: An uncle doesn't contain individual transactions.
    func eth_getUncleByBlockHashAndIndex(_ hash: Data, _ index: BigUInt) -> Promise<BlockInfo?> {
        return network.send("eth_getUncleByBlockHashAndIndex", hash, index).block()
    }
    
    /// Returns information about a uncle of a block by number and uncle index position.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `QUANTITY|TAG` - a block number, or the string `"earliest"`, `"latest"` or `"pending"`, as in the [default block parameter](#the-default-block-parameter).
    /// 2. `QUANTITY` - the uncle's index position.
    ///
    /// ```js
    /// params: [
    ///   '0x29c', // 668
    ///   '0x0' // 0
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// See [eth_getBlockByHash](#eth_getblockbyhash)
    ///
    /// **Note**: An uncle doesn't contain individual transactions.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getUncleByBlockNumberAndIndex","params":["0x29c", "0x0"],"id":1}'
    /// ```
    ///
    /// Result see [eth_getBlockByHash](#eth_getblockbyhash)
    func eth_getUncleByBlockNumberAndIndex(_ number: BigUInt, _ index: BigUInt) -> Promise<BlockInfo?> {
        return network.send("eth_getUncleByBlockNumberAndIndex", number, index).block()
    }
    
    /// Creates a filter object, based on filter options, to notify when the state changes (logs).
    /// To check if the state has changed, call [eth_getFilterChanges](#eth_getfilterchanges).
    ///
    /// ##### A note on specifying topic filters:
    /// Topics are order-dependent. A transaction with a log with topics [A, B] will be matched by the following topic filters:
    /// * `[]` "anything"
    /// * `[A]` "A in first position (and anything after)"
    /// * `[null, B]` "anything in first position AND B in second position (and anything after)"
    /// * `[A, B]` "A in first position AND B in second position (and anything after)"
    /// * `[[A, B], [A, B]]` "(A OR B) in first position AND (A OR B) in second position (and anything after)"
    ///
    /// ##### Parameters
    ///
    /// 1. `Object` - The filter options:
    ///  - `fromBlock`: `QUANTITY|TAG` - (optional, default: `"latest"`) Integer block number, or `"latest"` for the last mined block or `"pending"`, `"earliest"` for not yet mined transactions.
    ///  - `toBlock`: `QUANTITY|TAG` - (optional, default: `"latest"`) Integer block number, or `"latest"` for the last mined block or `"pending"`, `"earliest"` for not yet mined transactions.
    ///  - `address`: `DATA|Array`, 20 Bytes - (optional) Contract address or a list of addresses from which logs should originate.
    ///  - `topics`: `Array of DATA`,  - (optional) Array of 32 Bytes `DATA` topics. Topics are order-dependent. Each topic can also be an array of DATA with "or" options.
    ///
    /// ```js
    /// params: [{
    ///  "fromBlock": "0x1",
    ///  "toBlock": "0x2",
    ///  "address": "0x8888f1f195afa192cfee860698584c030f4c9db1",
    ///  "topics": ["0x000000000000000000000000a94f5374fce5edbc8e2a8697c15331677e6ebf0b", null, ["0x000000000000000000000000a94f5374fce5edbc8e2a8697c15331677e6ebf0b", "0x0000000000000000000000000aff3454fce5edbc8cca8697c15331677e6ebccc"]]
    /// }]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `QUANTITY` - A filter id.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_newFilter","params":[{"topics":["0x0000000000000000000000000000000000000000000000000000000012341234"]}],"id":73}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": "0x1" // 1
    /// }
    /// ```
    func eth_newFilter(_ options: [FilterOptions]) -> Promise<BigUInt> {
        return network.send("eth_newFilter", JArray(options)).uint256()
    }
    
    /// Creates a filter in the node, to notify when a new block arrives.
    /// To check if the state has changed, call [eth_getFilterChanges](#eth_getfilterchanges).
    ///
    /// ##### Parameters
    /// None
    ///
    /// ##### Returns
    ///
    /// `QUANTITY` - A filter id.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_newBlockFilter","params":[],"id":73}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc":  "2.0",
    ///  "result": "0x1" // 1
    /// }
    /// ```
    func eth_newBlockFilter() -> Promise<BigUInt> {
        return network.send("eth_newBlockFilter").uint256()
    }
    
    /// Creates a filter in the node, to notify when a new block arrives.
    /// To check if the state has changed, call [eth_getFilterChanges](#eth_getfilterchanges).
    ///
    /// ##### Parameters
    /// None
    ///
    /// ##### Returns
    ///
    /// `QUANTITY` - A filter id.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_newBlockFilter","params":[],"id":73}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc":  "2.0",
    ///  "result": "0x1" // 1
    /// }
    /// ```
    func eth_newPendingTransactionFilter() -> Promise<BigUInt> {
        return network.send("eth_newPendingTransactionFilter").uint256()
    }
    
    /// Uninstalls a filter with given id. Should always be called when watch is no longer needed.
    /// Additonally Filters timeout when they aren't requested with [eth_getFilterChanges](#eth_getfilterchanges) for a period of time.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `QUANTITY` - The filter id.
    ///
    /// ```js
    /// params: [
    ///  "0xb" // 11
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `Boolean` - `true` if the filter was successfully uninstalled, otherwise `false`.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_uninstallFilter","params":["0xb"],"id":73}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": true
    /// }
    /// ```
    func eth_uninstallFilter(_ id: BigUInt) -> Promise<Bool> {
        return network.send("eth_uninstallFilter", id).bool()
    }
    
    /// Polling method for a filter, which returns an array of logs which occurred since last poll.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `QUANTITY` - the filter id.
    ///
    /// ```js
    /// params: [
    ///  "0x16" // 22
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `Array` - Array of log objects, or an empty array if nothing has changed since last poll.
    ///
    /// - For filters created with `eth_newBlockFilter` the return are block hashes (`DATA`, 32 Bytes), e.g. `["0x3454645634534..."]`.
    /// - For filters created with `eth_newPendingTransactionFilter ` the return are transaction hashes (`DATA`, 32 Bytes), e.g. `["0x6345343454645..."]`.
    /// - For filters created with `eth_newFilter` logs are objects with following params:
    ///
    ///  - `removed`: `TAG` - `true` when the log was removed, due to a chain reorganization. `false` if its a valid log.
    ///  - `logIndex`: `QUANTITY` - integer of the log index position in the block. `null` when its pending log.
    ///  - `transactionIndex`: `QUANTITY` - integer of the transactions index position log was created from. `null` when its pending log.
    ///  - `transactionHash`: `DATA`, 32 Bytes - hash of the transactions this log was created from. `null` when its pending log.
    ///  - `blockHash`: `DATA`, 32 Bytes - hash of the block where this log was in. `null` when its pending. `null` when its pending log.
    ///  - `blockNumber`: `QUANTITY` - the block number where this log was in. `null` when its pending. `null` when its pending log.
    ///  - `address`: `DATA`, 20 Bytes - address from which this log originated.
    ///  - `data`: `DATA` - contains the non-indexed arguments of the log.
    ///  - `topics`: `Array of DATA` - Array of 0 to 4 32 Bytes `DATA` of indexed log arguments. (In *solidity*: The first topic is the *hash* of the signature of the event (e.g. `Deposit(address,bytes32,uint256)`), except you declared the event with the `anonymous` specifier.)
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getFilterChanges","params":["0x16"],"id":73}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc":"2.0",
    ///  "result": [{
    ///    "logIndex": "0x1", // 1
    ///    "blockNumber":"0x1b4", // 436
    ///    "blockHash": "0x8216c5785ac562ff41e2dcfdf5785ac562ff41e2dcfdf829c5a142f1fccd7d",
    ///    "transactionHash":  "0xdf829c5a142f1fccd7d8216c5785ac562ff41e2dcfdf5785ac562ff41e2dcf",
    ///    "transactionIndex": "0x0", // 0
    ///    "address": "0x16c5785ac562ff41e2dcfdf829c5a142f1fccd7d",
    ///    "data":"0x0000000000000000000000000000000000000000000000000000000000000000",
    ///    "topics": ["0x59ebeb90bc63057b6515673c3ecf9438e5058bca0f92585014eced636878c9a5"]
    ///    },{
    ///      ...
    ///    }]
    /// }
    /// ```
    func eth_getFilterChanges(_ id: BigUInt) -> Promise<FilterChanges> {
        return network.send("eth_getFilterChanges", id).filterChanges()
    }
    
    /// Returns an array of all logs matching filter with given id.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `QUANTITY` - The filter id.
    ///
    /// ```js
    /// params: [
    ///  "0x16" // 22
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// See [eth_getFilterChanges](#eth_getfilterchanges)
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getFilterLogs","params":["0x16"],"id":74}'
    /// ```
    ///
    /// Result see [eth_getFilterChanges](#eth_getfilterchanges)
    func eth_getFilterLogs(_ id: BigUInt) -> Promise<FilterChanges> {
        return network.send("eth_getFilterLogs", id).filterChanges()
    }
    
    /// Returns an array of all logs matching a given filter object.
    ///
    /// ##### Parameters
    ///
    /// 1. `Object` - The filter options:
    ///  - `fromBlock`: `QUANTITY|TAG` - (optional, default: `"latest"`) Integer block number, or `"latest"` for the last mined block or `"pending"`, `"earliest"` for not yet mined transactions.
    ///  - `toBlock`: `QUANTITY|TAG` - (optional, default: `"latest"`) Integer block number, or `"latest"` for the last mined block or `"pending"`, `"earliest"` for not yet mined transactions.
    ///  - `address`: `DATA|Array`, 20 Bytes - (optional) Contract address or a list of addresses from which logs should originate.
    ///  - `topics`: `Array of DATA`,  - (optional) Array of 32 Bytes `DATA` topics. Topics are order-dependent. Each topic can also be an array of DATA with "or" options.
    ///  - `blockhash`:  `DATA`, 32 Bytes - (optional) With the addition of EIP-234 (Geth >= v1.8.13 or Parity >= v2.1.0), `blockHash` is a new filter option which restricts the logs returned to the single block with the 32-byte hash `blockHash`.  Using `blockHash` is equivalent to `fromBlock` = `toBlock` = the block number with hash `blockHash`.  If `blockHash` is present in the filter criteria, then neither `fromBlock` nor `toBlock` are allowed.
    ///
    /// ```js
    /// params: [{
    ///  "topics": ["0x000000000000000000000000a94f5374fce5edbc8e2a8697c15331677e6ebf0b"]
    /// }]
    /// ```
    ///
    /// ##### Returns
    ///
    /// See [eth_getFilterChanges](#eth_getfilterchanges)
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getLogs","params":[{"topics":["0x000000000000000000000000a94f5374fce5edbc8e2a8697c15331677e6ebf0b"]}],"id":74}'
    /// ```
    ///
    /// Result see [eth_getFilterChanges](#eth_getfilterchanges)
    func eth_getLogs(_ logs: [FilterLogOptions]) -> Promise<FilterChanges> {
        return network.send("eth_getLogs", JArray(logs)).filterChanges()
    }
    
    /// Returns the hash of the current block, the seedHash, and the boundary condition to be met ("target").
    ///
    /// ##### Parameters
    /// none
    ///
    /// ##### Returns
    ///
    /// `Array` - Array with the following properties:
    ///  1. `DATA`, 32 Bytes - current block header pow-hash
    ///  2. `DATA`, 32 Bytes - the seed hash used for the DAG.
    ///  3. `DATA`, 32 Bytes - the boundary condition ("target"), 2^256 / difficulty.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getWork","params":[],"id":73}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc":"2.0",
    ///  "result": [
    ///      "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
    ///      "0x5EED00000000000000000000000000005EED0000000000000000000000000000",
    ///      "0xd1ff1c01710000000000000000000000d1ff1c01710000000000000000000000"
    ///    ]
    /// }
    /// ```
    func eth_getWork() -> Promise<WorkInfo> {
        return network.send("eth_getWork").work()
    }
    
    /// Used for submitting a proof-of-work solution.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `DATA`, 8 Bytes - The nonce found (64 bits)
    /// 2. `DATA`, 32 Bytes - The header's pow-hash (256 bits)
    /// 3. `DATA`, 32 Bytes - The mix digest (256 bits)
    ///
    /// ```js
    /// params: [
    ///  "0x0000000000000001",
    ///  "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef",
    ///  "0xD1FE5700000000000000000000000000D1FE5700000000000000000000000000"
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `Boolean` - returns `true` if the provided solution is valid, otherwise `false`.
    ///
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0", "method":"eth_submitWork", "params":["0x0000000000000001", "0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef", "0xD1GE5700000000000000000000000000D1GE5700000000000000000000000000"],"id":73}'
    ///
    /// // Result
    /// {
    ///  "id":73,
    ///  "jsonrpc":"2.0",
    ///  "result": true
    /// }
    /// ```
    func eth_submitWork(nonce: UInt64, headerPowHash: Data, mixDigest: Data) -> Promise<Bool> {
        return network.send("eth_submitWork", BigUInt(nonce), headerPowHash, mixDigest).bool()
    }
    
    /// Used for submitting mining hashrate.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `Hashrate`, a hexadecimal string representation (32 bytes) of the hash rate
    /// 2. `ID`, String - A random hexadecimal(32 bytes) ID identifying the client
    ///
    /// ```js
    /// params: [
    ///  "0x0000000000000000000000000000000000000000000000000000000000500000",
    ///  "0x59daa26581d0acd1fce254fb7e85952f4c09d0915afd33d3886cd914bc7d283c"
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `Boolean` - returns `true` if submitting went through succesfully and `false` otherwise.
    ///
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0", "method":"eth_submitHashrate", "params":["0x0000000000000000000000000000000000000000000000000000000000500000", "0x59daa26581d0acd1fce254fb7e85952f4c09d0915afd33d3886cd914bc7d283c"],"id":73}'
    ///
    /// // Result
    /// {
    ///  "id":73,
    ///  "jsonrpc":"2.0",
    ///  "result": true
    /// }
    /// ```
    func eth_submitHashrate(hashRate: Data, id: Data) -> Promise<Bool> {
        return network.send("eth_submitHashrate", hashRate, id).bool()
    }
    
    /// Returns the account- and storage-values of the specified account including the Merkle-proof.
    ///
    /// ##### getProof-Parameters
    ///
    /// 1. `DATA`, 20 bytes - address of the account or contract
    /// 2. `ARRAY`, 32 Bytes - array of storage-keys which should be proofed and included. See eth_getStorageAt
    /// 3. `QUANTITY|TAG` - integer block number, or the string "latest" or "earliest", see the default block parameter
    ///
    ///
    /// ```
    /// params: ["0x1234567890123456789012345678901234567890",["0x0000000000000000000000000000000000000000000000000000000000000000","0x0000000000000000000000000000000000000000000000000000000000000001"],"latest"]
    /// ```
    ///
    /// ##### getProof-Returns
    ///
    /// Returns
    /// `Object` - A account object:
    ///
    /// `balance`: `QUANTITY` - the balance of the account. See eth_getBalance
    ///
    /// `codeHash`: `DATA`, 32 Bytes - hash of the code of the account. For a simple Account without code it will return "0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470"
    ///
    /// `nonce`: `QUANTITY`, - nonce of the account. See eth_getTransactionCount
    ///
    /// `storageHash`: `DATA`, 32 Bytes - SHA3 of the StorageRoot. All storage will deliver a MerkleProof starting with this rootHash.
    ///
    /// `accountProof`: `ARRAY` - Array of rlp-serialized MerkleTree-Nodes, starting with the stateRoot-Node, following the path of the SHA3 (address) as key.
    ///
    /// `storageProof`: `ARRAY` - Array of storage-entries as requested. Each entry is a object with these properties:
    ///
    /// `key`: `QUANTITY` - the requested storage key
    /// `value`: `QUANTITY` - the storage value
    /// `proof`: `ARRAY` - Array of rlp-serialized MerkleTree-Nodes, starting with the storageHash-Node, following the path of the SHA3 (key) as path.
    ///
    /// ##### getProof-Example
    /// ```
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getProof","params":["0x1234567890123456789012345678901234567890",["0x0000000000000000000000000000000000000000000000000000000000000000","0x0000000000000000000000000000000000000000000000000000000000000001"],"latest"],"id":1}' -H "Content-type:application/json" http://localhost:8545
    ///
    /// // Result
    /// {
    ///  "jsonrpc": "2.0",
    ///  "id": 1,
    ///  "result": {
    ///    "address": "0x1234567890123456789012345678901234567890",
    ///    "accountProof": [
    ///      "0xf90211a090dcaf88c40c7bbc95a912cbdde67c175767b31173df9ee4b0d733bfdd511c43a0babe369f6b12092f49181ae04ca173fb68d1a5456f18d20fa32cba73954052bda0473ecf8a7e36a829e75039a3b055e51b8332cbf03324ab4af2066bbd6fbf0021a0bbda34753d7aa6c38e603f360244e8f59611921d9e1f128372fec0d586d4f9e0a04e44caecff45c9891f74f6a2156735886eedf6f1a733628ebc802ec79d844648a0a5f3f2f7542148c973977c8a1e154c4300fec92f755f7846f1b734d3ab1d90e7a0e823850f50bf72baae9d1733a36a444ab65d0a6faaba404f0583ce0ca4dad92da0f7a00cbe7d4b30b11faea3ae61b7f1f2b315b61d9f6bd68bfe587ad0eeceb721a07117ef9fc932f1a88e908eaead8565c19b5645dc9e5b1b6e841c5edbdfd71681a069eb2de283f32c11f859d7bcf93da23990d3e662935ed4d6b39ce3673ec84472a0203d26456312bbc4da5cd293b75b840fc5045e493d6f904d180823ec22bfed8ea09287b5c21f2254af4e64fca76acc5cd87399c7f1ede818db4326c98ce2dc2208a06fc2d754e304c48ce6a517753c62b1a9c1d5925b89707486d7fc08919e0a94eca07b1c54f15e299bd58bdfef9741538c7828b5d7d11a489f9c20d052b3471df475a051f9dd3739a927c89e357580a4c97b40234aa01ed3d5e0390dc982a7975880a0a089d613f26159af43616fd9455bb461f4869bfede26f2130835ed067a8b967bfb80",
    ///      "0xf90211a0395d87a95873cd98c21cf1df9421af03f7247880a2554e20738eec2c7507a494a0bcf6546339a1e7e14eb8fb572a968d217d2a0d1f3bc4257b22ef5333e9e4433ca012ae12498af8b2752c99efce07f3feef8ec910493be749acd63822c3558e6671a0dbf51303afdc36fc0c2d68a9bb05dab4f4917e7531e4a37ab0a153472d1b86e2a0ae90b50f067d9a2244e3d975233c0a0558c39ee152969f6678790abf773a9621a01d65cd682cc1be7c5e38d8da5c942e0a73eeaef10f387340a40a106699d494c3a06163b53d956c55544390c13634ea9aa75309f4fd866f312586942daf0f60fb37a058a52c1e858b1382a8893eb9c1f111f266eb9e21e6137aff0dddea243a567000a037b4b100761e02de63ea5f1fcfcf43e81a372dafb4419d126342136d329b7a7ba032472415864b08f808ba4374092003c8d7c40a9f7f9fe9cc8291f62538e1cc14a074e238ff5ec96b810364515551344100138916594d6af966170ff326a092fab0a0d31ac4eef14a79845200a496662e92186ca8b55e29ed0f9f59dbc6b521b116fea090607784fe738458b63c1942bba7c0321ae77e18df4961b2bc66727ea996464ea078f757653c1b63f72aff3dcc3f2a2e4c8cb4a9d36d1117c742833c84e20de994a0f78407de07f4b4cb4f899dfb95eedeb4049aeb5fc1635d65cf2f2f4dfd25d1d7a0862037513ba9d45354dd3e36264aceb2b862ac79d2050f14c95657e43a51b85c80",
    ///      "0xf90171a04ad705ea7bf04339fa36b124fa221379bd5a38ffe9a6112cb2d94be3a437b879a08e45b5f72e8149c01efcb71429841d6a8879d4bbe27335604a5bff8dfdf85dcea00313d9b2f7c03733d6549ea3b810e5262ed844ea12f70993d87d3e0f04e3979ea0b59e3cdd6750fa8b15164612a5cb6567cdfb386d4e0137fccee5f35ab55d0efda0fe6db56e42f2057a071c980a778d9a0b61038f269dd74a0e90155b3f40f14364a08538587f2378a0849f9608942cf481da4120c360f8391bbcc225d811823c6432a026eac94e755534e16f9552e73025d6d9c30d1d7682a4cb5bd7741ddabfd48c50a041557da9a74ca68da793e743e81e2029b2835e1cc16e9e25bd0c1e89d4ccad6980a041dda0a40a21ade3a20fcd1a4abb2a42b74e9a32b02424ff8db4ea708a5e0fb9a09aaf8326a51f613607a8685f57458329b41e938bb761131a5747e066b81a0a16808080a022e6cef138e16d2272ef58434ddf49260dc1de1f8ad6dfca3da5d2a92aaaadc58080",
    ///      "0xf851808080a009833150c367df138f1538689984b8a84fc55692d3d41fe4d1e5720ff5483a6980808080808080808080a0a319c1c415b271afc0adcb664e67738d103ac168e0bc0b7bd2da7966165cb9518080"
    ///    ],
    ///    "balance": "0x0",
    ///    "codeHash": "0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470",
    ///    "nonce": "0x0",
    ///    "storageHash": "0x56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421",
    ///    "storageProof": [
    ///      {
    ///        "key": "0x0000000000000000000000000000000000000000000000000000000000000000",
    ///        "value": "0x0",
    ///        "proof": []
    ///      },
    ///      {
    ///        "key": "0x0000000000000000000000000000000000000000000000000000000000000001",
    ///        "value": "0x0",
    ///        "proof": []
    ///      }
    
    ///    ]
    ///  }
    /// }
    /// ```
    func eth_getProof(address: Address, keys: [Data], block: BlockNumber) -> Promise<ProofInfo> {
        return network.send("eth_getProof", address, JArray(keys), block).proof()
    }
    
    /// Returns the current whisper protocol version.
    ///
    /// ##### Parameters
    /// none
    ///
    /// ##### Returns
    ///
    /// `String` - The current whisper protocol version
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"shh_version","params":[],"id":67}'
    ///
    /// // Result
    /// {
    ///  "id":67,
    ///  "jsonrpc": "2.0",
    ///  "result": "2"
    /// }
    /// ```
    func shh_version() -> Promise<String> {
        return network.send("shh_version").string()
    }
    
    /// Sends a whisper message.
    ///
    /// ##### Parameters
    ///
    /// 1. `Object` - The whisper post object:
    ///  - `from`: `DATA`, 60 Bytes - (optional) The identity of the sender.
    ///  - `to`: `DATA`, 60 Bytes - (optional) The identity of the receiver. When present whisper will encrypt the message so that only the receiver can decrypt it.
    ///  - `topics`: `Array of DATA` - Array of `DATA` topics, for the receiver to identify messages.
    ///  - `payload`: `DATA` - The payload of the message.
    ///  - `priority`: `QUANTITY` - The integer of the priority in a range from ... (?).
    ///  - `ttl`: `QUANTITY` - integer of the time to live in seconds.
    ///
    /// ```js
    /// params: [{
    ///  from: "0x04f96a5e25610293e42a73908e93ccc8c4d4dc0edcfa9fa872f50cb214e08ebf61a03e245533f97284d442460f2998cd41858798ddfd4d661997d3940272b717b1",
    ///  to: "0x3e245533f97284d442460f2998cd41858798ddf04f96a5e25610293e42a73908e93ccc8c4d4dc0edcfa9fa872f50cb214e08ebf61a0d4d661997d3940272b717b1",
    ///  topics: ["0x776869737065722d636861742d636c69656e74", "0x4d5a695276454c39425154466b61693532"],
    ///  payload: "0x7b2274797065223a226d6",
    ///  priority: "0x64",
    ///  ttl: "0x64",
    /// }]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `Boolean` - returns `true` if the message was send, otherwise `false`.
    ///
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"shh_post","params":[{"from":"0xc931d93e97ab07fe42d923478ba2465f2..","topics": ["0x68656c6c6f20776f726c64"],"payload":"0x68656c6c6f20776f726c64","ttl":0x64,"priority":0x64}],"id":73}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc":"2.0",
    ///  "result": true
    /// }
    /// ```
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
    
    /// Creates new whisper identity in the client.
    ///
    /// ##### Parameters
    /// none
    ///
    /// ##### Returns
    ///
    /// `DATA`, 60 Bytes - the address of the new identiy.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"shh_newIdentity","params":[],"id":73}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": "0xc931d93e97ab07fe42d923478ba2465f283f440fd6cabea4dd7a2c807108f651b7135d1d6ca9007d5b68aa497e4619ac10aa3b27726e1863c1fd9b570d99bbaf"
    /// }
    /// ```
    func shh_newIdentity() -> Promise<Data> {
        return network.send("shh_newIdentity").data()
    }
    
    /// Checks if the client hold the private keys for a given identity.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `DATA`, 60 Bytes - The identity address to check.
    ///
    /// ```js
    /// params: [
    ///  "0x04f96a5e25610293e42a73908e93ccc8c4d4dc0edcfa9fa872f50cb214e08ebf61a03e245533f97284d442460f2998cd41858798ddfd4d661997d3940272b717b1"
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `Boolean` - returns `true` if the client holds the privatekey for that identity, otherwise `false`.
    ///
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"shh_hasIdentity","params":["0x04f96a5e25610293e42a73908e93ccc8c4d4dc0edcfa9fa872f50cb214e08ebf61a03e245533f97284d442460f2998cd41858798ddfd4d661997d3940272b717b1"],"id":73}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": true
    /// }
    /// ```
    func shh_hasIdentity(id: ShhAddress) -> Promise<Bool> {
        return network.send("shh_hasIdentity", id).bool()
    }
    
    /// Creates a new group.
    ///
    /// ##### Parameters
    /// none
    ///
    /// ##### Returns
    ///
    /// `DATA`, 60 Bytes - the address of the new group.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"shh_newGroup","params":[],"id":73}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": "0xc65f283f440fd6cabea4dd7a2c807108f651b7135d1d6ca90931d93e97ab07fe42d923478ba2407d5b68aa497e4619ac10aa3b27726e1863c1fd9b570d99bbaf"
    /// }
    /// ```
    func shh_newGroup() -> Promise<Data> {
        return network.send("shh_newGroup").data()
    }
    
    /// Adds a whisper identity to the group.
    ///
    /// ##### Parameters
    ///
    /// 1. `DATA`, 60 Bytes - The identity address to add to a group.
    ///
    /// ```js
    /// params: [
    ///  "0x04f96a5e25610293e42a73908e93ccc8c4d4dc0edcfa9fa872f50cb214e08ebf61a03e245533f97284d442460f2998cd41858798ddfd4d661997d3940272b717b1"
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `Boolean` - returns `true` if the identity was successfully added to the group, otherwise `false`.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"shh_addToGroup","params":["0x04f96a5e25610293e42a73908e93ccc8c4d4dc0edcfa9fa872f50cb214e08ebf61a03e245533f97284d442460f2998cd41858798ddfd4d661997d3940272b717b1"],"id":73}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc": "2.0",
    ///  "result": true
    /// }
    /// ```
    func shh_addToGroup() -> Promise<Bool> {
        return network.send("shh_addToGroup").bool()
    }
    
    /// Creates filter to notify, when client receives whisper message matching the filter options.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `Object` - The filter options:
    ///  - `to`: `DATA`, 60 Bytes - (optional) Identity of the receiver. *When present it will try to decrypt any incoming message if the client holds the private key to this identity.*
    ///  - `topics`: `Array of DATA` - Array of `DATA` topics which the incoming message's topics should match.  You can use the following combinations:
    ///    - `[A, B] = A && B`
    ///    - `[A, [B, C]] = A && (B || C)`
    ///    - `[null, A, B] = ANYTHING && A && B` `null` works as a wildcard
    ///
    /// ```js
    /// params: [{
    ///   "topics": ['0x12341234bf4b564f'],
    ///   "to": "0x04f96a5e25610293e42a73908e93ccc8c4d4dc0edcfa9fa872f50cb214e08ebf61a03e245533f97284d442460f2998cd41858798ddfd4d661997d3940272b717b1"
    /// }]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `QUANTITY` - The newly created filter.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"shh_newFilter","params":[{"topics": ['0x12341234bf4b564f'],"to": "0x2341234bf4b2341234bf4b564f..."}],"id":73}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc":"2.0",
    ///  "result": "0x7" // 7
    /// }
    /// ```
    func shh_newFilter(to: Data, topics: TopicFilters) -> Promise<BigUInt> {
        return network.send("shh_newFilter").uint256()
    }
    
    /// Uninstalls a filter with given id. Should always be called when watch is no longer needed.
    /// Additonally Filters timeout when they aren't requested with [shh_getFilterChanges](#shh_getfilterchanges) for a period of time.
    ///
    ///
    /// ##### Parameters
    ///
    /// - Parameter id: The filter id.
    ///
    /// ```js
    /// params: [
    ///  "0x7" // 7
    /// ]
    /// ```
    ///
    /// - Returns: `Boolean` - `true` if the filter was successfully uninstalled, otherwise `false`.
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"shh_uninstallFilter","params":["0x7"],"id":73}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc":"2.0",
    ///  "result": true
    /// }
    /// ```
    func shh_uninstallFilter(id: BigUInt) -> Promise<Bool> {
        return network.send("shh_uninstallFilter").bool()
    }
    
    /// Polling method for whisper filters. Returns new messages since the last call of this method.
    ///
    /// **Note** calling the [shh_getMessages](#shh_getmessages) method, will reset the buffer for this method, so that you won't receive duplicate messages.
    ///
    ///
    /// ##### Parameters
    ///
    /// 1. `QUANTITY` - The filter id.
    ///
    /// ```js
    /// params: [
    ///  "0x7" // 7
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// `Array` - Array of messages received since last poll:
    ///
    ///  - `hash`: `DATA`, 32 Bytes (?) - The hash of the message.
    ///  - `from`: `DATA`, 60 Bytes - The sender of the message, if a sender was specified.
    ///  - `to`: `DATA`, 60 Bytes - The receiver of the message, if a receiver was specified.
    ///  - `expiry`: `QUANTITY` - Integer of the time in seconds when this message should expire (?).
    ///  - `ttl`: `QUANTITY` -  Integer of the time the message should float in the system in seconds (?).
    ///  - `sent`: `QUANTITY` -  Integer of the unix timestamp when the message was sent.
    ///  - `topics`: `Array of DATA` - Array of `DATA` topics the message contained.
    ///  - `payload`: `DATA` - The payload of the message.
    ///  - `workProved`: `QUANTITY` - Integer of the work this message required before it was send (?).
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"shh_getFilterChanges","params":["0x7"],"id":73}'
    ///
    /// // Result
    /// {
    ///  "id":1,
    ///  "jsonrpc":"2.0",
    ///  "result": [{
    ///    "hash": "0x33eb2da77bf3527e28f8bf493650b1879b08c4f2a362beae4ba2f71bafcd91f9",
    ///    "from": "0x3ec052fc33..",
    ///    "to": "0x87gdf76g8d7fgdfg...",
    ///    "expiry": "0x54caa50a", // 1422566666
    ///    "sent": "0x54ca9ea2", // 1422565026
    ///    "ttl": "0x64", // 100
    ///    "topics": ["0x6578616d"],
    ///    "payload": "0x7b2274797065223a226d657373616765222c2263686...",
    ///    "workProved": "0x0"
    ///    }]
    /// }
    /// ```
    func shh_getFilterChanges(id: BigUInt) -> Promise<[ShhMessage]> {
        return network.send("shh_getFilterChanges", id).shhMessages()
    }
    
    /// Get all messages matching a filter. Unlike `shh_getFilterChanges` this returns all messages.
    ///
    /// ##### Parameters
    ///
    /// 1. `QUANTITY` - The filter id.
    ///
    /// ```js
    /// params: [
    ///  "0x7" // 7
    /// ]
    /// ```
    ///
    /// ##### Returns
    ///
    /// See [shh_getFilterChanges](#shh_getfilterchanges)
    ///
    /// ##### Example
    /// ```js
    /// // Request
    /// curl -X POST --data '{"jsonrpc":"2.0","method":"shh_getMessages","params":["0x7"],"id":73}'
    /// ```
    ///
    /// Result see [shh_getFilterChanges](#shh_getfilterchanges)
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

class ShhAddress: JEncodable {
    let data: Data
    init(_ data: Data) {
        self.data = data
    }
    init(_ json: AnyReader) throws {
        data = try json.data()
    }
    
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return data.jsonRpcValue(with: network)
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
