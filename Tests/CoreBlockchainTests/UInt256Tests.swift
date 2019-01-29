//
//  UInt256Tests.swift
//  CoreBlockchainTests
//
//  Created by Dmitry on 28/01/2019.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import XCTest
@testable import CoreBlockchain

class UInt256Tests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func testNumberToString() {
        XCTAssertEqual(UInt256("123"), 123)
        XCTAssertEqual(UInt256("ff", radix: 16), 0xff)
        XCTAssertEqual(UInt256("10", radix: 2), 0b10)
//        XCTAssertEqual(String(UInt256(123), radix: 10), "123")
//        XCTAssertEqual(String(UInt256(0xff), radix: 10), "255")
//        XCTAssertEqual(String(UInt256(0xff), radix: 16), "ff")
//        XCTAssertEqual(String(UInt256(0b10), radix: 0b10), "10")
//        XCTAssertEqual(String(UInt256(1000)), "1000")
//        XCTAssertEqual(String(UInt256(0xfffffffffffffff), radix: 16), "fffffffffffffff")
//        XCTAssertEqual(String(UInt256(0xffffffffffffffff,0xffffffffffffffff,0xffffffffffffffff,0xffffffffffffffff), radix: 16), "ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testFixedWidthInteger() {
//        XCTAssertEqual(UInt256(0b0000_0000_0000_0000).byteSwapped, UInt256(Int(0b0000_0000_0000_0000).byteSwapped))
//        XCTAssertEqual(UInt256(0b1000_0000_0000_0000).byteSwapped, UInt256(Int(0b1000_0000_0000_0000).byteSwapped))
//        XCTAssertEqual(UInt256(0b0001_0001_0000_0000).byteSwapped, UInt256(Int(0b0001_0001_0000_0000).byteSwapped))
//        XCTAssertEqual(UInt256(0b0011_1100_1100_0011).byteSwapped, UInt256(Int(0b0011_1100_1100_0011).byteSwapped))
//        XCTAssertEqual(UInt256(0b1111_1111_0000_0000).byteSwapped, UInt256(Int(0b1111_1111_0000_0000).byteSwapped))
    }
}
