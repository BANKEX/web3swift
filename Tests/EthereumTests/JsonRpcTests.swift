//
//  JsonRpcTests.swift
//  Tests
//
//  Created by Dmitry on 17/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import XCTest
import PromiseKit
import BigInt
@testable import web3swift
@testable import CoreBlockchain

class TestCallRequest: Request {
    init() {
        super.init(method: "eth_call")
    }
    override func request() -> [Any] {
        return [[
            "data": "0x06fdde03",
            "to":"0x45245bc59219eeaaf6cd3f382e078a461ff9de7b",
            "value":"0x0",
            "gasPrice":"0x0"
            ], "latest"]
    }
    override func response(data: DictionaryReader) throws {
        let expected = "0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000001e2242414e4b4558222070726f6a656374207574696c69747920746f6b656e0000"
        try data.string().equals(expected)
    }
}

class JsonRpcTests: XCTestCase {
    func testRequest() throws {
        let request = TestCallRequest()
        URLSession.shared.send(request: request, to: .infura(.mainnet))
        _ = try! request.promise.wait()
    }
    func testNewRlp() throws {
        let data = try SolidityFunction(function: "doSome(uint256,uint256)").encode(0x123,0x456)
        
        let address: Address = "0x6a6a0b4aaa60E97386F94c5414522159b45DEdE8"
        var transaction = EthereumTransaction(gasPrice: 0x12345, gasLimit: 0x123123, to: address, value: 0, data: data)
        transaction.chainID = .mainnet
        
        let keystore = try! EthereumKeystoreV3(password: "")!
        let privateKey = try! keystore.UNSAFE_getPrivateKeyData(password: "", account: keystore.address!)
        
        let transaction2 = Transaction(gasPrice: 0x12345, gasLimit: 0x123123, to: address, value: 0, data: data)
        let dataWriter = TransactionDataWriter()
        transaction2.write(to: dataWriter)
        transaction2.write(networkId: .mainnet, to: dataWriter)
        
        
        let unsigned1 = transaction.encode(forSignature: false, chainId: .mainnet)!.hex
        let unsigned2 = dataWriter.done().hex
        XCTAssertEqual(unsigned1, unsigned2)
        
        try! Web3Signer.signTX(transaction: &transaction, keystore: keystore, account: keystore.address!, password: "")
        
        let signed1 = transaction.encode(forSignature: false, chainId: .mainnet)!.hex
        let signed2 = try! transaction2.sign(using: PrivateKey(privateKey), networkId: .mainnet).data().hex
        XCTAssertEqual(signed1, signed2)
    }
}
