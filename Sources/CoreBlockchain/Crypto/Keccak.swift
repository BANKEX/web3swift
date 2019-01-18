//
//  File.swift
//  web3swift
//
//  Created by Dmitry on 05/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import keccak

extension Data {
    /// - Returns: kaccak256 hash of data
    public func keccak256() -> Data {
        var data = Data(count: 32)
        keccak_256(••••data, 32, •••self, count)
        return data
    }
}
