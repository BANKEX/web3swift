//
//  Promise+Web3+Eth+SendTransaction.swift
//  web3swift
//
//  Created by Alexander Vlasov on 18.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation
import PromiseKit

extension Web3.Eth {
    func sendTransactionPromise(_ transaction: EthereumTransaction, options: Web3Options, password: String = "BANKEXFOUNDATION") -> Promise<TransactionSendingResult> {
//        print(transaction)
        var assembledTransaction: EthereumTransaction = transaction.mergedWithOptions(options)
        let queue = web3.requestDispatcher.queue
        do {
            if web3.provider.attachedKeystoreManager == nil {
                guard let request = EthereumTransaction.createRequest(method: JSONRPCmethod.sendTransaction, transaction: assembledTransaction, onBlock: nil, options: options) else {
                    throw Web3Error.processingError("Failed to create a request to send transaction")
                }
                return web3.dispatch(request).map(on: queue) { response in
                    guard let value: String = response.getValue() else {
                        if response.error != nil {
                            throw Web3Error.nodeError(response.error!.message)
                        }
                        throw Web3Error.nodeError("Invalid value from Ethereum node")
                    }
                    let result = TransactionSendingResult(transaction: assembledTransaction, hash: value)
                    return result
                }
            }
            guard let from = options.from else {
                throw Web3Error.inputError("No 'from' field provided")
            }
            do {
                try Web3Signer.signTX(transaction: &assembledTransaction, keystore: web3.provider.attachedKeystoreManager!, account: from, password: password)
            } catch {
                throw Web3Error.inputError("Failed to locally sign a transaction")
            }
            return web3.eth.sendRawTransactionPromise(assembledTransaction)
        } catch {
            let returnPromise = Promise<TransactionSendingResult>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
}
