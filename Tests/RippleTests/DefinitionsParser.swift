//
//  DefinitionsParser.swift
//  Tests
//
//  Created by Dmitry on 15/01/2019.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import XCTest
@testable import Ripple
import CoreBlockchain
import PromiseKit

class DefinitionsParserTest: XCTestCase {
    func testUpdateJson() throws {
        let defs = try Definitions.update().wait()
        let data = DefDataWriter()
        defs.write(to: data)
        let reader = try DefDataReader(data.data).readBits()
        let defs2 = try! Definitions(data: reader)
        assert(defs == defs2)
        assert(Definitions.main == defs2)
    }
}
