//
//  RippleTests.swift
//  RippleTests
//
//  Created by Dmitry on 08/01/2019.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import XCTest
@testable import Ripple
import CoreBlockchain

class ChildAccount {
    var index: UInt32
    var privateKey: PrivateKey
    init(index: UInt32, privateKey: PrivateKey) {
        self.index = index
        self.privateKey = privateKey
    }
}
extension PrivateKey {
    convenience init(_ uint256: UInt256) {
        self.init(uint256.data)
    }
}
//
//func getFamilyGenerator(seedBytes: Data) throws -> PrivateKey {
//    let curveOrderUint32 = UInt256(0xffffffffffffffff,0xfffffffffffffffe,0xbaaedce6af48a03b,0xbfd25e8cd0364141)
//    var counter = UInt256()
//
//    var privateKey: UInt256
//    repeat {
//
//        seedBytes[1..<17] + Data(raw: counter)
//        buf := new(bytes.Buffer)
//        binary.Write(buf, binary.LittleEndian, counter)
//        update := append(seedBytes[1:17], buf.Bytes()...)
//        pvk = utils.SHA512(update)[:32]
//        counter += 1
//    } while privateKey > curveOrderUint32
//
//    return &RootAccount {
//        pvk,
//    }, nil
//}
//buf := new(bytes.Buffer)
//binary.Write(buf, binary.LittleEndian, counter)
//update := append(seedBytes[1:17], buf.Bytes()...)
//pvk = utils.SHA512(update)[:32]
//counter++


class RippleTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func getFamilyGenerator(seed: Data) -> PrivateKey {
        let curveOrder = UInt256(0xffffffffffffffff,0xfffffffffffffffe,0xbaaedce6af48a03b,0xbfd25e8cd0364141)
        var counter = UInt256()
        var privateKey: UInt256
        repeat {
            privateKey = UInt256((seed + counter.data).sha512)
            counter += 1
        } while privateKey > curveOrder
        return PrivateKey(privateKey.data)
    }
    
    func getChildAccount(seed: Data, index: UInt32) -> ChildAccount {
        let accountIndex = Data(raw: index)
        let curveOrder = UInt256(0xffffffffffffffff,0xfffffffffffffffe,0xbaaedce6af48a03b,0xbfd25e8cd0364141)
        var counter: UInt256 = 0
        
        let rootAccount = getFamilyGenerator(seed: seed)
        var update1: UInt256 = 0
        let privateKey = UInt256(rootAccount.privateKey)
        let publicKey = try! rootAccount.publicKey.compressed()
        repeat {
            let update = publicKey.data + accountIndex + counter.data
            update1 = privateKey &+ UInt256(update.sha512)
            counter += 1
        } while update1 > curveOrder
        return ChildAccount(index: index, privateKey: PrivateKey(update1 % curveOrder))
    }

    
    func secretToData(_ secret: String) -> Data {
        let secret = secret.base58(.ripple)!
        return secret.subdata(in: 1..<17)
    }
    
    func secretToPrivateKey(_ secret: Data) -> Data {
        let account = getChildAccount(seed: secret, index: 0)
//        let secret = secret + Data(count: 4)
        return account.privateKey.privateKey
    }
    
    func privateToPublic(_ privateKey: Data) -> Data {
        return try! SECP256K1.privateToPublic(privateKey: privateKey, compressed: true)
    }
    
    func publicToAddress(_ publicKey: Data) -> String {
        var s = publicKey.sha256.ripemd160
        s.insert(0x00, at: 0)
        s.append(s.sha256.sha256[..<4])
        var address = s.base58(.ripple)
        address[0] = "r"
        return address
    }
    
    func testSecretToHex() {
        let secret = secretToData("sstV9YX8k7yTRzxkRFAHmX7EVqMfX")
        XCTAssertEqual(secret.hex, "559EDD35041D3C11F9BBCED912F4DE6A".hex.hex)
    }
    
    func testAll() {
        let secret = "sngoZvTaGzcobmrQmYqmd2ssuzDxR"
        print("Secret:       \(secret)")
        let secretData = secretToData(secret)
        print("Secret hex:   \(secretData.hex)")
        let privateKey = secretToPrivateKey(secretData)
        print("Private key:  \(privateKey.hex)")
        let publicKey = privateToPublic(privateKey)
        print("Public key:   \(publicKey.hex)")
        let address = publicToAddress(publicKey)
        print("Address:      \(address)")
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
