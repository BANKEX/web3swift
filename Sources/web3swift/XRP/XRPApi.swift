//
//  XRPApi.swift
//  web3swift
//
//  Created by Dmitry on 21/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt
import PromiseKit

class XRPApi {
    let network: NetworkProvider
    init(network: NetworkProvider) {
        self.network = network
    }
}
