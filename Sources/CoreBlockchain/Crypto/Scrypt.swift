//
//  scrypt.swift
//  web3swift
//
//  Created by Dmitry on 05/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import scrypt

enum ScryptError: Error {
    case failed(code: Int32)
}

public func scrypt(password: String, salt: Data, length: Int, N: Int, R: Int, P: Int) throws -> Data {
    let password = password.data
    var derivedKey = Data(count: length)
    let status = crypto_scrypt(•••password, password.count, •••salt, salt.count, UInt64(N), UInt32(R), UInt32(P), ••••derivedKey, derivedKey.count)
    guard status == 0 else { throw ScryptError.failed(code: status) }
    return derivedKey
}
