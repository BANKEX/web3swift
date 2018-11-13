//
//  Web3+Provider.swift
//  web3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation

/**
 Custom Web3 HTTP provider of Infura nodes.
 web3swift uses Infura mainnet as default provider
 */
public final class InfuraProvider: Web3HttpProvider {
    /**
     - parameter net: defines network id. applies to address "https://\(net).infura.io/"
     - parameter token: your infura token. appends to url address
     - parameter manager: KeystoreManager for this provider
     */
    public init?(_ net: NetworkId, accessToken token: String? = nil, keystoreManager manager: KeystoreManager? = nil) {
        var requestURLstring = "https://\(net).infura.io/"
        if token != nil {
            requestURLstring = requestURLstring + token!
        }
        let providerURL = URL(string: requestURLstring)
        super.init(providerURL!, network: net, keystoreManager: manager)
    }
}
