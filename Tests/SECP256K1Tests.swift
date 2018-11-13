//
//  web3swift_SECP256K1_Tests.swift
//  web3swift-iOS_Tests
//
//  Created by Anton Grigoriev on 02.07.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import XCTest

import BigInt
import CryptoSwift
import XCTest

@testable import web3swift

class SECP256K1Tests: XCTestCase {
    func testNonDeterministicSignature() throws {
        var unsuccesfulNondeterministic = 0
        var allAttempts = 0
        for _ in 0 ..< 10000 {
            do {
                let randomHash = Data.random(length: 32)
                let randomPrivateKey = Data.random(length: 32)
                try SECP256K1.verifyPrivateKey(privateKey: randomPrivateKey)
                allAttempts = allAttempts + 1
                let signature = try SECP256K1.signForRecovery(hash: randomHash, privateKey: randomPrivateKey, useExtraEntropy: true)
                let serialized = signature.serializedSignature
                let recovered = try SECP256K1.recoverPublicKey(hash: randomHash, signature: serialized, compressed: true)
                let original = try SECP256K1.privateToPublic(privateKey: randomPrivateKey, compressed: true)
                guard recovered == original else {
                    unsuccesfulNondeterministic += 1
                    continue
                }
            } catch {
                unsuccesfulNondeterministic += 1
            }
        }
        print("Problems with \(unsuccesfulNondeterministic) non-deterministic signatures out from \(allAttempts)")
        XCTAssertEqual(unsuccesfulNondeterministic, 0)
    }

    func testDeterministicSignature() {
        var unsuccesfulDeterministic = 0
        var allAttempts = 0
        for _ in 0 ..< 10000 {
            do {
                let randomHash = Data.random(length: 32)
                let randomPrivateKey = Data.random(length: 32)
                try SECP256K1.verifyPrivateKey(privateKey: randomPrivateKey)
                allAttempts = allAttempts + 1
                let signature = try SECP256K1.signForRecovery(hash: randomHash, privateKey: randomPrivateKey, useExtraEntropy: false)
                let serialized = signature.serializedSignature
                let recovered = try SECP256K1.recoverPublicKey(hash: randomHash, signature: serialized, compressed: true)
                let original = try SECP256K1.privateToPublic(privateKey: randomPrivateKey, compressed: true)
                guard recovered == original else {
                    unsuccesfulDeterministic += 1
                    continue
                }
            } catch {
                unsuccesfulDeterministic += 1
            }
        }
        print("Problems with \(unsuccesfulDeterministic) deterministic signatures out from \(allAttempts)")
        XCTAssert(unsuccesfulDeterministic == 0)
    }

    func testPrivateToPublic() throws {
        let randomPrivateKey = Data.random(length: 32)
        try SECP256K1.verifyPrivateKey(privateKey: randomPrivateKey)
        var previousPublic = try SECP256K1.privateKeyToPublicKey(privateKey: randomPrivateKey)
        for _ in 0 ..< 100_000 {
            let pub = try SECP256K1.privateKeyToPublicKey(privateKey: randomPrivateKey)
            guard Data(toByteArray(previousPublic.data)) == Data(toByteArray(pub.data)) else {
                return XCTFail()
            }
            previousPublic = pub
        }
    }

    func testSerializationAndParsing() throws {
        for _ in 0 ..< 1024 {
            let randomHash = Data.random(length: 32)
            let randomPrivateKey = Data.random(length: 32)
            try SECP256K1.verifyPrivateKey(privateKey: randomPrivateKey)
            var signature = try SECP256K1.recoverableSign(hash: randomHash, privateKey: randomPrivateKey, useExtraEntropy: true)
            let serialized = try SECP256K1.serializeSignature(recoverableSignature: &signature)
            let parsed = try SECP256K1.parseSignature(signature: serialized)
            let sigData = Data(toByteArray(signature.data))
            let parsedData = Data(toByteArray(parsed.data))
            guard sigData == parsedData else {
                for i in 0 ..< sigData.count {
                    if sigData[i] != parsedData[i] {
                        print(i)
                    }
                }
                return XCTFail()
            }
        }
    }
}
