//
//  Web3+Provider+ObjC.swift
//  web3swift
//
//  Created by Alexander Vlasov on 08.08.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

@objc(Web3HttpProvider)
final class _ObjCWeb3HttpProvider: NSObject {
    private(set) var web3Provider: Web3HttpProvider?

    init(providerURL: NSURL, network: _ObjCNetwork, keystoreManager: _ObjCKeystoreManager) {
        guard let ks = keystoreManager.keystoreManager else { return }
        web3Provider = Web3HttpProvider(providerURL as URL, network: NetworkId(network.networkID), keystoreManager: ks)
    }

    init(web3Provider: Web3HttpProvider) {
        self.web3Provider = web3Provider
    }
}

@objc(Network)
final class _ObjCNetwork: NSObject {
    let networkID: Int

    init(networkID: Int) {
        self.networkID = networkID
    }
}
