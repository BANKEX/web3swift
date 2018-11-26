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
    case noAccounts
}

/// Wallet functions
public class Web3Wallet {
    /// provider for some functions
    var provider: Web3Provider
    unowned var web3: Web3
    
    /// init with provider and web3 instance
    public init(provider prov: Web3Provider, web3 web3instance: Web3) {
        provider = prov
        web3 = web3instance
    }
    
    /// - returns: all accounts in your keystoreManager
    public func getAccounts() -> [Address] {
        return web3.provider.attachedKeystoreManager.addresses
    }
    
    /// - returns: returns first account in your keystoreManager
    /// - throws:
    /// Web3WalletError.noAccounts
    public func getCoinbase() throws -> Address {
        guard let account = getAccounts().first else { throw Web3WalletError.noAccounts }
        return account
    }

    /// Signs transaction with account
    /// - parameter transaction: transaction to sign
    /// - parameter account: Address that signs message
    /// - parameter password: Password to decrypt account's private key
    /// - throws:
    /// AbstractKeystoreError
    /// Error
    public func signTX(transaction: inout EthereumTransaction, account: Address, password: String = "BANKEXFOUNDATION") throws {
        let keystoreManager = self.web3.provider.attachedKeystoreManager
        try Web3Signer.signTX(transaction: &transaction, keystore: keystoreManager, account: account, password: password)
    }

    
    /// Signs personalMessage with account
    /// - parameter personalMessage: Message to sign
    /// - parameter account: Address that signs message
    /// - parameter password: Password to decrypt account's private key
    /// - returns: signed message
    /// - throws: SECP256K1Error
    /// DataError.hexStringCorrupted(String)
    public func signPersonalMessage(_ personalMessage: String, account: Address, password: String = "BANKEXFOUNDATION") throws -> Data {
        let data = try personalMessage.dataFromHex()
        return try signPersonalMessage(data, account: account, password: password)
    }
    
    /// Signs personalMessage with account
    /// - parameter personalMessage: Message to sign
    /// - parameter account: Address that signs message
    /// - parameter password: Password to decrypt account's private key
    /// - returns: signed message
    /// - throws: SECP256K1Error
    public func signPersonalMessage(_ personalMessage: Data, account: Address, password: String = "BANKEXFOUNDATION") throws -> Data {
        let keystoreManager = self.web3.provider.attachedKeystoreManager
        return try Web3Signer.signPersonalMessage(personalMessage, keystore: keystoreManager, account: account, password: password)
    }
}
