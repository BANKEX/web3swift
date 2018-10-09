//
//  Web3+Provider.swift
//  web3swift
//
//  Created by Alexander Vlasov on 19.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

/// Custom Web3 HTTP provider of Infura nodes.
public final class InfuraProvider: Web3HttpProvider {
    public init?(_ net: NetworkId, accessToken token: String? = nil, keystoreManager manager: KeystoreManager? = nil) {
        var requestURLstring = "https://\(net).infura.io/"
        if token != nil {
            requestURLstring = requestURLstring + token!
        }
        let providerURL = URL(string: requestURLstring)
        super.init(providerURL!, network: net, keystoreManager: manager)
    }
}

