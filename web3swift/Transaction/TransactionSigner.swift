//
//  TransactionSigner.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation

public enum TransactionSignerError: Error {
    case signatureError(String)
}

public struct Web3Signer {
    public static func signTX(transaction: inout EthereumTransaction, keystore: AbstractKeystore, account: EthereumAddress, password: String, useExtraEntropy: Bool = false) throws {
        var privateKey = try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
        defer { Data.zero(&privateKey) }
        if transaction.chainID != nil {
            try EIP155Signer.sign(transaction: &transaction, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
        } else {
            try FallbackSigner.sign(transaction: &transaction, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
        }
    }

    public static func signIntermediate(intermediate: inout TransactionIntermediate, keystore: AbstractKeystore, account: EthereumAddress, password: String, useExtraEntropy: Bool = false) throws {
        var tx = intermediate.transaction
        try Web3Signer.signTX(transaction: &tx, keystore: keystore, account: account, password: password, useExtraEntropy: useExtraEntropy)
        intermediate.transaction = tx
    }

    /// throws Web3UtilsError.cannotConvertDataToAscii
    /// throws SECP256K1Error
    /// throws AbstractKeystoreError
    public static func signPersonalMessage(_ personalMessage: Data, keystore: AbstractKeystore, account: EthereumAddress, password: String, useExtraEntropy: Bool = false) throws -> Data {
        var privateKey = try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
        defer { Data.zero(&privateKey) }
        let hash = try Web3.Utils.hashPersonalMessage(personalMessage)
        return try SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy).serializedSignature
    }

    public struct EIP155Signer {
        public static func sign(transaction: inout EthereumTransaction, privateKey: Data, useExtraEntropy: Bool = false) throws {
            for _ in 0 ..< 1024 {
                do {
                    try attemptSignature(transaction: &transaction, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
                    return
                } catch {}
            }
            throw AbstractKeystoreError.invalidAccountError
        }

        public enum Error: Swift.Error {
            case chainIdNotFound
            case hashNotFound
            case recoveredPublicKeyCorrupted
        }

        private static func attemptSignature(transaction: inout EthereumTransaction, privateKey: Data, useExtraEntropy: Bool = false) throws {
            guard let chainID = transaction.chainID else { throw Error.chainIdNotFound }
            guard let hash = transaction.hashForSignature(chainID: chainID) else { throw Error.hashNotFound }
            let signature = try SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
            let unmarshalledSignature = try SECP256K1.unmarshalSignature(signatureData: signature.serializedSignature)
            let originalPublicKey = try SECP256K1.privateToPublic(privateKey: privateKey)
            transaction.v = BigUInt(unmarshalledSignature.v) + 35 + chainID.rawValue + chainID.rawValue
            transaction.r = BigUInt(Data(unmarshalledSignature.r))
            transaction.s = BigUInt(Data(unmarshalledSignature.s))
            let recoveredPublicKey = transaction.recoverPublicKey()
            guard originalPublicKey.constantTimeComparisonTo(recoveredPublicKey) else { throw Error.recoveredPublicKeyCorrupted }
        }
    }

    public struct FallbackSigner {
        public static func sign(transaction: inout EthereumTransaction, privateKey: Data, useExtraEntropy _: Bool = false) throws {
            for _ in 0 ..< 1024 {
                do {
                    try attemptSignature(transaction: &transaction, privateKey: privateKey)
                    return
                } catch {}
            }
            throw AbstractKeystoreError.invalidAccountError
        }

        public enum Error: Swift.Error {
            case chainIdNotFound
            case hashNotFound
            case recoveredPublicKeyCorrupted
        }

        private static func attemptSignature(transaction: inout EthereumTransaction, privateKey: Data, useExtraEntropy: Bool = false) throws {
            guard let hash = transaction.hashForSignature(chainID: nil) else { throw Error.hashNotFound }
            let signature = try SECP256K1.signForRecovery(hash: hash, privateKey: privateKey, useExtraEntropy: useExtraEntropy)
            let unmarshalledSignature = try SECP256K1.unmarshalSignature(signatureData: signature.serializedSignature)
            let originalPublicKey = try SECP256K1.privateToPublic(privateKey: privateKey)
            transaction.chainID = nil
            transaction.v = BigUInt(unmarshalledSignature.v) + BigUInt(27)
            transaction.r = BigUInt(Data(unmarshalledSignature.r))
            transaction.s = BigUInt(Data(unmarshalledSignature.s))
            let recoveredPublicKey = transaction.recoverPublicKey()
            guard originalPublicKey.constantTimeComparisonTo(recoveredPublicKey) else { throw Error.recoveredPublicKeyCorrupted }
        }
    }
}
