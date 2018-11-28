//
//  Accounts.swift
//  web3swift
//
//  Created by Dmitry on 27/11/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import CryptoSwift

/*
## Version 3

{
  "crypto" : {
    "cipher" : "aes-128-ctr",
    "cipherparams" : {
      "iv" : "83dbcc02d8ccb40e466191a123791e0e"
    },
    "ciphertext" : "d172bf743a674da9cdad04534d56926ef8358534d458fffccd4e6ad2fbde479c",
    "kdf" : "scrypt",
    "kdfparams" : {
      "dklen" : 32,
      "n" : 262144,
      "r" : 1,
      "p" : 8,
      "salt" : "ab0c7876052600dd703518d6fc3fe8984592145b591fc8fb5c6d43190334ba19"
    },
    "mac" : "2103ac29920d71da29f15d75b4a16dbe95cfd7ff8faea1056c33131d846e3097"
  },
  "id" : "3198bc9c-6672-5ab3-d995-4942343ae5b6",
  "version" : 3
}

## Version 2

```
{
  "crypto": {
    "cipher": "aes-128-cbc",
    "ciphertext": "07533e172414bfa50e99dba4a0ce603f654ebfa1ff46277c3e0c577fdc87f6bb4e4fe16c5a94ce6ce14cfa069821ef9b",
    "cipherparams": {
      "iv": "16d67ba0ce5a339ff2f07951253e6ba8"
    },
    "kdf": "scrypt",
    "kdfparams": {
      "dklen": 32,
      "n": 262144,
      "p": 1,
      "r": 8,
      "salt": "06870e5e6a24e183a5c807bd1c43afd86d573f7db303ff4853d135cd0fd3fe91"
    },
    "mac": "8ccded24da2e99a11d48cda146f9cc8213eb423e2ea0d8427f41c3be414424dd",
    "version": 1
  },
  "id": "0498f19a-59db-4d54-ac95-33901b4f1870",
  "version": 2
}
```

## Version 1

```
{
  "Address": "d4584b5f6229b7be90727b0fc8c6b91bb427821f",
  "Crypto": {
    "CipherText": "07533e172414bfa50e99dba4a0ce603f654ebfa1ff46277c3e0c577fdc87f6bb4e4fe16c5a94ce6ce14cfa069821ef9b",
    "IV": "16d67ba0ce5a339ff2f07951253e6ba8",
    "KeyHeader": {
      "Kdf": "scrypt",
      "KdfParams": {
        "DkLen": 32,
        "N": 262144,
        "P": 1,
        "R": 8,
        "SaltLen": 32
      },
      "Version": "1"
    },
    "MAC": "8ccded24da2e99a11d48cda146f9cc8213eb423e2ea0d8427f41c3be414424dd",
    "Salt": "06870e5e6a24e183a5c807bd1c43afd86d573f7db303ff4853d135cd0fd3fe91"
  },
  "Id": "0498f19a-59db-4d54-ac95-33901b4f1870",
  "Version": "1"
}
```
*/

/*
public struct KeystoreParamsV3: Decodable, Encodable {
    var address: String?
    var crypto: CryptoParamsV3
    var id: String?
    var version: Int
    
    /// Init with all params
    public init(address ad: String?, crypto cr: CryptoParamsV3, id i: String, version ver: Int) {
        address = ad
        crypto = cr
        id = i
        version = ver
    }
}
/// Keystore encryption info
public struct CryptoParamsV3: Decodable, Encodable {
    var ciphertext: String
    var cipher: String
    var cipherparams: CipherParamsV3
    var kdf: String
    var kdfparams: KdfParamsV3
    var mac: String
    var version: String?
}
*/





/*
class Accounts {
    var accounts: [LockedAccount]
    init(json: DictionaryReader) throws {
        let version = try json.at("version").int()
        let id = try json.at("id").string()
        
        
        /*
        {
            "crypto" : {
                "cipher" : "aes-128-ctr",
                "cipherparams" : {
                    "iv" : "83dbcc02d8ccb40e466191a123791e0e"
                },
                "ciphertext" : "d172bf743a674da9cdad04534d56926ef8358534d458fffccd4e6ad2fbde479c",
                "kdf" : "scrypt",
                "kdfparams" : {
                    "dklen" : 32,
                    "n" : 262144,
                    "r" : 1,
                    "p" : 8,
                    "salt" : "ab0c7876052600dd703518d6fc3fe8984592145b591fc8fb5c6d43190334ba19"
                },
                "mac" : "2103ac29920d71da29f15d75b4a16dbe95cfd7ff8faea1056c33131d846e3097"
            },
            "id" : "3198bc9c-6672-5ab3-d995-4942343ae5b6",
            "version" : 3
        }
        */
    }
}
*/

class JsonLockedAccount {
    enum ParsingError: Swift.Error {
        case invalidCipherText(String)
    }
    
    let derivedKey: DerivedKey
    let encryptedPrivateKey: Data
    let blockMode: BlockMode
    let mac: Data
    init(json: DictionaryReader) throws {
        let crypto = try json.at("crypto")
        derivedKey = try DerivedKeyType(crypto.at("kdf").string()).derivedKey(crypto.at("kdfparams"))
        
        encryptedPrivateKey = try crypto.at("ciphertext").data()
        guard encryptedPrivateKey.count == 32 else { throw ParsingError.invalidCipherText(encryptedPrivateKey.hex) }
        blockMode = try AesMode(crypto.at("cipher").string()).blockMode(crypto.at("cipherparams").at("iv").data())
        mac = try crypto.at("mac").data()
    }
    
    func unlock(password: Data) throws -> Account {
        let derivedKey = try self.derivedKey.calculate(password: password)
        var dataForMAC = Data()
        dataForMAC.append(derivedKey.suffix(16))
        dataForMAC.append(encryptedPrivateKey)
        let mac = dataForMAC.sha3(.keccak256)
        guard self.mac.constantTimeComparisonTo(mac) else { throw DecryptionError.invalidPassword }
        
        let decryptionKey = derivedKey.suffix(16)
        let aesCipher = try AES(key: decryptionKey.bytes, blockMode: blockMode, padding: .noPadding)
        let privateKey = try aesCipher.decrypt(encryptedPrivateKey.bytes)
        return Account(privateKey: Data(privateKey))
    }
}

class LockedAccount {
    
}

class Account {
    var privateKey: Data
    init(privateKey: Data) {
        self.privateKey = privateKey
    }
}
