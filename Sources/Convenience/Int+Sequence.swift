//
//  Int+Sequence.swift
//  web3swift
//
//  Created by Dmitry on 25/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

extension Range: IteratorProtocol where Bound == Int {
    public mutating func next() -> Bound? {
        guard lowerBound + 1 < upperBound else { return nil }
        self = lowerBound+1..<upperBound
        return lowerBound
    }
}

extension Int: Sequence {
    public func makeIterator() -> Range<Int> {
        return -1..<self
    }
    public typealias Iterator = Range<Int>
}
