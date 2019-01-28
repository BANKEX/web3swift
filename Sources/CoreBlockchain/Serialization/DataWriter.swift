//
//  DataWriter.swift
//  CoreBlockchain
//
//  Created by Dmitry on 15/01/2019.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import Foundation

open class DataWriter {
    public var data: Data
    public init() {
        self.data = Data()
    }
    public init(data: Data) {
        self.data = data
    }
    open func append(data: Data) {
        self.data.append(data)
    }
    open func append(byte: UInt8) {
        data.append(byte)
    }
    open func append(bytes: [UInt8]) {
        data.append(contentsOf: bytes)
    }
    open func append(string: String) {
        data.append(string.data(using: .utf8)!)
    }
    open func append<T>(raw value: T) {
        data.append(raw: value)
    }
}

private extension Data {
    mutating func append<T>(raw: T) {
        let count = MemoryLayout<T>.size
        append(•••raw, count: count)
    }
}
