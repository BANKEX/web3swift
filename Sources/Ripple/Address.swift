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
import BigInt

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
    
    public func balance() -> Promise<BigUInt> {
        return ripple.accounts.info(account: string, strict: true, ledger: .current, queue: nil, singerLists: nil).map { $0.accountData.balance }
    }
    
//    public func send(_ amount: BigUInt, from privateKey: PrivateKey) -> Promise<String> {
//        let json = JDictionary()
//        const fee = new BigNumber(tx.Fee)
//        const maxFeeDrops = xrpToDrops(api._maxFeeXRP)
//        if (fee.greaterThan(maxFeeDrops)) {
//            throw new utils.common.errors.ValidationError(
//                `"Fee" should not exceed "${maxFeeDrops}". ` +
//                'To use a higher fee, set `maxFeeXRP` in the RippleAPI constructor.'
//            )
//        }
//        
//        tx.SigningPubKey = options.signAs ? '' : keypair.publicKey
//        
//        if (options.signAs) {
//            const signer = {
//                Account: options.signAs,
//                SigningPubKey: keypair.publicKey,
//                TxnSignature: computeSignature(tx, keypair.privateKey, options.signAs)
//            }
//            tx.Signers = [{Signer: signer}]
//        } else {
//            tx.TxnSignature = computeSignature(tx, keypair.privateKey)
//        }
//    }
}
extension RippleAddress: Equatable {
    static public func == (l: RippleAddress, r: RippleAddress) -> Bool {
        return l.data == r.data
    }
    static public func == (l: RippleAddress, r: String) -> Bool {
        return l.string == r
    }
}

