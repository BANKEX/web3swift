//
//  Web3+Protocols.swift
//  web3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation
import class PromiseKit.Promise

/// Protocol for generic Ethereum event parser
public protocol EventParserProtocol {
    /**
     Parses the transaction for events matching the EventParser settings.
     - Parameter transaction: web3swift native EthereumTransaction object
     - Returns: array of events
     - Important: This call is synchronous
     */
    func parseTransaction(_ transaction: EthereumTransaction) throws -> [EventParserResult]
    
    /**
     Parses the transaction for events matching the EventParser settings.
     - Parameter hash: Transaction hash
     - Returns: array of events
     - Important: This call is synchronous
     */
    func parseTransactionByHash(_ hash: Data) throws -> [EventParserResult]
    
    /**
     Parses the block for events matching the EventParser settings.
     - Parameter block: Native web3swift block object
     - Returns: array of events
     - Important: This call is synchronous
     */
    func parseBlock(_ block: Block) throws -> [EventParserResult]
    
    /**
     Parses the block for events matching the EventParser settings.
     - Parameter blockNumber: Ethereum network block number
     - Returns: array of events
     - Important: This call is synchronous
     */
    func parseBlockByNumber(_ blockNumber: UInt64) throws -> [EventParserResult]
    
    /**
     Parses the transaction for events matching the EventParser settings.
     - Parameter transaction: web3swift native EthereumTransaction object
     - Returns: promise that returns array of events
     - Important: This call is synchronous
     */
    func parseTransactionPromise(_ transaction: EthereumTransaction) -> Promise<[EventParserResult]>
    
    /**
     Parses the transaction for events matching the EventParser settings.
     - Parameter hash: Transaction hash
     - Returns: promise that returns array of events
     - Important: This call is synchronous
     */
    func parseTransactionByHashPromise(_ hash: Data) -> Promise<[EventParserResult]>
    
    /**
     Parses the block for events matching the EventParser settings.
     - Parameter blockNumber: Ethereum network block number
     - Returns: promise that returns array of events
     - Important: This call is synchronous
     */
    func parseBlockByNumberPromise(_ blockNumber: UInt64) -> Promise<[EventParserResult]>
    
    /**
     Parses the block for events matching the EventParser settings.
     - Parameter block: Native web3swift block object
     - Returns: promise that returns array of events
     - Important: This call is synchronous
     */
    func parseBlockPromise(_ block: Block) -> Promise<[EventParserResult]>
    
}

