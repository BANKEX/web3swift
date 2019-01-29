//
//  Definitions.swift
//  web3swift
//
//  Created by Dmitry on 18/01/2019.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit
import CoreBlockchain

class Definitions: ExpressibleByStringLiteral {
    static var main: Definitions = """
    91037d95001ade60ab0507f38d6e0e0a02e7a96acc0506300cbff71602b66a2732070209d0ea4104
    057dad1a8e0407b0945e97020100b80b74030f25c68d77040f6b258faf080f7e1b0d560108b697ae
    751005f1a73e2206075cfce1a8140290b901a30113504d3c6d0101200f3bf101048d64d2a622025e
    b2eb0c09020074db96090e7ca27cb409054b1b8aa302083e33415f090f28d581d2080868e1ca5701
    7d132785583e2c050ef38d9950020239b36d38110786c142f61105a8544fc11207799bfe741702d9
    749d5c03071c533af3250249e96d7c010640d1b9f50503a4b323ae1305ba3953630802002b8fcd1b
    02045bbfc50e024eaa6c3f040e64cecb8a0a0eefae5b6c0411990fc2b61106d04b98f47d0101059c
    7995b5011251a16ae90d0275b8e2d2090732e0c53d1405e72347890706436d1c302702eec26ddd01
    7d1127470c57ac0606e02d9ae903010e279b421c02f842c3e10806404aa18206080575f29d050f1c
    c9bd452302e37e02fd0505c9fb159101053b960f521805a950f2830313dd280fd30b025bce5d3f03
    1016c37f16060f8f12b5bb02077158c555030217b2f00a030554637951060e56b537c20a06c39491
    23010e79fa33610707a415a97003032349e79912061a7029570603944ca79a0805f9dcbc52100689
    9bbb35080e2362c46810105b9eca337d030106b625f3fe04061bc04b527d02010519df230f01073b
    ad8d590d076e2f80bf1505293d404a03080297e535100e52a0f9b60210ed0a0150030e3978474111
    02cbc986b21502577a3f3f070e77a0c1cd0b0ef51cb66f1e0215fbf197120ea77c79d0100f383a9f
    570311d220f49608035a6c392f011125379a460c07bee3806809035537063d1a0297cabc037d0201
    06fcc8e3f103060523fbd42102978354db07085d41866b0906a10612131007d720f61c120539e02c
    4604089bb6d0d11302c45e96450b0714346c5d060549bcaa5d0c0239a2bd960a07c343c657017d12
    279624154b1d0239d933d4021374783ff907030740f4ba0402b3518050080795c497b00e0796c34a
    07fffeb6741b4c050804cf162112021aebc1540110ae4e51e7260224464be402034710c22c18028f
    9996e902058a3cb5091002fdf65d59021100095129040369154d8c010f0228c6d400fe15f1c51e20
    02d05e07b702063c6ffd5e0502e0b7cbfc06022fe2177301032b9b1cec1f021391d49d19022fdfae
    902402de1c5155020e211fa4c5070fce4683e71605c018a5631705b62f0fc20705b76dcfb2eff9b6
    6ddf877dcfb76ddbb60dfbb661dbb76ddff66ddbb76ddb307edfb66ddbb67d1bf67ddfb70fdffe71
    dbb66d1bb66ddbb66d
    """
    var keys: [UInt32: Definition] = [:]
    subscript(key: String) -> Definition? {
        get {
            return keys[key.data.sha256.as(UInt32.self)]
        } set {
            keys[key.data.sha256.as(UInt32.self)] = newValue
        }
    }
    init() {
        
    }
    static func update() -> Promise<Definitions> {
        return URLSession.shared
            .get("https://raw.githubusercontent.com/ripple/ripple-binary-codec/master/src/enums/definitions.json")
            .map(on: .web3, AnyReader.init)
            .map(on: .web3, Definitions.init)
    }
    init(json: AnyReader) throws {
        let types = try json.at("TYPES").dictionary { try $0.int() }
        // let ledgerTypes = try json.at("LEDGER_ENTRY_TYPES").dictionary { try $0.int() }
        try! json.at("FIELDS").array {
            let array = try! $0.array()
            let params = array[1]
            assert((params.raw as! [String: Any]).count == 5)
            let name = try array[0].string()
            let info = try Definition(json: params, types: types)
            self[name] = info
        }
    }
    private init(data: DefDataReader) throws {
        let count = try data.int()
        for _ in 0..<count {
            let key: UInt32 = try data.nextRaw()
            let value = try Definition(data: data)
            keys[key] = value
        }
    }
    required init(stringLiteral value: String) {
        let data = try! DefDataReader(value.hex(separateEvery: 40, separator: "\n")).readBits()
        let count = try! data.int()
        for _ in 0..<count {
            let key: UInt32 = try! data.nextRaw()
            let value = try! Definition(data: data)
            keys[key] = value
        }
    }
    private func write(to data: DefDataWriter) {
        data.append(keys.count)
        for (key,value) in keys {
            data.append(raw: key)
            value.write(to: data)
        }
        data.done()
    }
    static func == (l: Definitions, r: Definitions) -> Bool {
        return l.keys == r.keys
    }
}

struct Definition: Equatable {
    let nth: Int
    let isVLEncoded: Bool
    let isSerialized: Bool
    let isSigningField: Bool
    let type: Int
    init(json: AnyReader, types: [String: Int]) throws {
        nth = try json.at("nth").int()
        isVLEncoded = try json.at("isVLEncoded").bool()
        isSerialized = try json.at("isSerialized").bool()
        isSigningField = try json.at("isSigningField").bool()
        type = try types[json.at("type").string()]!
    }
    fileprivate init(data: DefDataReader) throws {
        nth = try data.int()
        isVLEncoded = try data.bool()
        isSerialized = try data.bool()
        isSigningField = try data.bool()
        type = try data.int()
    }
    fileprivate func write(to data: DefDataWriter) {
        data.append(nth)
        data.append(isVLEncoded)
        data.append(isSerialized)
        data.append(isSigningField)
        data.append(type)
    }
}

private class Bits {
    var data: Data = Data()
    var byte: UInt8 = 0
    var position: Int = 0
    subscript(index: Int) -> Bool {
        let byte = data[index / 8]
        return byte[index % 8]
    }
    func next() throws -> Bool {
        let index = position / 8
        guard index < data.count else { throw DataReaderError.notEnoughBytes(index) }
        defer { position += 1 }
        let bit = data[index][position % 8]
        return bit
    }
    func append(_ bit: Bool) {
        if bit {
            byte[position] = true
        }
        position += 1
        if position == 8 {
            data.append(byte)
            byte = 0
            position = 0
        }
    }
}

private class DefDataWriter: DataWriter {
    var bits = Bits()
    override init() {
        super.init()
        append(raw: UInt16(0))
    }
    func append(_ bit: Bool) {
        bits.append(bit)
    }
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
    func done() {
        raw(&data).as(UInt16.self)[0] = UInt16(data.count)
        append(data: bits.data)
        append(byte: bits.byte)
    }
}
private class DefDataReader: DataReader {
    private let bits = Bits()
    func readBits() throws -> Self {
        let a = try next(2)
        bits.data = data
        bits.position = Int(raw(a).as(UInt16.self).at(0)) * 8
        return self
    }
    func int() throws -> Int {
        let firstByte: Int8 = try nextRaw()
        switch firstByte {
        case ..<125:
            return Int(firstByte)
        case 125:
            let value: Int16 = try nextRaw()
            return Int(value)
        case 126:
            let value: Int32 = try nextRaw()
            return Int(value)
        case 127:
            let value: Int64 = try nextRaw()
            return Int(value)
        default:
            fatalError()
        }
    }
    func bool() throws -> Bool {
        let bit = try bits.next()
        return bit
    }
}
extension BinaryInteger {
    subscript<T: BinaryInteger>(index: T) -> Bool {
        get {
            return self & (1 << index) != 0
        }
        set {
            if newValue {
                self |= 1 << index
            } else {
                self &= ~(1 << index)
            }
        }
    }
}
