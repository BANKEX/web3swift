//
//  Web3+Options.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

public protocol Web3OptionsInheritable {
    var options: Web3Options {get}
}

public struct Web3Options {
    public var to: EthereumAddress? = nil
    public var from: EthereumAddress? = nil
    public var gasLimit: BigUInt? = nil
    public var gasPrice: BigUInt? = nil
    public var value: BigUInt? = nil
    
    public init() {
    }
    
    public static func defaultOptions() -> Web3Options{
        var options = Web3Options()
        options.gasLimit = BigUInt("90000", radix: 10)!
        options.gasPrice = BigUInt("5000000000", radix:10)!
        options.value = BigUInt(0)
        return options
    }
    
    public static func fromJSON(_ json: [String: Any]) -> Web3Options? {
        var options = Web3Options()
        if let gas = json["gas"] as? String, let gasBiguint = BigUInt(gas.stripHexPrefix().lowercased(), radix: 16) {
            options.gasLimit = gasBiguint
        }
        if let gasPrice = json["gasPrice"] as? String, let gasPriceBiguint = BigUInt(gasPrice.stripHexPrefix().lowercased(), radix: 16) {
            options.gasPrice = gasPriceBiguint
        }
        if let value = json["value"] as? String, let valueBiguint = BigUInt(value.stripHexPrefix().lowercased(), radix: 16) {
            options.value = valueBiguint
        }
        if let fromString = json["from"] as? String {
            let addressFrom = EthereumAddress(fromString)
            if addressFrom.isValid {
                options.from = addressFrom
            }
        }
        return options
    }
    
    public static func merge(_ options:Web3Options?, with other:Web3Options?) -> Web3Options? {
        if (other == nil && options == nil) {
            return Web3Options.defaultOptions()
        }
        var newOptions = Web3Options.defaultOptions()
        if (other?.to != nil) {
            newOptions.to = other?.to
        } else {
            newOptions.to = options?.to
        }
        if (other?.from != nil) {
            newOptions.from = other?.from
        } else {
            newOptions.from = options?.from
        }
        if (other?.gasLimit != nil) {
            newOptions.gasLimit = other?.gasLimit
        } else {
            newOptions.gasLimit = options?.gasLimit
        }
        if (other?.gasPrice != nil) {
            newOptions.gasPrice = other?.gasPrice
        } else {
            newOptions.gasPrice = options?.gasPrice
        }
        if (other?.value != nil) {
            newOptions.value = other?.value
        } else {
            newOptions.value = options?.value
        }
        return newOptions
    }
}
