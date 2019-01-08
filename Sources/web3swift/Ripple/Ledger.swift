//
//  Ledger.swift
//  web3swift
//
//  Created by Dmitry on 28/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

enum LedgerType {
    case hash(String), number(Int), tag(String)
}

class Ledger {
    let type: LedgerType
    init(type: LedgerType) {
        self.type = type
    }
}

extension Ledger: JKeyedEncodable {
    func write(to dictionary: JDictionary) {
        switch type {
        case .hash(let value):
            dictionary.set("ledger_hash", value)
        case .number(let value):
            dictionary.set("ledger_index", value)
        case .tag(let value):
            dictionary.set("ledger_index", value)
        }
    }
}
