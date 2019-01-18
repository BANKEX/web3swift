//
//  DefinitionsParser.swift
//  Tests
//
//  Created by Dmitry on 15/01/2019.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import XCTest
@testable import Ripple
import CoreBlockchain

extension Set {
    mutating func insert(_ element: Element, _ writeCollision: inout Int) {
        if contains(element) {
            writeCollision += 1
        }
        insert(element)
    }
}

class DefinitionsParserTest: XCTestCase {
    func testUpdateJson() throws {
        //        let json = try! URLSession.shared
        //            .get("https://raw.githubusercontent.com/ripple/ripple-binary-codec/master/src/enums/definitions.json")
        //            .map(on: .web3, AnyReader.init)
        //            .wait()
        let json = try! AnyReader(json: Data(contentsOf: URL(fileURLWithPath: "/Users/dimas/Desktop/definitions.json.txt")))
        //        let json = try! AnyReader(json: file)
        let types = try json.at("TYPES").dictionary { try $0.int() }
        let ledgerTypes = try json.at("LEDGER_ENTRY_TYPES").dictionary { try $0.int() }
        var maxNth = 0
        let data = DefDataWriter()
        
        try! json.at("FIELDS").array {
            let array = try! $0.array()
            let name = try! array[0].string()
            let params = array[1]
            assert((params.raw as! [String: Any]).count == 5)
            let nth = try! params.at("nth").int()
            let isVLEncoded = try! params.at("isVLEncoded").bool()
            let isSerialized = try! params.at("isSerialized").bool()
            let isSigningField = try! params.at("isSigningField").bool()
            
            var options = 0
            if isVLEncoded { options |= 0b1 }
            if isSerialized { options |= 0b10 }
            if isSigningField { options |= 0b100 }
            let type = try! params.at("type").string()
            let tint = types[type]!
            maxNth = max(maxNth, nth)
            data.data.append(name.data.sha256[0..<4])
            data.append(nth)
            data.append(options)
            data.append(tint)
        }
        print(data.data.count)
        print(data.data.hex(separateEvery: 40, separator: "\n"))
        print(data.data.base64EncodedString())
        let string = """
0228c6d40000fe96c34a07ff00fe504d3c6d010601b0945e97020601e02d9ae9030601f38d995002
06027158c5550306020740f4ba0406023c6ffd5e050602e0b7cbfc060602b66a2732070602ba3953
630806025eb2eb0c090602f38d6e0e0a0602dd280fd30b060249bcaa5d0c060251a16ae90d060204
5bbfc50e06028a3cb5091006023978474111060204cf16211206029bb6d0d11306025cfce1a81406
02cbc986b2150602300cbff7160602799bfe741706024710c22c1806021391d49d1906025537063d
1a0602002b8fcd1b06020e279b421c06029624154b1d0602f51cb66f1e06022b9b1cec1f060215f1
c51e2006020523fbd42106028d64d2a62206021cc9bd452306022fdfae902406021c533af3250602
2fe2177301060324464be4020603a415a9700306030009512904060340d1b9f50506031a70295706
060374783ff9070603d220f496080603200f3bf1010604c9fb15910106058f9996e902060517b2f0
0a03060509d0ea41040605e37e02fd05060514346c5d060605b62f0fc2070605944ca79a0806057c
a27cb4090605b697ae7510060586c142f6110605d720f61c120605a4b323ae13060532e0c53d1406
056e2f80bf150605d04b98f47d010100051bc04b527d0201000549e96d7c010606d05e07b7020606
fcc8e3f1030606b625f3fe040606e7a96acc050606470c57ac060606e7234789070606f842c3e108
06065d41866b09060656b537c20a0606f9dcbc52100606990fc2b61106062349e79912060697cabc
037d020100065b9eca337d0301000619df230f0107078f12b5bb020707d9749d5c0307077dad1a8e
0403071ade60ab050707f1a73e2206030779fa3361070707b351805008070775b8e2d209070739a2
bd960a0707c45e96450b070725379a460c07073bad8d590d070795c497b00e0707a1061213100707
39b36d38110707a8544fc11203077e1b0d560107084b1b8aa3020708293d404a03070839e02c4604
0708b6741b4c050708404aa182060708978354db07070828d581d2080708c394912301060ede1c51
5502060eed0a015003060e4eaa6c3f04060e85583e2c05060e5463795106060e577a3f3f07060e89
9bbb3508060e0074db9609060e64cecb8a0a060e77a0c1cd0b060e0297e53510060e15fbf1971206
0e69154d8c01060f00b80b7403020f25c68d7704060f0575f29d05060f16c37f1606060f211fa4c5
07060f6b258faf08060f3e33415f09060fa77c79d010060f1aebc15401061052a0f9b60206105bce
5d3f0306105a6c392f010611fdf65d59020611383a9f57030611efae5b6c0406119c7995b5010612
90b901a301071339d933d4020713a950f283030713eec26ddd01007d1127c343c65701007d122768
e1ca5701007d1327ae4e51e7260602436d1c30270602ce4683e7160605c018a5631706053b960f52
1806052362c468100610bee38068090603
""".hex
    }
}

class DefDataWriter: DataWriter {
    func append(byte: Int) {
        append(byte: UInt8(bitPattern: Int8(byte)))
    }
    func append(_ number: Int) {
        if number < 125 && number >= Int8.min {
            append(byte: number)
        } else if number <= Int16.max && number >= Int16.min {
            append(byte: 125)
            append(raw: Int16(number))
        } else if number <= Int32.max && number >= Int32.min {
            append(byte: 126)
            append(raw: Int32(number))
        } else {
            append(byte: 127)
            append(raw: Int64(number))
        }
    }
    func append(_ string: String) {
        data.append(string.data(using: .utf8)!)
    }
}
class DefDataReader: DataReader {
    
}
