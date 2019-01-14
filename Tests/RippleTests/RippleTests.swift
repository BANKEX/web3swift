//
//  RippleTests.swift
//  RippleTests
//
//  Created by Dmitry on 08/01/2019.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import XCTest
@testable import Ripple
import CoreBlockchain

class RippleTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
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
    func testAll() throws {
        let secret = try Secret("sspmdvhjCgmasqzg9a6HW6rvYLEoD")
        XCTAssert(secret[0].rippleAddress() == "r99xZUyj1uiE1D6dUUqSrDqLXwtccarYXW")
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
