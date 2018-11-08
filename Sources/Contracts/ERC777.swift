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
	/// Token address
	public let address: Address
	/// Transaction options
	public var options: Web3Options = .default
	/// Password to unlock private key for sender address
	public var password: String = "BANKEXFOUNDATION"
	/**
	* Gas price functions if you want to see that
	* Automatically calls if options.gasPrice == nil */
	public var gasPrice: GasPrice { return GasPrice(self) }
	
	/// Represents Address as ERC777 token (with standart password and options)
	/// - parameter address: Token address
	public init(_ address: Address) {
		self.address = address
	}
	
	/// Represents Address as ERC777 token
	/// - parameter address: Token address
	/// - parameter from: Sender address
	/// - parameter address: Password to decrypt sender's private key
	public init(_ address: Address, from: Address, password: String) {
		self.address = address
		self.password = password
		options.from = from
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
    
    public func allowance(from owner: Address, to spender: Address) throws -> BigUInt {
        return try address.call("allowance(address,address)",owner,spender).wait().uint256()
    }
    public func transfer(to user: Address, amount: BigUInt) throws -> TransactionSendingResult {
		return try address.send("transfer(address,uint256)",user,amount, password: password, options: options).wait()
    }
    public func approve(to user: Address, amount: BigUInt) throws -> TransactionSendingResult {
        return try address.send("approve(address,uint256)",user,amount, password: password, options: options).wait()
    }
    public func transfer(from: Address, to: Address, amount: BigUInt) throws -> TransactionSendingResult {
        return try address.send("transferFrom(address,address,uint256)",from,to,amount, password: password, options: options).wait()
    }
    
    public func send(to user: Address, amount: BigUInt) throws -> TransactionSendingResult {
        return try address.send("send(address,uint256)",user,amount, password: password, options: options).wait()
    }
    public func send(to user: Address, amount: BigUInt, userData: Data) throws -> TransactionSendingResult {
        return try address.send("send(address,uint256,bytes)",user,amount,userData, password: password, options: options).wait()
    }
    
    public func authorize(operator user: Address) throws -> TransactionSendingResult {
        return try address.send("authorizeOperator(address)",user, password: password, options: options).wait()
    }
    public func revoke(operator user: Address) throws -> TransactionSendingResult {
        return try address.send("revokeOperator(address)",user, password: password, options: options).wait()
    }
    
    public func isOperatorFor(operator user: Address, tokenHolder: Address) throws -> Bool {
        return try address.call("isOperatorFor(address,address)",user,tokenHolder).wait().bool()
    }
    public func operatorSend(from: Address, to: Address, amount: BigUInt, userData: Data) throws -> TransactionSendingResult {
        return try address.send("operatorSend(address,address,uint256,bytes)",from,to,amount,userData, password: password, options: options).wait()
    }
	
	/**
	Gas price functions for erc721 token requests
	*/
	public struct GasPrice {
		let parent: ERC777
		var address: Address { return parent.address }
		var options: Web3Options { return parent.options }
		
		/**
		Native implementation of ERC20 token
		- important: NOT main thread friendly
		- returns: full information for all pending and queued transactions
		*/
		init(_ parent: ERC777) {
			self.parent = parent
		}
		
		/// - returns: gas price for transfer(address,uint256) transaction
		public func transfer(to user: Address, amount: BigUInt) throws -> BigUInt {
			return try address.estimateGas("transfer(address,uint256)",user,amount, options: options).wait()
		}
		/// - returns: gas price for approve(address,uint256) transaction
		public func approve(to user: Address, amount: BigUInt) throws -> BigUInt {
			return try address.estimateGas("approve(address,uint256)",user,amount, options: options).wait()
		}
		/// - returns: gas price for transferFrom(address,address,uint256) transaction
		public func transfer(from: Address, to: Address, amount: BigUInt) throws -> BigUInt {
			return try address.estimateGas("transferFrom(address,address,uint256)",from,to,amount, options: options).wait()
		}
		
		/// - returns: gas price for send(address,uint256) transaction
		public func send(to user: Address, amount: BigUInt) throws -> BigUInt {
			return try address.estimateGas("send(address,uint256)",user,amount, options: options).wait()
		}
		/// - returns: gas price for send(address,uint256,bytes) transaction
		public func send(to user: Address, amount: BigUInt, userData: Data) throws -> BigUInt {
			return try address.estimateGas("send(address,uint256,bytes)",user,amount,userData, options: options).wait()
		}
		
		/// - returns: gas price for authorizeOperator(address) transaction
		public func authorize(operator user: Address) throws -> BigUInt {
			return try address.estimateGas("authorizeOperator(address)",user, options: options).wait()
		}
		/// - returns: gas price for revokeOperator(address) transaction
		public func revoke(operator user: Address) throws -> BigUInt {
			return try address.estimateGas("revokeOperator(address)",user, options: options).wait()
		}
		
		/// - returns: gas price for operatorSend(address,address,uint256,bytes) transaction
		public func operatorSend(from: Address, to: Address, amount: BigUInt, userData: Data) throws -> BigUInt {
			return try address.estimateGas("operatorSend(address,address,uint256,bytes)",from,to,amount,userData, options: options).wait()
		}
	}
}
