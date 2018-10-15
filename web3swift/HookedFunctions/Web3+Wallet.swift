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

extension Web3.Web3Wallet {
    /// throws Web3WalletError.attachadKeystoreNotFound
    public func getAccounts() throws -> [EthereumAddress] {
        guard let keystoreManager = self.web3.provider.attachedKeystoreManager else { throw Web3WalletError.attachadKeystoreNotFound }
        return keystoreManager.addresses
    }

    /// throws Web3WalletError.attachadKeystoreNotFound
    /// throws Web3WalletError.noAccounts
    public func getCoinbase() throws -> EthereumAddress {
        let accounts = try getAccounts()
        guard let account = accounts.first else { throw Web3WalletError.noAccounts }
        return account
    }

    /// throws Web3WalletError.attachadKeystoreNotFound
    /// throws AbstractKeystoreError
    /// throws Error
    public func signTX(transaction: inout EthereumTransaction, account: EthereumAddress, password: String = "BANKEXFOUNDATION") throws {
        guard let keystoreManager = self.web3.provider.attachedKeystoreManager else { throw Web3WalletError.attachadKeystoreNotFound }
        try Web3Signer.signTX(transaction: &transaction, keystore: keystoreManager, account: account, password: password)
    }

    // from personalMessage.dataFromHex()
    /// throws DataError.hexStringCorrupted(String)
    // from self.signPersonalMessage()
    /// throws Web3WalletError.attachadKeystoreNotFound
    /// throws
    public func signPersonalMessage(_ personalMessage: String, account: EthereumAddress, password: String = "BANKEXFOUNDATION") throws -> Data {
        let data = try personalMessage.dataFromHex()
        return try signPersonalMessage(data, account: account, password: password)
    }

    /// throws SECP256K1Error
    public func signPersonalMessage(_ personalMessage: Data, account: EthereumAddress, password: String = "BANKEXFOUNDATION") throws -> Data {
        guard let keystoreManager = self.web3.provider.attachedKeystoreManager else { throw Web3WalletError.attachadKeystoreNotFound }
        return try Web3Signer.signPersonalMessage(personalMessage, keystore: keystoreManager, account: account, password: password)
    }
}
