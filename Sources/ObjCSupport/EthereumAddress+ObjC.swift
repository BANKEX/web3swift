//
//  Address+ObjC.swift
//  web3swift
//
//  Created by Alexander Vlasov on 08.08.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

@objc(Address)
public final class _ObjCAddress: NSObject {
    private(set) var address: Address?

    public init(address: String) {
        self.address = Address(address)
    }

    public init(address: Data) {
        self.address = Address(address)
    }

    init(address: Address) {
        self.address = address
    }

    public static var contractDeploymentAddress: _ObjCAddress {
        return _ObjCAddress(address: .contractDeployment)
    }
}
