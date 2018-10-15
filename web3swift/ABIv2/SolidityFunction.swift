//
//  SolidityFunction.swift
//  web3swift
//
//  Created by Dmitry on 12/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation

class SolidityFunction {
    let name: String
    init(name: String) {
        self.name = name
    }
}

class SafeSolidityFunction {
    enum Error: Swift.Error {
        case corrupted
        case emptyFunctionName
    }
    let name: String
    let arguments: [String]
    init(function: String) throws {
        var function = function.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let index = function.index(of: "(") else { throw Error.corrupted }
        name = String(function[..<index])
        guard name.count > 0 else { throw Error.emptyFunctionName }
        guard function.hasSuffix(")") else { throw Error.corrupted }
        function.removeLast()
        let arguments = function[function.index(after: index)...]
        self.arguments = arguments.split(separator: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines)}
    }
}
