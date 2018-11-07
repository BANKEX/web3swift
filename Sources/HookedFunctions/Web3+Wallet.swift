//
import BigInt
//  Web3+HookedWallet.swift
//  web3swift
//
//  Created by Alexander Vlasov on 07.01.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
import Foundation

public enum Web3WalletError: Error {
    case attachadKeystoreNotFound
    case noAccounts
}

/// Wallet functions
public class Web3Wallet {
    /// provider for some functions
    var provider: Web3Provider
    unowned var web3: Web3
    public init(provider prov: Web3Provider, web3 web3instance: Web3) {
        provider = prov
        web3 = web3instance
    }
    
    /// - throws: Web3WalletError.attachadKeystoreNotFound
    public func getAccounts() throws -> [Address] {
        guard let keystoreManager = self.web3.provider.attachedKeystoreManager else { throw Web3WalletError.attachadKeystoreNotFound }
        return keystoreManager.addresses
    }

    /// - throws:
    /// Web3WalletError.attachadKeystoreNotFound
    /// Web3WalletError.noAccounts
    public func getCoinbase() throws -> Address {
        let accounts = try getAccounts()
        guard let account = accounts.first else { throw Web3WalletError.noAccounts }
        return account
    }

    /// - throws:
    /// Web3WalletError.attachadKeystoreNotFound
    /// AbstractKeystoreError
    /// Error
    public func signTX(transaction: inout EthereumTransaction, account: Address, password: String = "BANKEXFOUNDATION") throws {
        guard let keystoreManager = self.web3.provider.attachedKeystoreManager else { throw Web3WalletError.attachadKeystoreNotFound }
        try Web3Signer.signTX(transaction: &transaction, keystore: keystoreManager, account: account, password: password)
    }

    
    /// - throws:
    /// DataError.hexStringCorrupted(String)
    /// Web3WalletError.attachadKeystoreNotFound
    public func signPersonalMessage(_ personalMessage: String, account: Address, password: String = "BANKEXFOUNDATION") throws -> Data {
        let data = try personalMessage.dataFromHex()
        return try signPersonalMessage(data, account: account, password: password)
    }

    /// - throws: SECP256K1Error
    public func signPersonalMessage(_ personalMessage: Data, account: Address, password: String = "BANKEXFOUNDATION") throws -> Data {
        guard let keystoreManager = self.web3.provider.attachedKeystoreManager else { throw Web3WalletError.attachadKeystoreNotFound }
        return try Web3Signer.signPersonalMessage(personalMessage, keystore: keystoreManager, account: account, password: password)
    }
}
