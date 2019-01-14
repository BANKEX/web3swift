//
//  RippleAddress.swift
//  web3swift
//
//  Created by Dmitry on 12/24/18.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit
import CoreBlockchain

struct RipplePrefix {
    static let address: UInt8 = 0x00
    static let secret: UInt8 = 0x21
}

private let rippleAddressPrefix: UInt8 = 0x00

public struct RippleNetworkId: RawRepresentable {
    public var rawValue: UInt8
    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}

extension PrivateKey {
    public func rippleAddress() -> RippleAddress {
        return try! RippleAddress(publicKey: publicKey)
    }
}
public class RippleAddress: Address58 {
    public override var string: String {
        return data.base58(.ripple)
    }
    public init(publicKey: PublicKey) throws {
        let data = publicKey.bitcoinAddress().base58Check(.ripple, RipplePrefix.address)
        super.init(data)
    }
    public override init(_ data: Data) {
        super.init(data)
    }
    public init?(_ base58: String) {
        guard let data = try? base58.base58(.ripple, check: true, prefix: RipplePrefix.address) else { return nil }
        super.init(data)
    }
}
extension RippleAddress: Equatable {
    static public func == (l: RippleAddress, r: RippleAddress) -> Bool {
        return l.data == r.data
    }
    static public func == (l: RippleAddress, r: String) -> Bool {
        return l.string == r
    }
}

