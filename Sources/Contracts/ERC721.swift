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

public class ERC721 {
    public let address: Address
    public var gasPrice: ERC721GasPrice { return ERC721GasPrice(self) }
    public var options: Web3Options = .default
    public var password: String = "BANKEXFOUNDATION"
    public init(_ address: Address) {
        self.address = address
    }
    public init(_ address: Address, from: Address, password: String) {
        self.address = address
        self.password = password
        options.from = from
    }
    public func balance(of user: Address) throws -> BigUInt {
        return try address.call("balanceOf(address)",user).wait().uint256()
    }
    public func owner(of token: BigUInt) throws -> Address {
        return try address.call("ownerOf(uint256)",token).wait().address()
    }
    
    public func approve(to user: Address, token: BigUInt) throws -> TransactionSendingResult {
        return try address.send("approve(address,uint256)",user,token).wait()
    }
    public func approved(for token: BigUInt) throws -> Address {
        return try address.call("getApproved(uint256)",token).wait().address()
    }
    
    public func setApproveForAll(operator: Address, approved: Bool) throws -> TransactionSendingResult {
        return try address.send("setApprovalForAll(address,bool)",`operator`,approved).wait()
    }
    public func isApprovedForAll(owner: Address, operator: Address) throws -> Bool {
        return try address.call("isApprovedForAll(address,address)",owner,`operator`).wait().bool()
    }
    
    public func transfer(from: Address, to: Address, token: BigUInt) throws -> TransactionSendingResult {
        return try address.send("transferFrom(address,address,uint256)",from,to,token).wait()
    }
    public func safeTransfer(from: Address, to: Address, token: BigUInt) throws -> TransactionSendingResult {
        return try address.send("safeTransferFrom(address,address,uint256)",from,to,token).wait()
    }
}




public struct ERC721GasPrice {
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
    
    public func approve(to user: Address, token: BigUInt) throws -> BigUInt {
        return try address.estimateGas("approve(address,uint256)",user,token).wait()
    }
    public func setApproveForAll(operator: Address, approved: Bool) throws -> BigUInt {
        return try address.estimateGas("setApprovalForAll(address,bool)",`operator`,approved).wait()
    }
    public func transfer(from: Address, to: Address, token: BigUInt) throws -> BigUInt {
        return try address.estimateGas("transferFrom(address,address,uint256)",from,to,token).wait()
    }
    public func safeTransfer(from: Address, to: Address, token: BigUInt) throws -> BigUInt {
        return try address.estimateGas("safeTransferFrom(address,address,uint256)",from,to,token).wait()
    }
}
