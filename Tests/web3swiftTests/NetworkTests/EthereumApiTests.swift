//
//  EthereumApiTests.swift
//  Tests
//
//  Created by Dmitry on 20/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import XCTest
@testable import web3swift
@testable import CoreBlockchain

class EthereumApiTests: XCTestCase {
    func testSome() {
        let yourPassword = "••••••••••••••••••••••••••••"
        let yourAddress = try! Web3.default.addAccount(mnemonics: "nation tornado double since increase orchard tonight left drip talk sand mad", password: yourPassword)
        
        let tokenAddress: Address = "0x45245bc59219eeaaf6cd3f382e078a461ff9de7b"
        
        let token = ERC20(tokenAddress, from: yourAddress, password: yourPassword)
        let result = try! token.transfer(to: "0xfbb1b73c4f0bda4f67dca266ce6ef42f520fbb98", amount: NaturalUnits("1.5"))
    }
//    func testNet() throws {
//        eth = .localhost(port: 8545)
//        try XCTAssertNoThrow(eth.version().wait())
//        try XCTAssertNoThrow(eth.peerCount().wait())
//        try XCTAssertEqual(eth.listening().wait(), true)
//        XCTAssertEqual(try eth.sha3("0x68656c6c6f20776f726c64".hex).wait(), "0x47173285a8d7341e5e972fc677286384f802f8ef42a5ec5f03bbfa254cb01fad".hex)
//    }
//    func testShh() throws {
//        try XCTAssertThrowsError(eth.shh.version().wait())
//    }
}

