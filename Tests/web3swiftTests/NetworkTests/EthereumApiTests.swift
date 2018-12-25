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

class EthereumApiTests: XCTestCase {
    func testNet() throws {
        eth = .localhost(port: 8545)
        try XCTAssertNoThrow(eth.version().wait())
        try XCTAssertNoThrow(eth.peerCount().wait())
        try XCTAssertEqual(eth.listening().wait(), true)
        XCTAssertEqual(try eth.sha3("0x68656c6c6f20776f726c64".hex).wait(), "0x47173285a8d7341e5e972fc677286384f802f8ef42a5ec5f03bbfa254cb01fad".hex)
    }
    func testShh() throws {
        try XCTAssertThrowsError(eth.shh.version().wait())
    }
    
    func testBitcoinAddress() {
        let publicKey = "031e7bcc70c72770dbb72fea022e8a6d07f814d2ebe4de9ae3f7af75bf706902a7".hex
        let sha = publicKey.sha256()
        var a = RIPEMD160()
        a.update(data: sha)
        var encrypted = a.finalize()
        encrypted.insert(0x00, at: 0)
        
        XCTAssertEqual(encrypted.hex, "00453233600a96384bb8d73d400984117ac84d7e8b")
        encrypted.append(encrypted.sha256().sha256()[..<4])
        XCTAssertEqual("17JsmEygbbEUEpvt4PFtYaTeSqfb9ki1F1", "17JsmEygbbEUEpvt4PFtYaTeSqfb9ki1F1")
        XCTAssertEqual(encrypted.base58(.bitcoin), "17JsmEygbbEUEpvt4PFtYaTeSqfb9ki1F1")
    }
    func testBitcoinAddress2() {
        let publicKey = "031e7bcc70c72770dbb72fea022e8a6d07f814d2ebe4de9ae3f7af75bf706902a7".hex
        try XCTAssertEqual(BTCAddress(publicKey: publicKey).string, "17JsmEygbbEUEpvt4PFtYaTeSqfb9ki1F1")
    }
    func testXrpAddress() {
        let publicKey = "ED9434799226374926EDA3B54B1B461B4ABF7237962EAE18528FEA67595397FA32".hex
        try XCTAssertEqual(XRPAddress(publicKey: publicKey).string, "rDTXLQ7ZKZVKz33zJbHjgVShjsBnqMBhmN")
    }
    
    func testXrpBase58() {
        var data = Data.random(length: 32)
        XCTAssertEqual(data.base58(.ripple), Base58.base58FromBytes(Array(data), Base58.riple))
        data = Data.random(length: 32)
        XCTAssertEqual(data.base58(.ripple), Base58.base58FromBytes(Array(data), Base58.riple))
        data = Data.random(length: 32)
        XCTAssertEqual(data.base58(.ripple), Base58.base58FromBytes(Array(data), Base58.riple))
        data = Data.random(length: 32)
        XCTAssertEqual(data.base58(.ripple), Base58.base58FromBytes(Array(data), Base58.riple))
        data = Data.random(length: 32)
        XCTAssertEqual(data.base58(.ripple), Base58.base58FromBytes(Array(data), Base58.riple))
        data = Data.random(length: 32)
        XCTAssertEqual(data.base58(.ripple), Base58.base58FromBytes(Array(data), Base58.riple))
    }
}
//"""
//Address
//r99xZUyj1uiE1D6dUUqSrDqLXwtccarYXW
//
//Secret
//sspmdvhjCgmasqzg9a6HW6rvYLEoD
//
//Balance
//10,000 XRP
//"""
