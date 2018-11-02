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
    public let address: Address
    public init(_ address: Address) {
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
    public func balance(of user: Address) throws -> BigUInt {
        return try address.call("balanceOf(address)",user).wait().uint256()
    }
    
    public func allowance(from owner: Address, to spender: EthereumTransaction) throws -> BigUInt {
        return try address.call("allowance(address,address)",owner,spender).wait().uint256()
    }
    public func transfer(to user: Address, amount: BigUInt) throws -> TransactionSendingResult {
        return try address.send("transfer(address,uint256)",user,amount).wait()
    }
    public func approve(to user: Address, amount: BigUInt) throws -> TransactionSendingResult {
        return try address.send("approve(address,uint256)",user,amount).wait()
    }
    public func transfer(from: Address, to: Address, amount: BigUInt) throws -> TransactionSendingResult {
        return try address.send("transferFrom(address,address,uint256)",from,to,amount).wait()
    }
    
    public func send(to user: Address, amount: BigUInt) throws -> TransactionSendingResult {
        return try address.send("send(address,uint256)",user,amount).wait()
    }
    public func send(to user: Address, amount: BigUInt, userData: Data) throws -> TransactionSendingResult {
        return try address.send("send(address,uint256,bytes)",user,amount,userData).wait()
    }
    
    public func authorize(operator user: Address) throws -> TransactionSendingResult {
        return try address.send("authorizeOperator(address)",user).wait()
    }
    public func revoke(operator user: Address) throws -> TransactionSendingResult {
        return try address.send("revokeOperator(address)",user).wait()
    }
    
    public func isOperatorFor(operator user: Address, tokenHolder: Address) throws -> Bool {
        return try address.call("isOperatorFor(address,address)",user,tokenHolder).wait().bool()
    }
    public func operatorSend(from: Address, to: Address, amount: BigUInt, userData: Data) throws -> TransactionSendingResult {
        return try address.send("operatorSend(address,address,uint256,bytes)",from,to,amount,userData).wait()
    }
}
