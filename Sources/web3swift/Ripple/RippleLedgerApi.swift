//
//  RippleLedgerApi.swift
//  web3swift
//
//  Created by Dmitry on 27/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

class RippleLedgerApi {
    let network: NetworkProvider
    init(network: NetworkProvider) {
        self.network = network
    }
    
    /// ledger_hash    String    (Optional) A 20-byte hex string for the ledger version to use. (See Specifying Ledgers).
    /// ledger_index    String or Unsigned Integer    (Optional) The sequence number of the ledger to use, or a shortcut string to choose a ledger automatically. (See Specifying Ledgers)
    /// full    Boolean    (Optional) Admin required If true, return full information on the entire ledger. Ignored if you did not specify a ledger version. Defaults to false. (Equivalent to enabling transactions, accounts, and expand.) Caution: This is a very large amount of data -- on the order of several hundred megabytes!
    /// accounts    Boolean    (Optional) Admin required. If true, return information on accounts in the ledger. Ignored if you did not specify a ledger version. Defaults to false. Caution: This returns a very large amount of data!
    /// transactions    Boolean    (Optional) If true, return information on transactions in the specified ledger version. Defaults to false. Ignored if you did not specify a ledger version.
    /// expand    Boolean    (Optional) Provide full JSON-formatted information for transaction/account information instead of only hashes. Defaults to false. Ignored unless you request transactions, accounts, or both.
    /// owner_funds    Boolean    (Optional) If true, include owner_funds field in the metadata of OfferCreate transactions in the response. Defaults to false. Ignored unless transactions are included and expand is true.
    /// binary    Boolean    (Optional) If true, and transactions and expand are both also true, return transaction information in binary format (hexadecimal string) instead of JSON format. New in: rippled 0.28.0
    /// queue    Boolean    (Optional) If true, and the command is requesting the current ledger, includes an array of queued transactions in the results.
    func ledger(_ ledger: Ledger, full: Bool, accounts: Bool, transactions: Bool, expand: Bool, owner_funds: Bool, binary: Bool, queue: Bool) -> Promise<LedgerInfo> {
        let input = JDictionary()
            .set(ledger)
            .oset("full", full)
            .oset("accounts", accounts)
            .oset("transactions", transactions)
            .oset("owner_funds", owner_funds)
            .oset("binary", binary)
            .oset("queue", queue)
        return network.send("account_channels", input).map(LedgerInfo.init)
    }
    
    class LedgerInfo {
        /// account_hash    String    Hash of all account state information in this ledger, as hex
        let account_hash: Data
        /// accountState    Array    (Omitted unless requested) All the account-state information in this ledger.
        let accountState: [AnyReader]
        /// close_flags    Integer    A bit-map of flags relating to the closing of this ledger. Currently, the ledger has only one flag defined for close_flags: sLCF_NoConsensusTime (value 1). If this flag is enabled, it means that validators were in conflict regarding the correct close time for the ledger, but build otherwise the same ledger, so they declared consensus while "agreeing to disagree" on the close time. In this case, the consensus ledger contains a close_time that is 1 second after that of the previous ledger. (In this case, there is no official close time, but the actual real-world close time is probably 3-6 seconds later than the specified close_time.)
        let close_flags: Int
        
        /// close_time    Integer    The time this ledger was closed, in seconds since the Ripple Epoch
        let close_time: Int
        /// close_time_human    String    The time this ledger was closed, in human-readable format
        let close_time_human: String
        /// close_time_resolution    Integer    Ledger close times are rounded to within this many seconds.
        let close_time_resolution: Int
        /// closed    Boolean    Whether or not this ledger has been closed
        let closed: Bool
        /// ledger_hash    String    Unique identifying hash of the entire ledger.
        let ledger_hash: Data
        /// ledger_index    String    The Ledger Index of this ledger, as a quoted integer
        let ledger_index: Int
        /// parent_close_time    Integer    The time at which the previous ledger was closed.
        let parent_close_time: Int
        /// parent_hash    String    Unique identifying hash of the ledger that came immediately before this one.
        let parent_hash: Data
        /// total_coins    String    Total number of XRP drops in the network, as a quoted integer. (This decreases as transaction costs destroy XRP.)
        let total_coins: BigUInt
        /// transaction_hash    String    Hash of the transaction information included in this ledger, as hex
        let transaction_hash: Data
        /// transactions    Array    (Omitted unless requested) Transactions applied in this ledger version. By default, members are the transactions' identifying Hash strings. If the request specified expand as true, members are full representations of the transactions instead, in either JSON or binary depending on whether the request specified binary as true.
        let transactions: [AnyReader]
        
        init(_ json: AnyReader) throws {
            account_hash = try json.at("account_hash").data()
            accountState = try json.at("accountState").array()
            close_flags = try json.at("close_flags").int()
            close_time = try json.at("close_time").int()
            close_time_human = try json.at("close_time_human").string()
            close_time_resolution = try json.at("close_time_resolution").int()
            closed = try json.at("closed").bool()
            ledger_hash = try json.at("ledger_hash").data()
            ledger_index = try json.at("ledger_index").int()
            parent_close_time = try json.at("parent_close_time").int()
            parent_hash = try json.at("parent_hash").data()
            total_coins = try json.at("total_coins").uint256()
            transaction_hash = try json.at("transaction_hash").data()
            transactions = try json.at("transactions").array()
        }
    }
    
//    class QueueData {
//        /// account    String    The Address of the sender for this queued transaction.
//        let account: String
//        /// tx    String or Object    By default, this is a String containing the identifying hash of the transaction. If transactions are expanded in binary format, this is an object whose only field is tx_blob, containing the binary form of the transaction as a decimal string. If transactions are expanded in JSON format, this is an object containing the transaction object including the transaction's identifying hash in the hash field.
//        /// retries_remaining    Number    How many times this transaction can be retried before being dropped.
//        /// preflight_result    String    The tentative result from preliminary transaction checking. This is always tesSUCCESS.
//        /// last_result    String    (May be omitted) If this transaction was left in the queue after getting a retriable (ter) result, this is the exact ter result code it got.
//        /// auth_change    Boolean    (May be omitted) Whether this transaction changes this address's ways of authorizing transactions.
//        /// fee    String    (May be omitted) The Transaction Cost of this transaction, in drops of XRP.
//        /// fee_level    String    (May be omitted) The transaction cost of this transaction, relative to the minimum cost for this type of transaction, in fee levels.
//        /// max_spend_drops    String    (May be omitted) The maximum amount of XRP, in drops, this transaction could potentially send or destroy.
//    }
}

extension JDictionary {
    func oset(_ key: String, _ value: Bool, _ d: Bool = false) -> Self {
        guard value != d else { return self }
        return set(key, value)
    }
}
