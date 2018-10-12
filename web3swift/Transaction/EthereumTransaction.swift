//
//  EthereumTransaction.swift
//  web3swift
//
//  Created by Alexander Vlasov on 05.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import BigInt
import Foundation

public enum DictionaryError: Error {
    case keyNotFound(dictionary: [String: Any], key: String)
    case bigUInt(dictionary: [String: Any], key: String, value: String)
    case string(dictionary: [String: Any], key: String, value: Any)
    case address(dictionary: [String: Any], key: String, value: String)
}

extension Dictionary where Key == String, Value == Any {
    func address(_ key: String) throws -> EthereumAddress {
        let string = try self.string(key)
        guard string != "0x" && string == "0x0" else { return .contractDeployment }
        let address = EthereumAddress(string)
        guard address.isValid else { throw DictionaryError.address(dictionary: self, key: key, value: string) }
        return address
    }

    func bigUInt(_ bigUInt: inout BigUInt, _ key: String) throws {
        guard self[key] != nil else { return }
        bigUInt = try self.bigUInt(key)
    }

    func value(_ key: String) throws -> Any {
        guard let value = self[key] else { throw DictionaryError.keyNotFound(dictionary: self, key: key) }
        return value
    }

    func string(_ key: String) throws -> String {
        let value = try self.value(key)
        guard let string = value as? String else { throw DictionaryError.string(dictionary: self, key: key, value: value) }
        return string
    }

    func bigUInt(_ key: String) throws -> BigUInt {
        let string = try self.string(key)
        guard let number = BigUInt(string.withoutHex, radix: 16) else { throw DictionaryError.bigUInt(dictionary: self, key: key, value: string) }
        return number
    }

    func hexData(_ key: String) throws -> Data {
        let string = try self.string(key)
        guard let data = try? string.dataFromHex() else { throw DictionaryError.bigUInt(dictionary: self, key: key, value: string) }
        return data
    }
}

public struct EthereumTransaction: CustomStringConvertible {
    public var nonce: BigUInt
    public var gasPrice: BigUInt = 0
    public var gasLimit: BigUInt = 0
    public var to: EthereumAddress
    public var value: BigUInt
    public var data: Data
    public var v: BigUInt = 1
    public var r: BigUInt = 0
    public var s: BigUInt = 0
    var chainID: NetworkId?

    public var inferedChainID: NetworkId? {
        if r == 0 && s == 0 {
            return NetworkId(v)
        } else if v == 27 || v == 28 {
            return nil
        } else {
            return NetworkId((v - 1) / 2 - 17)
        }
    }

    public var intrinsicChainID: BigUInt? {
        return chainID?.rawValue
    }

    public mutating func UNSAFE_setChainID(_ chainID: NetworkId?) {
        self.chainID = chainID
    }

    public var hash: Data? {
        var encoded: Data
        let inferedChainID = self.inferedChainID
        if inferedChainID != nil {
            guard let enc = self.self.encode(forSignature: false, chainID: inferedChainID) else { return nil }
            encoded = enc
        } else {
            guard let enc = self.self.encode(forSignature: false, chainID: self.chainID) else { return nil }
            encoded = enc
        }
        let hash = encoded.sha3(.keccak256)
        return hash
    }

    public init(gasPrice: BigUInt, gasLimit: BigUInt, to: EthereumAddress, value: BigUInt, data: Data) {
        nonce = BigUInt(0)
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.value = value
        self.data = data
        self.to = to
    }

    public init(to: EthereumAddress, data: Data, options: Web3Options) {
        let merged = Web3Options.default.merge(with: options)
        nonce = BigUInt(0)
        gasLimit = merged.gasLimit!
        gasPrice = merged.gasPrice!
        value = merged.value!
        self.to = to
        self.data = data
    }

    public init(nonce: BigUInt, gasPrice: BigUInt, gasLimit: BigUInt, to: EthereumAddress, value: BigUInt, data: Data, v: BigUInt, r: BigUInt, s: BigUInt) {
        self.nonce = nonce
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.to = to
        self.value = value
        self.data = data
        self.v = v
        self.r = r
        self.s = s
    }

    public func mergedWithOptions(_ options: Web3Options) -> EthereumTransaction {
        var tx = self
        if options.gasPrice != nil {
            tx.gasPrice = options.gasPrice!
        }
        if options.gasLimit != nil {
            tx.gasLimit = options.gasLimit!
        }
        if options.value != nil {
            tx.value = options.value!
        }
        if options.to != nil {
            tx.to = options.to!
        }
        return tx
    }

    public var description: String {
        var toReturn = ""
        toReturn = toReturn + "Transaction" + "\n"
        toReturn = toReturn + "Nonce: " + String(nonce) + "\n"
        toReturn = toReturn + "Gas price: " + String(gasPrice) + "\n"
        toReturn = toReturn + "Gas limit: " + String(describing: gasLimit) + "\n"
        toReturn = toReturn + "To: " + to.address + "\n"
        toReturn = toReturn + "Value: " + String(value) + "\n"
        toReturn = toReturn + "Data: " + data.toHexString().withHex.lowercased() + "\n"
        toReturn = toReturn + "v: " + String(v) + "\n"
        toReturn = toReturn + "r: " + String(r) + "\n"
        toReturn = toReturn + "s: " + String(s) + "\n"
        toReturn = toReturn + "Intrinsic chainID: " + String(describing: chainID) + "\n"
        toReturn = toReturn + "Infered chainID: " + String(describing: inferedChainID) + "\n"
        toReturn = toReturn + "sender: " + String(describing: sender?.address) + "\n"
        toReturn = toReturn + "hash: " + String(describing: hash?.toHexString().withHex) + "\n"
        return toReturn
    }

    public var sender: EthereumAddress? {
        guard let publicKey = self.recoverPublicKey() else { return nil }
        return try? Web3.Utils.publicToAddress(publicKey)
    }

    public func recoverPublicKey() -> Data? {
        // !(r == 0 && s == 0)
        guard r != 0 || s != 0 else { return nil }
        var normalizedV: BigUInt = 0
        let inferedChainID = self.inferedChainID
        if let chainId = chainID?.rawValue, chainId != 0 {
            normalizedV = v - 35 - chainId - chainId
        } else if let inferedChainID = inferedChainID?.rawValue {
            normalizedV = v - 35 - inferedChainID - inferedChainID
        } else {
            normalizedV = v - 27
        }
        guard let vData = normalizedV.serialize().setLengthLeft(1) else { return nil }
        guard let rData = r.serialize().setLengthLeft(32) else { return nil }
        guard let sData = s.serialize().setLengthLeft(32) else { return nil }
        guard let signatureData = try? SECP256K1.marshalSignature(v: vData, r: rData, s: sData) else { return nil }
        var hash: Data
        if let inferedChainID = inferedChainID {
            guard let h = self.hashForSignature(chainID: inferedChainID) else { return nil }
            hash = h
        } else {
            guard let h = self.hashForSignature(chainID: self.chainID) else { return nil }
            hash = h
        }
        guard let publicKey = try? SECP256K1.recoverPublicKey(hash: hash, signature: signatureData) else { return nil }
        return publicKey
    }

    public var txhash: String? {
        guard sender != nil else { return nil }
        guard let hash = self.hash else { return nil }
        let txid = hash.toHexString().withHex.lowercased()
        return txid
    }

    public var txid: String? {
        return txhash
    }

    public func encode(forSignature: Bool = false, chainID: NetworkId? = nil) -> Data? {
        if forSignature {
            if chainID != nil {
                let fields = [nonce, gasPrice, gasLimit, to.addressData, value, data, chainID!, BigUInt(0), BigUInt(0)] as [AnyObject]
                return RLP.encode(fields)
            } else if self.chainID != nil {
                let fields = [nonce, gasPrice, gasLimit, to.addressData, value, data, chainID!, BigUInt(0), BigUInt(0)] as [AnyObject]
                return RLP.encode(fields)
            } else {
                let fields = [nonce, gasPrice, gasLimit, to.addressData, value, data] as [AnyObject]
                return RLP.encode(fields)
            }
        } else {
            let fields = [nonce, gasPrice, gasLimit, to.addressData, value, data, v, r, s] as [AnyObject]
            return RLP.encode(fields)
        }
    }

    public func encodeAsDictionary(from: EthereumAddress? = nil) -> TransactionParameters? {
        var toString: String?
        switch to.type {
        case .normal:
            toString = to.address.lowercased()
        case .contractDeployment:
            break
        }
        var params = TransactionParameters(from: from?.address.lowercased(),
                                           to: toString)
        let gasEncoding = gasLimit.abiEncode(bits: 256)
        params.gas = gasEncoding?.toHexString().withHex.stripLeadingZeroes()
        let gasPriceEncoding = gasPrice.abiEncode(bits: 256)
        params.gasPrice = gasPriceEncoding?.toHexString().withHex.stripLeadingZeroes()
        let valueEncoding = value.abiEncode(bits: 256)
        params.value = valueEncoding?.toHexString().withHex.stripLeadingZeroes()
        if data != Data() {
            params.data = data.toHexString().withHex
        } else {
            params.data = "0x"
        }
        return params
    }

    public func hashForSignature(chainID: NetworkId? = nil) -> Data? {
        guard let encoded = self.encode(forSignature: true, chainID: chainID) else { return nil }
        let hash = encoded.sha3(.keccak256)
        return hash
    }

    init(_ json: [String: Any]) throws {
        let options = try Web3Options(json)
        let to = try json.address("to")
        let data: Data
        if json["data"] != nil {
            data = try json.hexData("data")
        } else if json["input"] != nil {
            data = try json.hexData("input")
        } else {
            throw DictionaryError.keyNotFound(dictionary: json, key: "data")
        }
        self.init(to: to, data: data, options: options)
        try json.bigUInt(&nonce, "nonce")
        try json.bigUInt(&v, "v")
        try json.bigUInt(&r, "r")
        try json.bigUInt(&s, "s")
        try json.bigUInt(&value, "value")
        if let inferedChainID = inferedChainID, v >= 37 {
            chainID = inferedChainID
        }
    }

    public static func fromRaw(_ raw: Data) -> EthereumTransaction? {
        guard let totalItem = RLP.decode(raw) else { return nil }
        guard let rlpItem = totalItem[0] else { return nil }
        switch rlpItem.count {
        case 9?:
            guard let nonceData = rlpItem[0]!.data else { return nil }
            let nonce = BigUInt(nonceData)
            guard let gasPriceData = rlpItem[1]!.data else { return nil }
            let gasPrice = BigUInt(gasPriceData)
            guard let gasLimitData = rlpItem[2]!.data else { return nil }
            let gasLimit = BigUInt(gasLimitData)
            var to: EthereumAddress
            switch rlpItem[3]!.content {
            case .noItem:
                to = .contractDeployment
            case let .data(addressData):
                if addressData.count == 0 {
                    to = .contractDeployment
                } else if addressData.count == 20 {
                    to = EthereumAddress(addressData)
                } else {
                    return nil
                }
            case .list:
                return nil
            }
            guard let valueData = rlpItem[4]!.data else { return nil }
            let value = BigUInt(valueData)
            guard let transactionData = rlpItem[5]!.data else { return nil }
            guard let vData = rlpItem[6]!.data else { return nil }
            let v = BigUInt(vData)
            guard let rData = rlpItem[7]!.data else { return nil }
            let r = BigUInt(rData)
            guard let sData = rlpItem[8]!.data else { return nil }
            let s = BigUInt(sData)
            return EthereumTransaction(nonce: nonce, gasPrice: gasPrice, gasLimit: gasLimit, to: to, value: value, data: transactionData, v: v, r: r, s: s)
        case 6?:
            return nil
        default:
            return nil
        }
    }

    static func createRequest(method: JSONRPCmethod, transaction: EthereumTransaction, onBlock: String? = nil, options: Web3Options?) -> JSONRPCrequest? {
        var request = JSONRPCrequest()
        request.method = method
//        guard let from = options?.from else { return nil }
        guard var txParams = transaction.encodeAsDictionary(from: options?.from) else { return nil }
        if method == .estimateGas || options?.gasLimit == nil {
            txParams.gas = nil
        }
        var params = [txParams] as Array<Encodable>
        if method.requiredNumOfParameters == 2 && onBlock != nil {
            params.append(onBlock as Encodable)
        }
        let pars = JSONRPCparams(params: params)
        request.params = pars
        if !request.isValid { return nil }
        return request
    }

    static func createRawTransaction(transaction: EthereumTransaction) -> JSONRPCrequest? {
        guard transaction.sender != nil else { return nil }
        guard let encodedData = transaction.encode() else { return nil }
        let hex = encodedData.toHexString().withHex.lowercased()
        var request = JSONRPCrequest()
        request.method = JSONRPCmethod.sendRawTransaction
        let params = [hex] as Array<Encodable>
        let pars = JSONRPCparams(params: params)
        request.params = pars
        if !request.isValid { return nil }
        return request
    }
}
