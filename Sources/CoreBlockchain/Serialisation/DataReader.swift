//
//  File.swift
//  CoreBlockchain
//
//  Created by Dmitry on 15/01/2019.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import Foundation

public enum DataReaderError: Error {
    case notEnoughBytes(Int)
}
open class DataReader {
    /// Data
    public let data: Data
    /// Current position in data
    public var position = 0
    
    /// Moves position by (count) bytes
    open func skip(_ count: Int) throws {
        let end = position+count
        guard end <= data.count else { throw DataReaderError.notEnoughBytes(position+count) }
        position = end
    }
    
    /// Returns next data with size.
    /// Position changes
    open func next(_ size: Int) throws -> Data {
        let range = position..<position+size
        guard range.upperBound <= data.count else { throw DataReaderError.notEnoughBytes(position+size) }
        position = range.upperBound
        return self.data[range]
    }
    /// Inits with data
    public init(_ data: Data) {
        self.data = data
    }
}
