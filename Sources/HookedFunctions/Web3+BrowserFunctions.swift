//
//  Web3+BrowserFunctions.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation

/// Browser functions
public class Web3BrowserFunctions: Web3OptionsInheritable {
    /// provider for some functions
    var provider: Web3Provider
    unowned var web3: Web3
    public var options: Web3Options {
        return web3.options
    }
    
    public init(provider prov: Web3Provider, web3 web3instance: Web3) {
        provider = prov
        web3 = web3instance
    }
    
    public func getAccounts() -> [String]? {
        do {
            return try web3.eth.getAccounts().compactMap { $0.address }
        } catch {
            return nil
        }
    }

    public func getCoinbase() -> String? {
        guard let addresses = self.getAccounts() else { return nil }
        guard addresses.count > 0 else { return nil }
        return addresses[0]
    }

    public func personalSign(_ personalMessage: String, account: String, password: String = "BANKEXFOUNDATION") -> String? {
        return sign(personalMessage, account: account, password: password)
    }

    public func sign(_ personalMessage: String, account: String, password: String = "BANKEXFOUNDATION") -> String? {
        guard let data = Data.fromHex(personalMessage) else { return nil }
        return sign(data, account: account, password: password)
    }

    public func sign(_ personalMessage: Data, account: String, password: String = "BANKEXFOUNDATION") -> String? {
        guard let keystoreManager = self.web3.provider.attachedKeystoreManager else { return nil }
        guard let signature = try? Web3Signer.signPersonalMessage(personalMessage, keystore: keystoreManager, account: Address(account), password: password) else { return nil }
        return signature.toHexString().withHex
    }

    public func personalECRecover(_ personalMessage: String, signature: String) throws -> String {
        return try personalECRecover(personalMessage.dataFromHex(), signature: signature.dataFromHex())
    }

    public func personalECRecover(_ personalMessage: Data, signature: Data) throws -> String {
        try signature.checkSignatureSize()
        let rData = signature[0 ..< 32].bytes
        let sData = signature[32 ..< 64].bytes
        let vData = signature[64]
        let signatureData = try SECP256K1.marshalSignature(v: vData, r: rData, s: sData)
        var hash: Data
        if personalMessage.count == 32 {
            print("Most likely it's hash already, allow for now")
            hash = personalMessage
        } else {
            hash = try Web3Utils.hashPersonalMessage(personalMessage)
        }
        let publicKey = try SECP256K1.recoverPublicKey(hash: hash, signature: signatureData)
        return try Web3Utils.publicToAddressString(publicKey)
    }

    public func sendTransaction(_ json: [String: Any], password: String = "BANKEXFOUNDATION") throws -> String {
        let transaction = try EthereumTransaction(json)
        let options = try Web3Options(json)
        return try sendTransaction(transaction, options: options, password: password)
    }

    public func sendTransaction(_ transaction: EthereumTransaction, options: Web3Options, password: String = "BANKEXFOUNDATION") throws -> String {
        return try web3.eth.sendTransaction(transaction, options: options, password: password).hash
    }

    public func estimateGas(_ json: [String: Any]) throws -> BigUInt {
        let transaction = try EthereumTransaction(json)
        let options = try Web3Options(json)
        return try estimateGas(transaction, options: options)
    }

    public func estimateGas(_ transaction: EthereumTransaction, options: Web3Options) throws -> BigUInt {
        return try web3.eth.estimateGas(transaction, options: options)
    }

    public func prepareTxForApproval(_ json: [String: Any]) throws -> (transaction: EthereumTransaction, options: Web3Options) {
        let transaction = try EthereumTransaction(json)
        let options = try Web3Options(json)
        return try prepareTxForApproval(transaction, options: options)
    }

    public enum TransactionError: Error {
        case optionsFromNotFound
        case keystoreManagerNotFound
        case privateKeyNotFound(forAddress: Address)
        case cannotEncodeTransaction
    }

    public func prepareTxForApproval(_ trans: EthereumTransaction, options opts: Web3Options) throws -> (transaction: EthereumTransaction, options: Web3Options) {
        var transaction = trans
        var options = opts
        guard options.from != nil else { throw TransactionError.optionsFromNotFound }
        let gasPrice = try web3.eth.getGasPrice()
        transaction.gasPrice = gasPrice
        options.gasPrice = gasPrice
        let gasLimit = try estimateGas(transaction, options: options)
        transaction.gasLimit = gasLimit
        options.gasLimit = gasLimit
        print(transaction)
        return (transaction, options)
    }

    public func signTransaction(_ json: [String: Any], password: String = "BANKEXFOUNDATION") throws -> String {
        let transaction = try EthereumTransaction(json)
        let options = try Web3Options(json)
        return try signTransaction(transaction, options: options, password: password)
    }

    public func signTransaction(_ trans: EthereumTransaction, options: Web3Options, password: String = "BANKEXFOUNDATION") throws -> String {
        var transaction = trans
        guard let from = options.from else { throw TransactionError.optionsFromNotFound }
        guard let keystoreManager = self.web3.provider.attachedKeystoreManager else { throw TransactionError.keystoreManagerNotFound }
        let gasPrice = try web3.eth.getGasPrice()
        transaction.gasPrice = gasPrice
        let gasLimit = try estimateGas(transaction, options: options)
        transaction.gasLimit = gasLimit

        transaction.nonce = try web3.eth.getTransactionCount(address: from, onBlock: "pending")

        if web3.provider.network != nil {
            transaction.chainID = web3.provider.network
        }

        guard let keystore = keystoreManager.walletForAddress(from) else { throw TransactionError.privateKeyNotFound(forAddress: from) }
        try Web3Signer.signTX(transaction: &transaction, keystore: keystore, account: from, password: password)
        print(transaction)
        guard let signedData = transaction.encode(forSignature: false, chainId: nil)?.toHexString().withHex else { throw TransactionError.cannotEncodeTransaction }
        return signedData
    }
}
