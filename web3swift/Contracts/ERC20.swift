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
    public var options: Web3Options = .default
    public var gasPrice: ERC20GasPrice { return ERC20GasPrice(self) }
    public init(_ address: EthereumAddress) {
        self.address = address
    }
    public init(_ address: EthereumAddress, from: EthereumAddress) {
        self.address = address
        options.from = from
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
    public func balance(of user: EthereumAddress) throws -> BigUInt {
        return try address.call("balanceOf(address)", user, options: options).wait().uint256()
    }
    
    public func allowance(from owner: EthereumAddress, to spender: EthereumTransaction) throws -> BigUInt {
        
        return try address.call("allowance(address,address)", owner, spender, options: options).wait().uint256()
    }
    
    public func transfer(to user: EthereumAddress, amount: BigUInt) throws -> TransactionSendingResult {
        return try address.send("transfer(address,uint256)", user, amount, options: options).wait()
    }
    public func approve(to user: EthereumAddress, amount: BigUInt) throws -> TransactionSendingResult {
        return try address.send("approve(address,uint256)", user, amount, options: options).wait()
    }
    public func transferFrom(owner: EthereumAddress, to: EthereumAddress, amount: BigUInt) throws -> TransactionSendingResult {
        return try address.send("transferFrom(address,address,uint256)", owner, to, amount, options: options).wait()
    }
    
    /// Transfer functions with NaturalUnits
    public func transfer(to user: EthereumAddress, amount: NaturalUnits) throws -> TransactionSendingResult {
        let decimals = try Int(self.decimals())
        let amount = amount.number(with: decimals)
        return try transfer(to: user, amount: amount)
    }
    public func approve(to user: EthereumAddress, amount: NaturalUnits) throws -> TransactionSendingResult {
        let decimals = try Int(self.decimals())
        let amount = amount.number(with: decimals)
        return try transfer(to: user, amount: amount)
    }
    public func transferFrom(owner: EthereumAddress, to: EthereumAddress, amount: NaturalUnits) throws -> TransactionSendingResult {
        let decimals = try Int(self.decimals())
        let amount = amount.number(with: decimals)
        return try transferFrom(owner: owner, to: to, amount: amount)
    }
}

public struct ERC20GasPrice {
    let erc20: ERC20
    var address: EthereumAddress { return erc20.address }
    var options: Web3Options { return erc20.options }
    init(_ erc20: ERC20) {
        self.erc20 = erc20
    }
    
    public func transfer(to user: EthereumAddress, amount: BigUInt) throws -> BigUInt {
        return try address.estimateGas("transfer(address,uint256)", user, amount, options: options).wait()
    }
    public func approve(to user: EthereumAddress, amount: BigUInt) throws -> BigUInt {
        return try address.estimateGas("approve(address,uint256)", user, amount, options: options).wait()
    }
    public func transferFrom(owner: EthereumAddress, to: EthereumAddress, amount: BigUInt) throws -> BigUInt {
        return try address.estimateGas("transferFrom(address,address,uint256)", owner, to, amount, options: options).wait()
    }
    
    /// Transfer functions with NaturalUnits
    public func transfer(to user: EthereumAddress, amount: NaturalUnits) throws -> BigUInt {
        let decimals = try Int(erc20.decimals())
        let amount = amount.number(with: decimals)
        return try transfer(to: user, amount: amount)
    }
    public func approve(to user: EthereumAddress, amount: NaturalUnits) throws -> BigUInt {
        let decimals = try Int(erc20.decimals())
        let amount = amount.number(with: decimals)
        return try transfer(to: user, amount: amount)
    }
    public func transferFrom(owner: EthereumAddress, to: EthereumAddress, amount: NaturalUnits) throws -> BigUInt {
        let decimals = try Int(erc20.decimals())
        let amount = amount.number(with: decimals)
        return try transferFrom(owner: owner, to: to, amount: amount)
    }
}
