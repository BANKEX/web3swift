//
//  BetterERC20Tests.swift
//  web3swift-iOS_Tests
//
//  Created by Dmitry on 17/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import XCTest
import BigInt
@testable import web3swift

class BetterERC20Tests: XCTestCase {
    let contract: Address = "0x45245bc59219eeaaf6cd3f382e078a461ff9de7b"
    let user: Address = "0x6394b37Cf80A7358b38068f0CA4760ad49983a1B"
    
    override func setUp() {
        Web3.default.options.from = "0x6394b37Cf80A7358b38068f0CA4760ad49983a1B"
    }
    override func tearDown() {
        Web3.default.options.from = nil
    }
    func testERC20EncodeUsingABIv2() throws {
        let amount = BigUInt(10).power(18)
        let arguments: [SolidityDataRepresentable] = [user, amount]
        let request = arguments.data(function: "transfer(address,uint256)")
        XCTAssertEqual(request.toHexString(), "a9059cbb0000000000000000000000006394b37cf80a7358b38068f0ca4760ad49983a1b0000000000000000000000000000000000000000000000000de0b6b3a7640000")
        
        let response = BigUInt(1).solidityData
        let success = try Web3DataResponse(response).bool()
        XCTAssertTrue(success)
    }
    
    func testERC20BalanceResponse() throws {
        let options = Web3Options.default
        let address = "0xd0a6e6c54dbc68db5db3a091b171a77407ff7ccf"
        let arguments: [SolidityDataRepresentable] = [address]
        let transaction = EthereumTransaction(to: contract, data: arguments.data(function: "balanceOf(address)"), options: options)
        let requestDictionary = transaction.encodeAsDictionary(from: "0xE6877A4d8806e9A9F12eB2e8561EA6c1db19978d")
        XCTAssertNotNil(requestDictionary, "Can't read ERC20 balance")
    }
    
    func testERC20NameResponse() throws {
        let response = Data(hex: "0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000a534f4e4d20546f6b656e00000000000000000000000000000000000000000000")
        let name = try Web3DataResponse(response).string()
        XCTAssertEqual(name, "SONM Token")
    }
    
    func testERC20Name() throws {
        let name = try contract.call("name()").wait().string()
        XCTAssertEqual(name, "\"BANKEX\" project utility token")
    }
    
    func testERC20Balance() throws {
        XCTAssertNoThrow(try contract.call("balanceOf(address)",user).wait().uint256())
    }

}
