//
//  TxPoolTests.swift
//  web3swift-iOS_Tests
//
//  Created by Dmitry on 28/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import XCTest
@testable import web3swift_iOS
import BigInt

class TxPoolTests: XCTestCase {
    override func setUp() {
        let url = URL(string: "http://127.0.0.1:8545")!
        guard let provider = Web3HttpProvider(url, network: nil, keystoreManager: nil) else { return XCTFail("Please start your local test node") }
        Web3.default = Web3(provider: provider)
    }
    func testTxPoolStatus() throws {
        let response = try TxPool.default.status().wait()
        print(response)
    }
    
    func testTxPoolInspect() throws {
        let response = try TxPool.default.inspect().wait()
        print(response)
    }
    
    func testTxPoolContent() throws {
        let response = try TxPool.default.content().wait()
        print(response)
    }
}
