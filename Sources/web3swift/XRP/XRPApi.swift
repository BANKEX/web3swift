//
//  XRPApi.swift
//  web3swift
//
//  Created by Dmitry on 21/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

extension URL {
    static var xrpMainnet = URL(string: "https://s2.ripple.com:51234")!
    static var xrpTestnet = URL(string: "https://s.altnet.rippletest.net:51234")!
}

let xrp = XRPApi.mainnet
class XRPApi {
    let network: NetworkProvider
    init(network: NetworkProvider) {
        self.network = network
    }
    static var mainnet: XRPApi {
        return XRPApi(network: NetworkProvider(url: .xrpMainnet))
    }
    static var testnet: XRPApi {
        return XRPApi(network: NetworkProvider(url: .xrpTestnet))
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
    func channels(account: String, destinationAccount: String?, ledgerHash: String?, ledgerIndex: String?, limit: Int?) -> Promise<[XRPAccountChannel]> {
        let input = JDictionary()
            .set("account", account)
            .set("destination_account", destinationAccount)
            .set("ledger_hash", ledgerHash)
            .set("ledger_index", ledgerIndex)
            .set("limit", limit)
        return network.send("account_channels", input).array(XRPAccountChannel.init)
    }
}

class XRPAccountChannel {
    /// The owner of the channel, as an Address.
    let account: XRPAddress
    /// The total amount of XRP, in drops allocated to this channel.
    let amount: BigUInt
    /// The total amount of XRP, in drops, paid out from this channel, as of the ledger version used. (You can calculate the amount of XRP left in the channel by subtracting balance from amount.)
    let balance: BigUInt
    /// A unique ID for this channel, as a 64-character hexadecimal string. This is also the ID of the channel object in the ledger's state data.
    let channelId: Data
    /// the destination account of the channel, as an Address. Only this account can receive the XRP in the channel while it is open.
    let destinationAccount: XRPAddress
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
        account = try json.at("account").xrpAddress()
        amount = try json.at("amount").uint256()
        balance = try json.at("balance").uint256()
        channelId = try json.at("channel_id").data()
        destinationAccount = try json.at("destinationAccount").xrpAddress()
        publicKey = try json.at("public_key").data()
        settleDelay = try json.at("settle_delay").int()
        expiration = try json.optional("expiration")?.int()
        cancelAfter = try json.optional("cancel_after")?.int()
        sourceTag = try json.optional("source_tag")?.uint64()
        destinationTag = try json.optional("destinationTag")?.uint64()
    }
}

extension AnyReader {
    func xrpBase58() throws -> Data {
        let string = try self.string()
        guard let data = string.base58(.ripple) else { throw unconvertible(to: "base58 data") }
        return data
    }
    func xrpAddress() throws -> XRPAddress {
        let data = try xrpBase58()
        return XRPAddress(data)
    }
}
