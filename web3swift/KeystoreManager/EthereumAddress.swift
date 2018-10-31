//
//  EthereumAddress.swift
//  web3swift
//
//  Created by Alexander Vlasov on 07.01.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import BigInt
import Foundation

public enum AddressError: Error {
    case invalidAddress(String)
}

public struct EthereumAddress: Equatable {
    public enum AddressType {
        case normal
        case contractDeployment
    }

    public var isValid: Bool {
        switch type {
        case .normal:
            return addressData.count == 20
        case .contractDeployment:
            return true
        }
    }

    var _address: String
    public var type: AddressType = .normal
    public static func == (lhs: EthereumAddress, rhs: EthereumAddress) -> Bool {
        return lhs.address.lowercased() == rhs.address.lowercased() && lhs.type == rhs.type
    }

    public var addressData: Data {
        switch type {
        case .normal:
            guard let dataArray = Data.fromHex(_address) else { return Data() }
            return dataArray
        //                guard let d = dataArray.setLengthLeft(20) else { return Data()}
        //                return d
        case .contractDeployment:
            return Data()
        }
    }

    public var address: String {
        switch type {
        case .normal:
            return EthereumAddress.toChecksumAddress(_address)!
        case .contractDeployment:
            return "0x"
        }
    }

    public static func toChecksumAddress(_ addr: String) -> String? {
        let address = addr.lowercased().withoutHex
        guard let hash = address.data(using: .ascii)?.sha3(.keccak256).toHexString() else { return nil }
        var ret = "0x"

        for (i, char) in address.enumerated() {
            let startIdx = hash.index(hash.startIndex, offsetBy: i)
            let endIdx = hash.index(hash.startIndex, offsetBy: i + 1)
            let hashChar = String(hash[startIdx ..< endIdx])
            let c = String(char)
            guard let int = Int(hashChar, radix: 16) else { return nil }
            if int >= 8 {
                ret += c.uppercased()
            } else {
                ret += c
            }
        }
        return ret
    }

    public init(_ addressString: String, type: AddressType = .normal) {
        switch type {
        case .normal:
            // check for checksum
            _address = addressString.withHex
            self.type = .normal
        case .contractDeployment:
            _address = "0x"
            self.type = .contractDeployment
        }
    }

    public init(_ addressData: Data, type: AddressType = .normal) {
        _address = addressData.toHexString().withHex
        self.type = type
    }
    public func check() throws {
        guard isValid else { throw AddressError.invalidAddress(_address) }
    }

    public static var contractDeployment: EthereumAddress {
        return EthereumAddress("0x", type: .contractDeployment)
    }
    
    //    public static func fromIBAN(_ iban: String) -> EthereumAddress {
    //
    //    }
}

extension EthereumAddress: CustomStringConvertible {
    public var description: String {
        return address
    }
}

extension EthereumAddress: ExpressibleByStringLiteral {
    public typealias StringLiteralType = String
    public init(stringLiteral value: StringLiteralType) {
        self.init(value)
    }
}

public extension String {
    var isContractAddress: Bool {
        return Data(hex: self).count > 0
    }

    var isAddress: Bool {
        return Data(hex: self).count == 20
    }

    var contractAddress: EthereumAddress {
        return EthereumAddress(self, type: .contractDeployment)
    }
}
