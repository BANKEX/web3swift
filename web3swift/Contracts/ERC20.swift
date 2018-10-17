//
//  ERC20.swift
//  web3swift-iOS
//
//  Created by Dmitry on 12/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

public class ERC20 {
    public let address: EthereumAddress
    public init(address: EthereumAddress) {
        self.address = address
    }
    public func name() throws -> String {
        return try address.call("name()").string()
    }
    public func totalSupply() throws -> BigUInt {
        return try address.call("totalSupply()").uint256()
    }
    public func balance(of user: EthereumAddress) throws -> BigUInt {
        return try address.call("balanceOf(address)",user).uint256()
    }
    public func allowance(from owner: EthereumAddress, to spender: EthereumTransaction) throws -> BigUInt {
        return try address.call("allowance(address,address)",owner,spender).uint256()
    }
    public func transfer(to user: EthereumAddress, value: BigUInt) throws -> TransactionSendingResult {
        return try address.send("transfer(address,uint256)",user,value)
    }
    public func approve(to user: EthereumAddress, value: BigUInt) throws -> TransactionSendingResult {
        return try address.send("approve(address,uint256)",user,value)
    }
    public func transfer(from: EthereumAddress, to: EthereumAddress, value: BigUInt) throws -> TransactionSendingResult {
        return try address.send("transferFrom(address,address,uint256)",from,to,value)
    }
}
