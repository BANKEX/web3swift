//
//  KeystoreManager.swift
//  web3swift
//
//  Created by Alexander Vlasov on 04.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation

public class KeystoreManager: AbstractKeystore {
    public var isEmpty: Bool { return bip32keystores.isEmpty && keystores.isEmpty && plainKeystores.isEmpty }
    public var isHDKeystore: Bool { return !bip32keystores.isEmpty }
    public var addresses: [Address] {
        var toReturn = [Address]()
        for keystore in keystores {
            guard let key = keystore.addresses.first else { continue }
            if key.isValid {
                toReturn.append(key)
            }
        }
        for keystore in bip32keystores {
            let allAddresses = keystore.addresses
            for addr in allAddresses {
                if addr.isValid {
                    toReturn.append(addr)
                }
            }
        }
        for keystore in plainKeystores {
            guard let key = keystore.addresses.first else { continue }
            if key.isValid {
                toReturn.append(key)
            }
        }
        return toReturn
    }

    public func UNSAFE_getPrivateKeyData(password: String = "BANKEXFOUNDATION", account: Address) throws -> Data {
        guard let keystore = self.walletForAddress(account) else { throw AbstractKeystoreError.invalidAccountError }
        return try keystore.UNSAFE_getPrivateKeyData(password: password, account: account)
    }

    public static var all = [KeystoreManager]()
    public static var `default`: KeystoreManager? {
        if KeystoreManager.all.count == 0 {
            return nil
        }
        return KeystoreManager.all[0]
    }

    public static func managerForPath(_ path: String, scanForHDwallets: Bool = false, suffix: String? = nil) -> KeystoreManager? {
        guard let newManager = try? KeystoreManager(path, scanForHDwallets: scanForHDwallets, suffix: suffix), let manager = newManager else { return nil }
        return manager
    }

    public func walletForAddress(_ address: Address) -> AbstractKeystore? {
        for keystore in keystores {
            guard let key = keystore.addresses.first else { continue }
            if key == address && key.isValid {
                return keystore as AbstractKeystore?
            }
        }
        for keystore in bip32keystores {
            let allAddresses = keystore.addresses
            for addr in allAddresses {
                if addr == address && addr.isValid {
                    return keystore as AbstractKeystore?
                }
            }
        }
        for keystore in plainKeystores {
            guard let key = keystore.addresses.first else { continue }
            if key == address && key.isValid {
                return keystore as AbstractKeystore?
            }
        }
        return nil
    }

    public var keystores = [EthereumKeystoreV3]()
    public var bip32keystores = [BIP32Keystore]()
    public var plainKeystores = [PlainKeystore]()

    public init(_ keystores: [EthereumKeystoreV3]) {
        self.keystores = keystores
    }
    public init(_ keystores: [BIP32Keystore]) {
        bip32keystores = keystores
    }
    public init(_ keystores: [PlainKeystore]) {
        plainKeystores = keystores
    }
    public init() {
        
    }
    
    public func append(_ keystore: EthereumKeystoreV3) {
        keystores.append(keystore)
    }
    public func append(_ keystore: BIP32Keystore) {
        bip32keystores.append(keystore)
    }
    public func append(_ keystore: PlainKeystore) {
        plainKeystores.append(keystore)
    }

    private init?(_ path: String, scanForHDwallets: Bool = false, suffix: String? = nil) throws {
        let fileManager = FileManager.default
        var isDir: ObjCBool = false
        var exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
        if !exists && !isDir.boolValue {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            exists = fileManager.fileExists(atPath: path, isDirectory: &isDir)
        }
        if !isDir.boolValue {
            return nil
        }
        let allFiles = try fileManager.contentsOfDirectory(atPath: path)
        if suffix != nil {
            for file in allFiles where file.hasSuffix(suffix!) {
                var filePath = path
                if !path.hasSuffix("/") {
                    filePath = path + "/"
                }
                filePath = filePath + file
                guard let content = fileManager.contents(atPath: filePath) else { continue }
                if !scanForHDwallets {
                    guard let keystore = EthereumKeystoreV3(content) else { continue }
                    keystores.append(keystore)
                } else {
                    guard let bipkeystore = BIP32Keystore(content) else { continue }
                    bip32keystores.append(bipkeystore)
                }
            }
        } else {
            for file in allFiles {
                var filePath = path
                if !path.hasSuffix("/") {
                    filePath = path + "/"
                }
                filePath = filePath + file
                guard let content = fileManager.contents(atPath: filePath) else { continue }
                if !scanForHDwallets {
                    guard let keystore = EthereumKeystoreV3(content) else { continue }
                    keystores.append(keystore)
                } else {
                    guard let bipkeystore = BIP32Keystore(content) else { continue }
                    bip32keystores.append(bipkeystore)
                }
            }
        }
    }
}
