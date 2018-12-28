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
    
    /// The account_channels method returns information about an account's Payment Channels. This includes only channels where the specified account is the channel's source, not the destination. (A channel's "source" and "owner" are the same.) All information retrieved is relative to a particular version of the ledger.
    ///
    /// - Parameters:
    ///   - account: The unique identifier of an account, typically the account's Address. The request returns channels where this account is the channel's owner/source.
    ///   - destinationAccount: The unique identifier of an account, typically the account's Address. If provided, filter results to payment channels whose destination is this account.
    ///   - ledgerHash: A 20-byte hex string for the ledger version to use. (See Specifying Ledgers)
    ///   - ledgerIndex: The sequence number of the ledger to use, or a shortcut string to choose a ledger automatically. (See Specifying Ledgers)
    ///   - limit: Limit the number of transactions to retrieve. The server is not required to honor this value. Must be within the inclusive range 10 to 400. Defaults to 200.
    ///   - marker: Value from a previous paginated response. Resume retrieving data where that response left off.
//    func channels(account: String, destinationAccount: String?, ledgerHash: String?, ledgerIndex: String?, limit: Int?) -> Promise<[Channel]> {
//        let input = JDictionary()
//            .set("account", account)
//            .set("destination_account", destinationAccount)
//            .set("ledger_hash", ledgerHash)
//            .set("ledger_index", ledgerIndex)
//            .set("limit", limit)ssFkxuEj1WB1xyumnNAfNMUqUMuWJ
//        return network.send("account_channels", input).array(Channel.init)
//    }
}
