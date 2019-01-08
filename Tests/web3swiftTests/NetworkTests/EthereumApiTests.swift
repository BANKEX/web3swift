//
//  EthereumApiTests.swift
//  Tests
//
//  Created by Dmitry on 20/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import XCTest
@testable import web3swift

class EthereumApiTests: XCTestCase {
//    func testNet() throws {
//        eth = .localhost(port: 8545)
//        try XCTAssertNoThrow(eth.version().wait())
//        try XCTAssertNoThrow(eth.peerCount().wait())
//        try XCTAssertEqual(eth.listening().wait(), true)
//        XCTAssertEqual(try eth.sha3("0x68656c6c6f20776f726c64".hex).wait(), "0x47173285a8d7341e5e972fc677286384f802f8ef42a5ec5f03bbfa254cb01fad".hex)
//    }
//    func testShh() throws {
//        try XCTAssertThrowsError(eth.shh.version().wait())
//    }
//    
//    func testBitcoinAddress() {
//        let publicKey = "031e7bcc70c72770dbb72fea022e8a6d07f814d2ebe4de9ae3f7af75bf706902a7".hex
//        let sha = publicKey.sha256()
//        var a = RIPEMD160()
//        a.update(data: sha)
//        var encrypted = a.finalize()
//        encrypted.insert(0x00, at: 0)
//        
//        XCTAssertEqual(encrypted.hex, "00453233600a96384bb8d73d400984117ac84d7e8b")
//        encrypted.append(encrypted.sha256().sha256()[..<4])
//        XCTAssertEqual("17JsmEygbbEUEpvt4PFtYaTeSqfb9ki1F1", "17JsmEygbbEUEpvt4PFtYaTeSqfb9ki1F1")
//        XCTAssertEqual(encrypted.base58(.bitcoin), "17JsmEygbbEUEpvt4PFtYaTeSqfb9ki1F1")
//    }
//    func testBitcoinAddress2() {
//        let publicKey = "031e7bcc70c72770dbb72fea022e8a6d07f814d2ebe4de9ae3f7af75bf706902a7".hex
//        try XCTAssertEqual(BTCAddress(publicKey: publicKey).string, "17JsmEygbbEUEpvt4PFtYaTeSqfb9ki1F1")
//    }
//    func testRippleAddress() {
//        let publicKey = "ED9434799226374926EDA3B54B1B461B4ABF7237962EAE18528FEA67595397FA32".hex
//        try XCTAssertEqual(XRPAddress(publicKey: publicKey).string, "rDTXLQ7ZKZVKz33zJbHjgVShjsBnqMBhmN")
//    }
    
    
    func secretToData(_ secret: String) -> Data {
        let secret = secret.base58(.ripple)!
        return secret.subdata(in: 1..<17)
    }
    
    func secretToPrivateKey(_ secret: Data) -> Data {
        let secret = secret + Data(count: 4)
        return secret.sha512[0..<32]
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
        let secret = "sswKp6cZgif8AKYsSrhozKNRPdkhd"
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
    
    func testSecretToPrivate() {
        let secret = "559EDD35041D3C11F9BBCED912F4DE6A".hex
        let privateKey = secretToPrivateKey(secret)
        print(privateKey.hex)
        let publicKey = privateToPublic(privateKey)
        XCTAssertEqual(publicKey.hex, "0351BDFB30E7924993C625687AE6127034C4A5EBA78A01E9C58B0C46E04E3A4948".hex.hex)
    }
    
    func testPrivateToPublic() {
        let publicKey = privateToPublic("559EDD35041D3C11F9BBCED912F4DE6A".hex)
        XCTAssertEqual(publicKey.hex, "0351BDFB30E7924993C625687AE6127034C4A5EBA78A01E9C58B0C46E04E3A4948")
    }
    
    func testPublicKeyToAddress() {
//"result": {
//"account_id": "rDGnaDqJczDAjrKHKdhGRJh2G7zJfZhj5q",
//"key_type": "secp256k1",
//"master_key": "COON WARN AWE LUCK TILE WIRE ELI SNUG TO COVE SHAM NAT",
//"master_seed": "sstV9YX8k7yTRzxkRFAHmX7EVqMfX",
//"master_seed_hex": "559EDD35041D3C11F9BBCED912F4DE6A",
//"public_key": "aBQXEw1vZD3guCX3rHL8qy8ooDomdFuxZcWrbRZKZjdDkUoUjGVS",
//"public_key_hex": "0351BDFB30E7924993C625687AE6127034C4A5EBA78A01E9C58B0C46E04E3A4948"
//},
        
        
        let publicKey = "0351BDFB30E7924993C625687AE6127034C4A5EBA78A01E9C58B0C46E04E3A4948"
        let address = publicToAddress(publicKey.hex)
        XCTAssertEqual(address, "rDGnaDqJczDAjrKHKdhGRJh2G7zJfZhj5q")
    }
    
    func testSome() {
        //  61512107762d6c7f85438c407599fb7c27bcc24458e5ab0ea39e51269ae02850
//        "3DAaoriL9e1u7PTMACp6DSrrsicPPDfEtAscbyy2o3Gu"
//        "MzA1RXCamsYzKVb8eKYSgt"
//
//        "ssFkxuEj1WB1xyumnNAfNMUqUMuWJ"
        
        let secret = "ssFkxuEj1WB1xyumnNAfNMUqUMuWJ"
        let secretHex = secret.base58(.ripple)!
        
        var seed = secretHex[1..<17]
//        var seed = "DEDCE9CE67B451D852FD4E846FCDE31C".hex
        seed += Data(count: 4)
        let privateKey = PrivateKey(seed.sha512[0..<32].hex.hex)
        
        let publicKey = try! SECP256K1.privateToPublic(privateKey: privateKey.privateKey, compressed: true)
        var s = publicKey.sha256.ripemd160
        s.insert(0x00, at: 0)
        s.append(s.sha256.sha256[..<4])
        
        let address = privateKey.rippleAddress().string
        XCTAssertEqual(address, "rhvXS7NFpnPdTk6teNPzpbQTvBHYH92tPY")
        print(address)
        
        
////        "0339F61C06E025ECDFA1A16B2AFAE0F2F4E3FA48661A"
//        a.insert(0x21, at: 0)
//        a.append(a.sha256().sha256()[0..<4])
//        XCTAssertEqual(a.base58(.ripple), "snoPBrXtMeMyMHUVTgbuqAfg1SUTb")
//
//        let s = "snoPBrXtMeMyMHUVTgbuqAfg1SUTb".base58(.ripple)!.hex
//        print(s)
        
//        var seed = "ssFkxuEj1WB1xyumnNAfNMUqUMuWJ".base58(.ripple)!
////        seed.sha512[0..<32]
//
//        seed.append(Data(raw: UInt32(0)))
//        let privateKey = seed.sha512[0..<32]
//        let address = PrivateKey(privateKey).rippleAddress().string
////        let publicKey = PrivateKey(privateKey).publicKey
////        var address = (Data(count: 1) + publicKey.sha256.ripemd160).base58(.ripple)
////        address[0] = "r"
//        XCTAssertEqual(address, "rhvXS7NFpnPdTk6teNPzpbQTvBHYH92tPY")
    }
}
//"""
//Address
//r99xZUyj1uiE1D6dUUqSrDqLXwtccarYXW
//
//Secret
//sspmdvhjCgmasqzg9a6HW6rvYLEoD
//
//Balance
//10,000 XRP
//"""
