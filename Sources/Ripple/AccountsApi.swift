//
//  RippleAccountsApi.swift
//  web3swift
//
//  Created by Dmitry on 27/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit
import CoreBlockchain

class RippleAccountsApi {
    let network: NetworkProvider
    init(network: NetworkProvider) {
        self.network = network
    }
    
    /// The account_channels method returns information about an account's Payment Channels. This includes only channels where the specified account is the channel's source, not the destination. (A channel's "source" and "owner" are the same.) All information retrieved is relative to a particular version of the ledger.
    ///
    /// - Parameters:
    ///   - account: The unique identifier of an account, typically the account's Address. The request returns channels where this account is the channel's owner/source.
    ///   - destinationAccount: The unique identifier of an account, typically the account's Address. If provided, filter results to payment channels whose destination is this account.
    ///   - ledgerHash: A 20-byte hex string for the ledger version to use. (See Specifying Ledgers)
    ///   - ledgerIndex: The sequence number of the ledger to use, or a shortcut string to choose a ledger automatically. (See Specifying Ledgers)
    ///   - limit: Limit the number of transactions to retrieve. The server is not required to honor this value. Must be within the inclusive range 10 to 400. Defaults to 200.
    ///   - marker: Value from a previous paginated response. Resume retrieving data where that response left off.
    func channels(account: String, destinationAccount: String?, ledger: Ledger, limit: Int?) -> Promise<[Channel]> {
        let input = JDictionary()
            .set("account", account)
            .set("destination_account", destinationAccount)
            .set(ledger)
            .set("limit", limit)
        return network.send("account_channels", input).array(Channel.init)
    }
    
    class Channel {
        /// The owner of the channel, as an Address.
        let account: RippleAddress
        /// The total amount of XRP, in drops allocated to this channel.
        let amount: BigUInt
        /// The total amount of XRP, in drops, paid out from this channel, as of the ledger version used. (You can calculate the amount of XRP left in the channel by subtracting balance from amount.)
        let balance: BigUInt
        /// A unique ID for this channel, as a 64-character hexadecimal string. This is also the ID of the channel object in the ledger's state data.
        let channelId: Data
        /// the destination account of the channel, as an Address. Only this account can receive the XRP in the channel while it is open.
        let destinationAccount: RippleAddress
        /// (May be omitted) The public key for the payment channel in base58 format. Signed claims against this channel must be redeemed with the matching key pair.
        let publicKey: Data?
        /// The number of seconds the payment channel must stay open after the owner of the channel requests to close it.
        let settleDelay: Int
        /// (May be omitted) Time, in seconds since the Ripple Epoch, when this channel is set to expire. This expiration date is mutable. If this is before the close time of the most recent validated ledger, the channel is expired.
        let expiration: Int?
        /// (May be omitted) Time, in seconds since the Ripple Epoch, of this channel's immutable expiration, if one was specified at channel creation. If this is before the close time of the most recent validated ledger, the channel is expired.
        let cancelAfter: Int?
        /// (May be omitted) A 32-bit unsigned integer to use as a source tag for payments through this payment channel, if one was specified at channel creation. This indicates the payment channel's originator or other purpose at the source account. Conventionally, if you bounce payments from this channel, you should specify this value in the DestinationTag of the return payment.
        let sourceTag: UInt64?
        /// (May be omitted) A 32-bit unsigned integer to use as a destination tag for payments through this channel, if one was specified at channel creation. This indicates the payment channel's beneficiary or other purpose at the destination account.
        let destinationTag: UInt64?
        init(_ json: AnyReader) throws {
            account = try json.at("account").rippleAddress()
            amount = try json.at("amount").uint256()
            balance = try json.at("balance").uint256()
            channelId = try json.at("channel_id").data()
            destinationAccount = try json.at("destinationAccount").rippleAddress()
            publicKey = try json.at("public_key").data()
            settleDelay = try json.at("settle_delay").int()
            expiration = try json.optional("expiration")?.int()
            cancelAfter = try json.optional("cancel_after")?.int()
            sourceTag = try json.optional("source_tag")?.uint64()
            destinationTag = try json.optional("destinationTag")?.uint64()
        }
    }
    
    /// account    String    A unique identifier for the account, most commonly the account's Address.
    /// strict    Boolean    (Optional) If true, only accept an address or public key for the account parameter. Defaults to false.
    /// ledger_hash    String    (Optional) A 20-byte hex string for the ledger version to use. (See Specifying Ledgers)
    /// ledger_index    String or Unsigned Integer    (Optional) The sequence number of the ledger to use, or a shortcut string to choose a ledger automatically. (See Specifying Ledgers)
    func currencies(account: String, strict: Bool, ledger: Ledger) -> Promise<Currencies> {
        let input = JDictionary()
            .set("account", account)
            .set("strict", strict)
            .set(ledger)
        return network.send("account_currencies", input).map(Currencies.init)
    }
    
    class Currencies {
        /// ledger_hash    String - Hash    (May be omitted) The identifying hash of the ledger version used to retrieve this data, as hex.
        let ledgerHash: String?
        /// ledger_index    Integer - Ledger Index    The sequence number of the ledger version used to retrieve this data.
        let ledgerIndex: Int
        /// receive_currencies    Array of Strings    Array of Currency Codes for currencies that this account can receive.
        let receiveCurrencies: [String]
        /// send_currencies    Array of Strings    Array of Currency Codes for currencies that this account can send.
        let sendCurrencies: [String]
        /// validated    Boolean    If true, this data comes from a validated ledger.
        let validated: Bool
        init(_ json: AnyReader) throws {
            ledgerHash = try json.optional("ledger_hash")?.string()
            ledgerIndex = try json.at("ledger_index").int()
            receiveCurrencies = try json.at("receive_currencies").array(_string)
            sendCurrencies = try json.at("send_currencies").array(_string)
            validated = try json.at("validated").bool()
        }
    }
    
    /// account    String    A unique identifier for the account, most commonly the account's Address.
    /// strict    Boolean    (Optional, defaults to False) If set to True, then the account field only accepts a public key or XRP Ledger address.
    /// ledger_hash    String    (Optional) A 20-byte hex string for the ledger version to use. (See Specifying Ledgers)
    /// ledger_index    String or Unsigned Integer    (Optional) The sequence number of the ledger to use, or a shortcut string to choose a ledger automatically. (See Specifying Ledgers)
    /// queue    Boolean    (Optional) If true, and the FeeEscalation amendment is enabled, also returns stats about queued transactions associated with this account. Can only be used when querying for the data from the current open ledger. New in: rippled 0.33.0
    /// signer_lists    Boolean    (Optional) If true, and the MultiSign amendment is enabled, also returns any SignerList objects associated with this account. New in: rippled 0.31.0
    func info(account: String, strict: Bool, ledger: Ledger, queue: Bool?, singerLists: Bool?) -> Promise<AccountInfo> {
        let input = JDictionary()
            .set("account", account)
            .set("strict", strict)
            .set(ledger)
            .set("queue", queue)
            .set("signer_lists", singerLists)
        return network.send("account_info", input).map(AccountInfo.init)
    }
    
    class AccountInfo {
        /// account_data    Object    The AccountRoot ledger object with this account's information, as stored in the ledger.
        var accountData: AccountRoot
        /// signer_lists    Array    (Omitted unless the request specified signer_lists and at least one SignerList is associated with the account.) Array of SignerList ledger objects associated with this account for Multi-Signing. Since an account can own at most one SignerList, this array must have exactly one member if it is present. New in: rippled 0.31.0
        /// ledger_current_index    Integer    (Omitted if ledger_index is provided instead) The sequence number of the most-current ledger, which was used when retrieving this information. The information does not contain any changes from ledgers newer than this one.
        /// ledger_index    Integer    (Omitted if ledger_current_index is provided instead) The sequence number of the ledger used when retrieving this information. The information does not contain any changes from ledgers newer than this one.
        /// queue_data    Object    (Omitted unless queue specified as true and querying the current open ledger.) Information about queued transactions sent by this account. This information describes the state of the local rippled server, which may be different from other servers in the consensus network. Some fields may be omitted because the values are calculated "lazily" by the queuing mechanism.
        /// validated    Boolean    True if this data is from a validated ledger version; if omitted or set to false, this data is not final. New in: rippled 0.26.0
        init(_ json: AnyReader) throws {
            accountData = try AccountRoot(json.at("account_data"))
        }
    }
    class AccountRoot {
        /// LedgerEntryType    String    UInt16    The value 0x0061, mapped to the string AccountRoot, indicates that this is an AccountRoot object.
        ///
        /// Account    String    AccountID    The identifying address of this account, such as rf1BiGeXwwQoi8Z2ueFYTEXSwuJYfV2Jpn.
        /// Balance    String    Amount    The account's current XRP balance in drops, represented as a string.
        var balance: BigUInt
        /// Flags    Number    UInt32    A bit-map of boolean flags enabled for this account.
        /// OwnerCount    Number    UInt32    The number of objects this account owns in the ledger, which contributes to its owner reserve.
        /// PreviousTxnID    String    Hash256    The identifying hash of the transaction that most recently modified this object.
        /// PreviousTxnLgrSeq    Number    UInt32    The index of the ledger that contains the transaction that most recently modified this object.
        /// Sequence    Number    UInt32    The sequence number of the next valid transaction for this account. (Each account starts with Sequence = 1 and increases each time a transaction is made.)
        /// AccountTxnID    String    Hash256    (Optional) The identifying hash of the transaction most recently submitted by this account.
        /// Domain    String    VariableLength    (Optional) A domain associated with this account. In JSON, this is the hexadecimal for the ASCII representation of the domain.
        /// EmailHash    String    Hash128    (Optional) The md5 hash of an email address. Clients can use this to look up an avatar through services such as Gravatar.
        /// MessageKey    String    VariableLength    (Optional) A public key that may be used to send encrypted messages to this account. In JSON, uses hexadecimal. No more than 33 bytes.
        /// RegularKey    String    AccountID    (Optional) The address of a keypair that can be used to sign transactions for this account instead of the master key. Use a SetRegularKey transaction to change this value.
        /// TickSize    Number    UInt8    (Optional) How many significant digits to use for exchange rates of Offers involving currencies issued by this address. Valid values are 3 to 15, inclusive. (Requires the TickSize amendment.)
        /// TransferRate    Number    UInt32    (Optional) A transfer fee to charge other users for sending currency issued by this account to each other.
        init(_ json: AnyReader) throws {
            balance = try json.at("balance").uint256()
        }
    }
    
    /// account    String    A unique identifier for the account, most commonly the account's Address.
    /// ledger_hash    String    (Optional) A 20-byte hex string for the ledger version to use. (See Specifying Ledgers)
    /// ledger_index    String or Unsigned Integer    (Optional) The sequence number of the ledger to use, or a shortcut string to choose a ledger automatically. (See Specifying Ledgers)
    /// peer    String    (Optional) The Address of a second account. If provided, show only lines of trust connecting the two accounts.
    /// limit    Integer    (Optional, default varies) Limit the number of transactions to retrieve. The server is not required to honor this value. Must be within the inclusive range 10 to 400. New in: rippled 0.26.4
    /// marker    Marker    (Optional) Value from a previous paginated response. Resume retrieving data where that response left off. New in: rippled 0.26.4
    func lines(account: String, ledger: Ledger, peer: String?, limit: Int?, marker: Any?) -> Promise<Lines> {
        let input = JDictionary()
            .set("account", account)
            .set(ledger)
            .set("peer", peer)
            .set("limit", limit)
            .set("marker", JValue(marker))
        return network.send("account_lines", input).map(Lines.init)
    }
    
    class Lines {
        /// account    String    Unique Address of the account this request corresponds to. This is the "perspective account" for purpose of the trust lines.
        let account: String
        /// lines    Array    Array of trust line objects, as described below. If the number of trust lines is large, only returns up to the limit at a time.
        let line: [Line]
        /// ledger_current_index    Integer    (Omitted if ledger_hash or ledger_index provided) Sequence number of the ledger version used when retrieving this data. New in: rippled 0.26.4-sp1
        let ledger_current_index: Int?
        /// ledger_index    Integer    (Omitted if ledger_current_index provided instead) Sequence number, provided in the request, of the ledger version that was used when retrieving this data. New in: rippled 0.26.4-sp1
        let ledger_index: Int?
        /// ledger_hash    String    (May be omitted) Hex hash, provided in the request, of the ledger version that was used when retrieving this data. New in: rippled 0.26.4-sp1
        let ledger_hash: String?
        /// marker    Marker    Server-defined value indicating the response is paginated. Pass this to the next call to resume where this call left off. Omitted when there are no additional pages after this one. New in: rippled 0.26.4
        let marker: AnyReader
        init(_ json: AnyReader) throws {
            account = try json.at("account").string()
            line = try json.at("line").array(Line.init)
            ledger_current_index = try json.optional("ledger_current_index")?.int()
            ledger_index = try json.optional("ledger_index")?.int()
            ledger_hash = try json.optional("ledger_hash")?.string()
            marker = try json.at("marker")
        }
    }
    
    class Line {
        /// account    String    The unique Address of the counterparty to this trust line.
        let account: String
        /// balance    String    Representation of the numeric balance currently held against this line. A positive balance means that the perspective account holds value; a negative balance means that the perspective account owes value.
        let balance: String
        /// currency    String    A Currency Code identifying what currency this trust line can hold.
        let currency: String
        /// limit    String    The maximum amount of the given currency that this account is willing to owe the peer account
        let limite: String
        /// limit_peer    String    The maximum amount of currency that the counterparty account is willing to owe the perspective account
        let limitPeer: String
        /// quality_in    Unsigned Integer    Rate at which the account values incoming balances on this trust line, as a ratio of this value per 1 billion units. (For example, a value of 500 million represents a 0.5:1 ratio.) As a special case, 0 is treated as a 1:1 ratio.
        let qualityIn: UInt
        /// quality_out    Unsigned Integer    Rate at which the account values outgoing balances on this trust line, as a ratio of this value per 1 billion units. (For example, a value of 500 million represents a 0.5:1 ratio.) As a special case, 0 is treated as a 1:1 ratio.
        let qualityOut: UInt
        /// no_ripple    Boolean    (May be omitted) true if this account has enabled the NoRipple flag for this line. If omitted, that is the same as false.
        let noRipple: Bool
        /// no_ripple_peer    Boolean    (May be omitted) true if the peer account has enabled the NoRipple flag. If omitted, that is the same as false.
        let noRipplePeer: Bool
        /// authorized    Boolean    (May be omitted) true if this account has authorized this trust line. If omitted, that is the same as false.
        let authorized: Bool
        /// peer_authorized    Boolean    (May be omitted) true if the peer account has authorized this trust line. If omitted, that is the same as false.
        let peerAuthorized: Bool
        /// freeze    Boolean    (May be omitted) true if this account has frozen this trust line. If omitted, that is the same as false.
        let freeze: Bool
        /// freeze_peer    Boolean    (May be omitted) true if the peer account has frozen this trust line. If omitted, that is the same as false.
        let freezePeer: Bool
        
        init(_ json: AnyReader) throws {
            account = try json.at("account").string()
            balance = try json.at("balance").string()
            currency = try json.at("currency").string()
            limite = try json.at("limite").string()
            limitPeer = try json.at("limitPeer").string()
            qualityIn = try json.at("qualityIn").uint()
            qualityOut = try json.at("qualityOut").uint()
            noRipple = try json.bool(at: "noRipple")
            noRipplePeer = try json.bool(at: "noRipplePeer")
            authorized = try json.bool(at: "authorized")
            peerAuthorized = try json.bool(at: "peerAuthorized")
            freeze = try json.bool(at: "freeze")
            freezePeer = try json.bool(at: "freezePeer")
        }
    }
    
    /// account    String    A unique identifier for the account, most commonly the account's address.
    /// type    String    (Optional) If included, filter results to include only this type of ledger object. The valid types are: check, deposit_preauth, escrow, offer, payment_channel, signer_list, and state (trust line).
    /// ledger_hash    String    (Optional) A 20-byte hex string for the ledger version to use. (See Specifying Ledgers)
    /// ledger_index    String or Unsigned Integer    (Optional) The sequence number of the ledger to use, or a shortcut string to choose a ledger automatically. (See Specifying Ledgers)
    /// limit    Unsigned Integer    (Optional) The maximum number of objects to include in the results. Must be within the inclusive range 10 to 400 on non-admin connections. Defaults to 200.
    /// marker    Marker    (Optional) Value from a previous paginated response. Resume retrieving data where that response left off.
    func objects(account: String, type: String?, ledger: Ledger, limit: UInt?, marker: Any?) -> Promise<AnyReader> {
        let input = JDictionary()
            .set("account", account)
            .set("type", type)
            .set(ledger)
            .set("limit", limit)
            .set("marker", JValue(marker))
        return network.send("account_objects", input)
    }
    
    /// account    String    A unique identifier for the account, most commonly the account's Address.
    /// ledger_hash    String    (Optional) A 20-byte hex string identifying the ledger version to use.
    /// ledger_index    Ledger Index    (Optional, defaults to current) The sequence number of the ledger to use, or "current", "closed", or "validated" to select a ledger dynamically. (See Specifying Ledgers)
    /// limit    Integer    (Optional, default varies) Limit the number of transactions to retrieve. The server is not required to honor this value. Must be within the inclusive range 10 to 400. New in: rippled 0.26.4
    /// marker    Marker    (Optional) Value from a previous paginated response. Resume retrieving data where that response left off. New in: rippled 0.26.4
    func offers(account: String, ledger: Ledger, limit: UInt?, marker: Any?) -> Promise<AnyReader> {
        let input = JDictionary()
            .set("account", account)
            .set(ledger)
            .set("limit", limit)
            .set("marker", JValue(marker))
        return network.send("account_offers", input)
    }
    
    /// account    String    A unique identifier for the account, most commonly the account's address.
    /// ledger_index_min    Integer    (Optional) Use to specify the earliest ledger to include transactions from. A value of -1 instructs the server to use the earliest validated ledger version available.
    /// ledger_index_max    Integer    (Optional) Use to specify the most recent ledger to include transactions from. A value of -1 instructs the server to use the most recent validated ledger version available.
    /// ledger_hash    String    (Optional) Use to look for transactions from a single ledger only. (See Specifying Ledgers.)
    /// ledger_index    String or Unsigned Integer    (Optional) Use to look for transactions from a single ledger only. (See Specifying Ledgers.)
    /// binary    Boolean    (Optional) Defaults to false. If set to true, returns transactions as hex strings instead of JSON.
    /// forward    Boolean    (Optional) Defaults to false. If set to true, returns values indexed with the oldest ledger first. Otherwise, the results are indexed with the newest ledger first. (Each page of results may not be internally ordered, but the pages are overall ordered.)
    /// limit    Integer    (Optional) Default varies. Limit the number of transactions to retrieve. The server is not required to honor this value.
    /// marker    Marker    Value from a previous paginated response. Resume retrieving data where that response left off. This value is stable even if there is a change in the server's range of available ledgers.
    func tx(account: String, ledger_index_min: Int?, ledger_index_max: Int?, ledger: Ledger, binary: Bool, forward: Bool, limit: Bool, marker: Any?) -> Promise<TX> {
        let input = JDictionary()
            .set("account", account)
            .set("ledger_index_min", ledger_index_min)
            .set("ledger_index_max", ledger_index_max)
            .set(ledger)
            .set("binary", binary)
            .set("forward", forward)
            .set("limit", limit)
            .set("marker", JValue(marker))
        return network.send("account_tx", input).map(TX.init)
    }
    
    struct TX {
        /// account    String    Unique Address identifying the related account
        let account: String
        /// ledger_index_min    Integer    The sequence number of the earliest ledger actually searched for transactions.
        let ledger_index_min: Int
        /// ledger_index_max    Integer    The sequence number of the most recent ledger actually searched for transactions.
        let ledger_index_max: Int
        /// limit    Integer    The limit value used in the request. (This may differ from the actual limit value enforced by the server.)
        let limit: Int
        /// marker    Marker    Server-defined value indicating the response is paginated. Pass this to the next call to resume where this call left off.
        let marker: AnyReader
        /// transactions    Array    Array of transactions matching the request's criteria, as explained below.
        let transactions: [Transaction]
        /// validated    Boolean    If included and set to true, the information in this response comes from a validated ledger version. Otherwise, the information is subject to change.
        let validated: Bool
        init(_ json: AnyReader) throws {
            account = try json.at("account").string()
            ledger_index_min = try json.at("ledger_index_min").int()
            ledger_index_max = try json.at("ledger_index_max").int()
            limit = try json.at("limit").int()
            marker = try json.at("marker")
            transactions = try json.at("transactions").array(Transaction.init)
            validated = try json.at("validated").bool()
        }
    }
    
    struct Transaction {
        /// ledger_index    Integer    The sequence number of the ledger version that included this transaction.
        let ledger_index: Int
        /// meta    Object (JSON) or String (Binary)    If binary is True, then this is a hex string of the transaction metadata. Otherwise, the transaction metadata is included in JSON format.
        let meta: AnyReader
        /// tx    Object    (JSON mode only) JSON object defining the transaction
        let tx: AnyReader?
        /// tx_blob    String    (Binary mode only) Unique hashed String representing the transaction.
        let txBlob: String?
        /// validated    Boolean    Whether or not the transaction is included in a validated ledger. Any transaction not yet in a validated ledger is subject to change.
        let validated: Bool
        
        init(_ json: AnyReader) throws {
            ledger_index = try json.at("ledger_index").int()
            meta = try json.at("meta")
            tx = try json.optional("tx")
            txBlob = try json.at("tx_blob").string()
            validated = try json.at("validated").bool()
        }
    }
    
    /// account    String    The Address to check. This should be the issuing address
    /// strict    Boolean    (Optional) If true, only accept an address or public key for the account parameter. Defaults to false.
    /// hotwallet    String or Array    (Optional) An operational address to exclude from the balances issued, or an array of such addresses.
    /// ledger_hash    String    (Optional) A 20-byte hex string for the ledger version to use. (See Specifying Ledgers)
    /// ledger_index    String or Unsigned Integer    (Optional) The sequence number of the ledger version to use, or a shortcut string to choose a ledger automatically. (See Specifying Ledgers)
    func gateway_balances(account: String, hotWallet: [String]?, ledger: Ledger) -> Promise<Balances> {
        let input = JDictionary()
            .set("account", account)
            .set("hotWallet", JArray(hotWallet))
            .set(ledger)
        return network.send("gateway_balances", input).map(Balances.init)
    }
    
    class Balances {
        /// account    String    Unique Address identifying the account that issued the balances.
        let account: String
        /// obligations    Object    (Omitted if empty) Total amounts issued to addresses not excluded, as a map of currencies to the total value issued.
        let obligations: [String: String]
        /// balances    Object    (Omitted if empty) Amounts issued to the hotwallet addresses from the request. The keys are addresses and the values are arrays of currency amounts they hold.
        let balances: [String: Value]
        /// assets    Object    (Omitted if empty) Total amounts held that are issued by others. In the recommended configuration, the issuing address should have none.
        let assets: [String: Value]
        /// ledger_hash    String    (May be omitted) The identifying hash of the ledger that was used to generate this response.
        let ledgerHash: String?
        /// ledger_index    Number    (May be omitted) The sequence number of the ledger version that was used to generate this response.
        let ledgerIndex: Int?
        /// ledger_current_index    Number    (May be omitted) The sequence number of the current in-progress ledger version that was used to generate this response.
        let ledgerCurrentIndex: Int?
        
        init(_ json: AnyReader) throws {
            account = try json.at("account").string()
            obligations = try json.at("obligations").dictionary(_string)
            balances = try json.at("balances").dictionary(Value.init)
            assets = try json.at("assets").dictionary(Value.init)
            ledgerHash = try json.optional("ledger_hash")?.string()
            ledgerIndex = try json.optional("ledger_index")?.int()
            ledgerCurrentIndex = try json.optional("ledger_current_index")?.int()
        }
        
    }
    
    class Value {
        let currency: String
        let value: String
        init(_ json: AnyReader) throws {
            currency = try json.at("currency").string()
            value = try json.at("value").string()
        }
    }
    
    /// account    String    A unique identifier for the account, most commonly the account's address.
    /// role    String    Whether the address refers to a gateway or user. Recommendations depend on the role of the account. Issuers must have DefaultRipple enabled and must disable NoRipple on all trust lines. Users should have DefaultRipple disabled, and should enable NoRipple on all trust lines.
    /// transactions    Boolean    (Optional) If true, include an array of suggested transactions, as JSON objects, that you can sign and submit to fix the problems. Defaults to false.
    /// limit    Unsigned Integer    (Optional) The maximum number of trust line problems to include in the results. Defaults to 300.
    /// ledger_hash    String    (Optional) A 20-byte hex string for the ledger version to use. (See Specifying Ledgers)
    /// ledger_index    String or Unsigned Integer    (Optional) The sequence number of the ledger to use, or a shortcut string to choose a ledger automatically. (See Specifying Ledgers)
    func noripple_check(account: String, role: String, transactions: Bool?, limit: UInt?, ledger: Ledger) -> Promise<NoRippleCheck> {
        let input = JDictionary()
            .set("account", account)
            .set("role", role)
            .set("transactions", transactions)
            .set("limit", limit)
            .set(ledger)
        return network.send("noripple_check", input).map(NoRippleCheck.init)
    }
    
    struct NoRippleCheck {
        /// ledger_current_index    Number    The sequence number of the ledger used to calculate these results.
        let ledger_current_index: Int
        /// problems    Array    Array of strings with human-readable descriptions of the problems. This includes up to one entry if the account's DefaultRipple setting is not as recommended, plus up to limit entries for trust lines whose NoRipple setting is not as recommended.
        let problems: [String]
        /// transactions    Array    (May be omitted) If the request specified transactions as true, this is an array of JSON objects, each of which is the JSON form of a transaction that should fix one of the described problems. The length of this array is the same as the problems array, and each entry is intended to fix the problem described at the same index into that array.
        let transactions: [AnyReader]
        init(_ json: AnyReader) throws {
            ledger_current_index = try json.at("ledger_current_index").int()
            problems = try json.at("problems").array(_string)
            transactions = try json.at("transactions").array()
        }
    }
}
