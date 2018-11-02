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

/**
 Native implementation of ERC20 token
 */
public class ERC20 {
    public let address: Address
    public var options: Web3Options = .default
    public var password: String = "BANKEXFOUNDATION"
    public var gasPrice: ERC20GasPrice { return ERC20GasPrice(self) }
    
    /**
     Native implementation of ERC20 token
     - important: NOT main thread friendly
     - returns: full information for all pending and queued transactions
     */
    public init(_ address: Address) {
        self.address = address
    }
    public init(_ address: Address, from: Address, password: String) {
        self.address = address
        options.from = from
        self.password = password
    }
    public func name() throws -> String {
        return try address.call("name()", options: options).wait().string()
    }
    public func symbol() throws -> String {
        return try address.call("symbol()", options: options).wait().string()
    }
    public func totalSupply() throws -> BigUInt {
        return try address.call("totalSupply()", options: options).wait().uint256()
    }
    public func decimals() throws -> BigUInt {
        return try address.call("decimals()", options: options).wait().uint256()
    }
    public func balance(of user: Address) throws -> BigUInt {
        return try address.call("balanceOf(address)", user, options: options).wait().uint256()
    }
    public func naturalBalance(of user: Address) throws -> String {
        let balance = try address.call("balanceOf(address)", user, options: options).wait().uint256()
        let decimals = try self.decimals()
        return balance.string(unitDecimals: Int(decimals))
    }
    
    public func allowance(from owner: Address, to spender: EthereumTransaction) throws -> BigUInt {
        return try address.call("allowance(address,address)", owner, spender, options: options).wait().uint256()
    }
    
    /**
     transfers to user \(amount)
     - important: Transaction | Requires password | Contract owner only.
     - returns: TransactionSendingResult
     - parameter user: recepient address
     - parameter amount: amount in wei to send. If you want to send 1 token (not 0.00000000001) use NaturalUnits(amount) instead
     */
    public func transfer(to user: Address, amount: BigUInt) throws -> TransactionSendingResult {
        return try address.send("transfer(address,uint256)", user, amount, password: password, options: options).wait()
    }
    /**
     approves user to take \(amount) tokens from your account
     NaturalUnits is user readable representaion of tokens (like "0.01" / "1.543634")
     - important: Transaction | Requires password
     - returns: TransactionSendingResult
     - parameter user: recepient address
     - parameter amount: amount in wei to send. If you want to send 1 token (not 0.00000000001) use NaturalUnits(amount) instead
     */
    public func approve(to user: Address, amount: BigUInt) throws -> TransactionSendingResult {
        
        return try address.send("approve(address,uint256)", user, amount, password: password, options: options).wait()
    }
    
    /**
     transfers from user1 to user2
     NaturalUnits is user readable representaion of tokens (like "0.01" / "1.543634")
     - important: Transaction | Requires password | Contract owner only.
     ERC20(address, from: me).transfer(to: user, amount: NaturalUnits(0.1)) is not the same as
     ERC20(address).transferFrom(owner: me, to: user, amount: NaturalUnits(0.1))
     - returns: TransactionSendingResult
     - parameter user: recepient address
     - parameter amount: amount in wei to send. If you want to send 1 token (not 0.00000000001) use NaturalUnits(amount) instead
     */
    public func transferFrom(owner: Address, to: Address, amount: BigUInt) throws -> TransactionSendingResult {
        return try address.send("transferFrom(address,address,uint256)", owner, to, amount, password: password, options: options).wait()
    }
    
    /**
     transfers to user \(amount)
     NaturalUnits is user readable representaion of tokens (like "0.01" / "1.543634")
     - important: Transaction | Requires password | Contract owner only.
     - returns: TransactionSendingResult
     */
    public func transfer(to user: Address, amount: NaturalUnits) throws -> TransactionSendingResult {
        let decimals = try Int(self.decimals())
        let amount = amount.number(with: decimals)
        return try transfer(to: user, amount: amount)
    }
    /**
     approves user to take \(amount) tokens from your account
     NaturalUnits is user readable representaion of tokens (like "0.01" / "1.543634")
     - important: Transaction | Requires password
     - returns: TransactionSendingResult
     */
    public func approve(to user: Address, amount: NaturalUnits) throws -> TransactionSendingResult {
        let decimals = try Int(self.decimals())
        let amount = amount.number(with: decimals)
        return try transfer(to: user, amount: amount)
    }
    
    /**
     transfers from user1 to user2
     NaturalUnits is user readable representaion of tokens (like "0.01" / "1.543634")
     - important: Transaction | Requires password | Contract owner only.
     ERC20(address, from: me).transfer(to: user, amount: NaturalUnits(0.1)) is not the same as
     ERC20(address).transferFrom(owner: me, to: user, amount: NaturalUnits(0.1))
     - returns: TransactionSendingResult
     */
    public func transferFrom(owner: Address, to: Address, amount: NaturalUnits) throws -> TransactionSendingResult {
        let decimals = try Int(self.decimals())
        let amount = amount.number(with: decimals)
        return try transferFrom(owner: owner, to: to, amount: amount)
    }
}

public struct ERC20GasPrice {
    let erc20: ERC20
    var address: Address { return erc20.address }
    var options: Web3Options { return erc20.options }
    init(_ erc20: ERC20) {
        self.erc20 = erc20
    }
    
    public func transfer(to user: Address, amount: BigUInt) throws -> BigUInt {
        return try address.estimateGas("transfer(address,uint256)", user, amount, options: options).wait()
    }
    public func approve(to user: Address, amount: BigUInt) throws -> BigUInt {
        return try address.estimateGas("approve(address,uint256)", user, amount, options: options).wait()
    }
    public func transferFrom(owner: Address, to: Address, amount: BigUInt) throws -> BigUInt {
        return try address.estimateGas("transferFrom(address,address,uint256)", owner, to, amount, options: options).wait()
    }
    
    /// Transfer functions with NaturalUnits
    public func transfer(to user: Address, amount: NaturalUnits) throws -> BigUInt {
        let decimals = try Int(erc20.decimals())
        let amount = amount.number(with: decimals)
        return try transfer(to: user, amount: amount)
    }
    
    public func approve(to user: Address, amount: NaturalUnits) throws -> BigUInt {
        let decimals = try Int(erc20.decimals())
        let amount = amount.number(with: decimals)
        return try transfer(to: user, amount: amount)
    }
    
    /// contract owner only
    /// transfers from owner to recepient
    public func transferFrom(owner: Address, to: Address, amount: NaturalUnits) throws -> BigUInt {
        let decimals = try Int(erc20.decimals())
        let amount = amount.number(with: decimals)
        return try transferFrom(owner: owner, to: to, amount: amount)
    }
}
