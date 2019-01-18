//
//  Sign.swift
//  Ripple
//
//  Created by Dmitry on 1/15/19.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import Foundation
struct HashPrefix {
    static let transactionID: UInt32 = 0x54584E00
    // transaction plus metadata
    static let transaction: UInt32 = 0x534E4400
    // account state
    static let accountStateEntry: UInt32 = 0x4D4C4E00
    // inner node in tree
    static let innerNode: UInt32 = 0x4D494E00
    // ledger master data for signing
    static let ledgerHeader: UInt32 = 0x4C575200
    // inner transaction to sign
    static let transactionSig: UInt32 = 0x53545800
    // inner transaction to sign
    static let transactionMultiSig: UInt32 = 0x534D5400
    // validation for signing
    static let validation: UInt32 = 0x56414C00
    // proposal for signing
    static let proposal: UInt32 = 0x50525000
    // payment channel claim
    static let paymentChannelClaim: UInt32 = 0x434C4D00
}


func serialize(_ object: Any, to data: inout Data, signingFieldsOnly: Bool) {
    
}
func serialize(_ object: Any, prefix: UInt32?, suffix: Data?, signingFieldsOnly: Bool = false) -> Data {
    var data = Data()
    if let prefix = prefix {
        data.append(Data(raw: prefix))
    }
    serialize(object, to: &data, signingFieldsOnly: signingFieldsOnly)
    if let suffix = suffix {
        data.append(suffix)
    }
    return data
}

func signingData(_ tx: Any) -> Data {
    return serialize(tx, prefix: HashPrefix.transactionSig, suffix: nil, signingFieldsOnly: true)
}
