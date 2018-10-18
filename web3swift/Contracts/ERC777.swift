//
//  ERC777.swift
//  web3swift
//
//  Created by Dmitry on 17/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

public class ERC777 {
    public let address: EthereumAddress
    public init(_ address: EthereumAddress) {
        self.address = address
    }
    
    public func name() throws -> String {
        return try address.call("name()").wait().string()
    }
    public func symbol() throws -> String {
        return try address.call("symbol()").wait().string()
    }
    public func totalSupply() throws -> BigUInt {
        return try address.call("totalSupply()").wait().uint256()
    }
    public func decimals() throws -> BigUInt {
        return try address.call("decimals()").wait().uint256()
    }
    public func balance(of user: EthereumAddress) throws -> BigUInt {
        return try address.call("balanceOf(address)",user).wait().uint256()
    }
    
    public func allowance(from owner: EthereumAddress, to spender: EthereumTransaction) throws -> BigUInt {
        return try address.call("allowance(address,address)",owner,spender).wait().uint256()
    }
    public func transfer(to user: EthereumAddress, amount: BigUInt) throws -> TransactionSendingResult {
        return try address.send("transfer(address,uint256)",user,amount).wait()
    }
    public func approve(to user: EthereumAddress, amount: BigUInt) throws -> TransactionSendingResult {
        return try address.send("approve(address,uint256)",user,amount).wait()
    }
    public func transfer(from: EthereumAddress, to: EthereumAddress, amount: BigUInt) throws -> TransactionSendingResult {
        return try address.send("transferFrom(address,address,uint256)",from,to,amount).wait()
    }
    
    public func send(to user: EthereumAddress, amount: BigUInt) throws -> TransactionSendingResult {
        return try address.send("send(address,uint256)",user,amount).wait()
    }
    public func send(to user: EthereumAddress, amount: BigUInt, userData: Data) throws -> TransactionSendingResult {
        return try address.send("send(address,uint256,bytes)",user,amount,userData).wait()
    }
    
    public func authorize(operator user: EthereumAddress) throws -> TransactionSendingResult {
        return try address.send("authorizeOperator(address)",user).wait()
    }
    public func revoke(operator user: EthereumAddress) throws -> TransactionSendingResult {
        return try address.send("revokeOperator(address)",user).wait()
    }
    
    public func isOperatorFor(operator user: EthereumAddress, tokenHolder: EthereumAddress) throws -> Bool {
        return try address.call("isOperatorFor(address,address)",user,tokenHolder).wait().bool()
    }
    public func operatorSend(from: EthereumAddress, to: EthereumAddress, amount: BigUInt, userData: Data) throws -> TransactionSendingResult {
        return try address.send("operatorSend(address,address,uint256,bytes)",from,to,amount,userData).wait()
    }
}
