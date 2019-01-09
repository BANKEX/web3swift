//
//  ResponseProcessing.swift
//  CoreBlockchain
//
//  Created by Dmitry on 09/01/2019.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit

public func _bool(_ data: AnyReader) throws -> Bool {
    return try data.bool()
}
public func _data(_ data: AnyReader) throws -> Data {
    return try data.data()
}
public func _string(_ data: AnyReader) throws -> String {
    return try data.string()
}
public func _int(_ data: AnyReader) throws -> Int {
    return try data.int()
}

public extension Promise where T == AnyReader {
    func bool() -> Promise<Bool> {
        return map(on: .web3, _bool)
    }
    func data() -> Promise<Data> {
        return map(on: .web3, _data)
    }
    func string() -> Promise<String> {
        return map(on: .web3, _string)
    }
    func int() -> Promise<Int> {
        return map(on: .web3, _int)
    }
    func array<T>(_ convert: @escaping (AnyReader)throws->(T)) -> Promise<[T]> {
        return map(on: .web3) { try $0.array().map(convert) }
    }
}
