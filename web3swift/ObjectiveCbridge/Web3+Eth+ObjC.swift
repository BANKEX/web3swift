//
//  Web3+Eth+ObjC.swift
//  web3swift
//
//  Created by Alexander Vlasov on 08.08.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

@objc(web3Eth)
public final class _ObjCweb3Eth: NSObject {
    private(set) weak var web3: web3?

    init(web3: web3?) {
        self.web3 = web3
    }

    public func getBalance(address: _ObjCEthereumAddress, onBlock: NSString = "latest", error: NSErrorPointer) -> _ObjCBigUInt? {
        let _error = error
        do {
            guard let web3 = web3 else { throw Web3Error.processingError("Web3 object was not properly initialized") }
            guard let addr = address.address else { throw Web3Error.inputError("Address is empty") }
            let balance = try web3.eth.getBalance(address: addr, onBlock: onBlock as String)
            return _ObjCBigUInt(value: balance)
        } catch {
            _error?.pointee = error as NSError
            return nil
        }
    }
}
