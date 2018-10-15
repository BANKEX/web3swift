//
//  Web3+ObjectiveC.swift
//  web3swift
//
//  Created by Alexander Vlasov on 08.08.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

@objc(Web3)
public final class _ObjCWeb3: NSObject {
    public static func InfuraMainnetWeb3() -> _ObjCweb3 {
        let web3 = Web3(infura: .mainnet)
        return _ObjCweb3(web3: web3)
    }

    public static func InfuraRinkebyWeb3() -> _ObjCweb3 {
        let web3 = Web3(infura: .rinkeby)
        return _ObjCweb3(web3: web3)
    }

    public static func new(providerURL: NSURL) -> _ObjCweb3 {
        let web3 = Web3(url: providerURL as URL)
        return _ObjCweb3(web3: web3)
    }
}
