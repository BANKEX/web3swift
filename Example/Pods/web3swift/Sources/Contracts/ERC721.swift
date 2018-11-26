//
//  ERC721.swift
//  web3swift
//
//  Created by Dmitry on 17/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit


/**
 Native implementation of ERC20 token
 - important: NOT main thread friendly
 */
public class ERC721 {
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
    
    /// Represents Address as ERC721 token (with standart password and options)
    /// - parameter address: Token address
    public init(_ address: Address) {
        self.address = address
    }
    
    /// Represents Address as ERC721 token
    /// - parameter address: Token address
    /// - parameter from: Sender address
    /// - parameter address: Password to decrypt sender's private key
    public init(_ address: Address, from: Address, password: String) {
        self.address = address
        self.password = password
        options.from = from
    }
    
    public func balance(of user: Address) throws -> BigUInt {
        return try address.call("balanceOf(address)",user).wait().uint256()
    }
    /// - returns: address of token holder
    public func owner(of token: BigUInt) throws -> Address {
        return try address.call("ownerOf(uint256)",token).wait().address()
    }
    
    /// Sending approve that another user can take your token
    public func approve(to user: Address, token: BigUInt) throws -> TransactionSendingResult {
        return try address.send("approve(address,uint256)",user,token, password: password, options: options).wait()
    }
    
    /// - returns: address
    public func approved(for token: BigUInt) throws -> Address {
        return try address.call("getApproved(uint256)",token).wait().address()
    }
    /// sets operator for all your tokens
    public func setApproveForAll(operator: Address, approved: Bool) throws -> TransactionSendingResult {
        return try address.send("setApprovalForAll(address,bool)",`operator`,approved, password: password, options: options).wait()
    }
    /// checks if user is approved to manager your tokens
    public func isApprovedForAll(owner: Address, operator: Address) throws -> Bool {
        return try address.call("isApprovedForAll(address,address)",owner,`operator`).wait().bool()
    }
    /// transfers token from one address to another
    /// - important: admin only
    public func transfer(from: Address, to: Address, token: BigUInt) throws -> TransactionSendingResult {
        return try address.send("transferFrom(address,address,uint256)",from,to,token, password: password, options: options).wait()
    }
    
    public func safeTransfer(from: Address, to: Address, token: BigUInt) throws -> TransactionSendingResult {
        return try address.send("safeTransferFrom(address,address,uint256)",from,to,token, password: password, options: options).wait()
    }
    
    /**
     Gas price functions for erc721 token requests
     */
    public struct GasPrice {
        let parent: ERC721
        var address: Address { return parent.address }
        var options: Web3Options { return parent.options }
        
        /**
         Native implementation of ERC20 token
         - important: NOT main thread friendly
         - returns: full information for all pending and queued transactions
         */
        init(_ parent: ERC721) {
            self.parent = parent
        }
        
        /// - returns: gas price for approve(address,uint256) transaction
        public func approve(to user: Address, token: BigUInt) throws -> BigUInt {
            return try address.estimateGas("approve(address,uint256)",user,token, options: options).wait()
        }
        /// - returns: gas price for setApprovalForAll(address,bool) transaction
        public func setApproveForAll(operator: Address, approved: Bool) throws -> BigUInt {
            return try address.estimateGas("setApprovalForAll(address,bool)",`operator`,approved, options: options).wait()
        }
        /// - returns: gas price for transferFrom(address,address,uint256) transaction
        public func transfer(from: Address, to: Address, token: BigUInt) throws -> BigUInt {
            return try address.estimateGas("transferFrom(address,address,uint256)",from,to,token, options: options).wait()
        }
        /// - returns: gas price for safeTransferFrom(address,address,uint256) transaction
        public func safeTransfer(from: Address, to: Address, token: BigUInt) throws -> BigUInt {
            return try address.estimateGas("safeTransferFrom(address,address,uint256)",from,to,token, options: options).wait()
        }
    }
}

