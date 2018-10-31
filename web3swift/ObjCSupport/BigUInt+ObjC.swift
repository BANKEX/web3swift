//
//  BigUInt+ObjC.swift
//  web3swift
//
//  Created by Alexander Vlasov on 08.08.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation

@objc(BigUInt)
public final class _ObjCBigUInt: NSObject {
    private(set) var biguint: BigUInt?

    public init(value: String) {
        biguint = BigUInt(value)
    }

    public init(value: String, radix: Int) {
        biguint = BigUInt(value, radix: radix)
    }

    init(value: BigUInt) {
        biguint = value
    }

    public func toString(radix: Int = 10) -> NSString {
        guard let val = self.biguint else { return "" as NSString }
        return String(val, radix: radix) as NSString
    }
}
