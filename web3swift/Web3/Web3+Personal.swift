//
//  Web3+Personal.swift
//  web3swift
//
//  Created by Alexander Vlasov on 14.04.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation

extension Web3.Personal {
    /**
     *Locally or remotely sign a message (arbitrary data) with the private key. To avoid potential signing of a transaction the message is first prepended by a special header and then hashed.*

     - parameters:
     - message: Message Data
     - from: Use a private key that corresponds to this account
     - password: Password for account if signing locally

     - returns:
     - Result object

     - important: This call is synchronous

     */
    public func signPersonalMessage(message: Data, from: EthereumAddress, password: String = "BANKEXFOUNDATION") throws -> Data {
        return try signPersonalMessagePromise(message: message, from: from, password: password).wait()
    }

    /**
     *Unlock an account on the remote node to be able to send transactions and sign messages.*

     - parameters:
     - account: EthereumAddress of the account to unlock
     - password: Password to use for the account
     - seconds: Time inteval before automatic account lock by Ethereum node

     - returns:
     - Result object

     - important: This call is synchronous. Does nothing if private keys are stored locally.

     */
    public func unlockAccount(account: EthereumAddress, password _: String = "BANKEXFOUNDATION", seconds _: UInt64 = 300) throws -> Bool {
        return try unlockAccountPromise(account: account).wait()
    }

    /**
     *Recovers a signer of some message. Message is first prepended by special prefix (check the "signPersonalMessage" method description) and then hashed.*

     - parameters:
     - personalMessage: Message Data
     - signature: Serialized signature, 65 bytes

     - returns:
     - Result object

     */
    public func ecrecover(personalMessage: Data, signature: Data) throws -> EthereumAddress {
        return try Web3Utils.personalECRecover(personalMessage, signature: signature)
    }

    /**
     *Recovers a signer of some hash. Checking what is under this hash is on behalf of the user.*

     - parameters:
     - hash: Signed hash
     - signature: Serialized signature, 65 bytes

     - returns:
     - Result object

     */
    public func ecrecover(hash: Data, signature: Data) throws -> EthereumAddress {
        return try Web3Utils.hashECRecover(hash: hash, signature: signature)
    }
}
