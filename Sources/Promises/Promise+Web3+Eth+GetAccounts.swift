//
//  Promise+Web3+Eth+GetAccounts.swift
//  web3swift
//
//  Created by Alexander Vlasov on 17.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation
import PromiseKit

extension Web3.Eth {
    public func getAccountsPromise() -> Promise<[Address]> {
        let queue = web3.requestDispatcher.queue
        if web3.provider.attachedKeystoreManager != nil {
            let promise = Promise<[Address]>.pending()
            queue.async {
                do {
                    let accounts = try self.web3.wallet.getAccounts()
                    promise.resolver.fulfill(accounts)
                } catch {
                    promise.resolver.reject(error)
                }
            }
            return promise.promise
        }
        let request = JsonRpcRequestFabric.prepareRequest(.getAccounts, parameters: [])
        let rp = web3.dispatch(request)
        return rp.map(on: queue) { response in
            guard let value: [Address] = response.getValue() else {
                if response.error != nil {
                    throw Web3Error.nodeError(response.error!.message)
                }
                throw Web3Error.nodeError("Invalid value from Ethereum node")
            }
            return value
        }
    }
}
