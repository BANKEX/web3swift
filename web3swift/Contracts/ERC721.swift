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
    public let address: EthereumAddress
    public init(_ address: EthereumAddress) {
        self.address = address
    }
    public func balance(of user: EthereumAddress) throws -> BigUInt {
        return try address.call("balanceOf(address)",user).wait().uint256()
    }
    public func owner(of token: BigUInt) throws -> EthereumAddress {
        return try address.call("ownerOf(uint256)",token).wait().address()
    }
    
    public func approve(to user: EthereumAddress, token: BigUInt) throws -> TransactionSendingResult {
        return try address.send("approve(address,uint256)",user,token).wait()
    }
    public func approved(for token: BigUInt) throws -> EthereumAddress {
        return try address.call("getApproved(uint256)",token).wait().address()
    }
    
    public func setApproveForAll(operator: EthereumAddress, approved: Bool) throws -> TransactionSendingResult {
        return try address.send("setApprovalForAll(address,bool)",`operator`,approved).wait()
    }
    public func isApprovedForAll(owner: EthereumAddress, operator: EthereumAddress) throws -> Bool {
        return try address.call("isApprovedForAll(address,address)",owner,`operator`).wait().bool()
    }
    
    public func transfer(from: EthereumAddress, to: EthereumAddress, token: BigUInt) throws -> TransactionSendingResult {
        return try address.send("transferFrom(address,address,uint256)",from,to,token).wait()
    }
    public func safeTransfer(from: EthereumAddress, to: EthereumAddress, token: BigUInt) throws -> TransactionSendingResult {
        return try address.send("safeTransferFrom(address,address,uint256)",from,to,token).wait()
    }
}


