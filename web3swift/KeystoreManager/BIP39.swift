//
//  BIP39.swift
//  web3swift
//
//  Created by Alexander Vlasov on 11.01.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import CryptoSwift
import Foundation

public enum BIP39Language {
    case english
    case chinese_simplified
    case chinese_traditional
    case japanese
    case korean
    case french
    case italian
    case spanish
    var words: [String] {
        switch self {
        case .english:
            return englishWords
        case .chinese_simplified:
            return simplifiedchineseWords
        case .chinese_traditional:
            return traditionalchineseWords
        case .japanese:
            return japaneseWords
        case .korean:
            return koreanWords
        case .french:
            return frenchWords
        case .italian:
            return italianWords
        case .spanish:
            return spanishWords
        }
    }

    var separator: String {
        switch self {
        case .japanese:
            return "\u{3000}"
        default:
            return " "
        }
    }
}

public enum EntropySize: Int {
    case b128 = 128
    case b160 = 160
    case b192 = 192
    case b224 = 224
    case b256 = 256
}

public class Mnemonics {
    public enum Error: Swift.Error {
        case invalidEntropySize
    }
    public enum EntropyError: Swift.Error {
        case notEnoughtWords
        case invalidNumberOfWords
        case wordNotFound(String)
        case invalidOrderOfWords
        case checksumFailed(String,String)
    }
    public let string: String
    public let language: BIP39Language
    public var entropy: Data
    public var password: String = ""
    
    public static func seed(from mnemonics: String, password: String) -> Data {
        let mnemData = Array(mnemonics.decomposedStringWithCompatibilityMapping.utf8)
        let salt = "mnemonic" + password
        let saltData = Array(salt.decomposedStringWithCompatibilityMapping.utf8)
        
        // PKCS5.PBKDF2 throws only if mnemData.isEmpty
        // or keyLength > variant.digestLength * 256
        // and .calculate() won't throw any errors
        // so i feel free to use "try!"
        let seed = try! PKCS5.PBKDF2(password: mnemData, salt: saltData, iterations: 2048, keyLength: 64, variant: .sha512).calculate()
        return Data(bytes: seed)
    }
    
    public init(_ string: String, language: BIP39Language = .english) throws {
        // checking entropy
        let wordList = string.components(separatedBy: " ")
        guard wordList.count >= 12 else { throw EntropyError.notEnoughtWords }
        guard wordList.count % 4 == 0 else { throw EntropyError.invalidNumberOfWords }

        var bitString = ""
        for word in wordList {
            guard let idx = language.words.index(of: word) else { throw EntropyError.wordNotFound(word) }
            let idxAsInt = language.words.startIndex.distance(to: idx)
            let stringForm = String(UInt16(idxAsInt), radix: 2).leftPadding(toLength: 11, withPad: "0")
            bitString.append(stringForm)
        }
        let stringCount = bitString.count
        guard stringCount % 33 == 0 else { throw EntropyError.invalidOrderOfWords }
        let position = (bitString.count - bitString.count / 33)
        let entropyBits = bitString[0..<position]
        let checksumBits = bitString[position..<bitString.count]
        let entropy = entropyBits.interpretAsBinaryData()
        let checksum = String(entropy.sha256().bitsInRange(0, checksumBits.count), radix: 2).leftPadding(toLength: checksumBits.count, withPad: "0")
        guard checksum == checksumBits else { throw EntropyError.checksumFailed(checksum, checksumBits) }
        self.string = string
        self.language = language
        self.entropy = entropy
    }
    public init(entropySize: EntropySize = .b256, language: BIP39Language = .english) {
        self.entropy = Data.random(length: entropySize.rawValue / 8)
        let checksum = entropy.sha256()
        let checksumBits = entropy.count * 8 / 32
        var fullEntropy = Data()
        fullEntropy.append(entropy)
        fullEntropy.append(checksum[0 ..< (checksumBits + 7) / 8])
        var wordList = [String]()
        for i in 0 ..< fullEntropy.count * 8 / 11 {
            let bits = fullEntropy.bitsInRange(i * 11, 11)
            let index = Int(bits)
            let word = language.words[index]
            wordList.append(word)
        }
        self.string = wordList.joined(separator: language.separator)
        self.language = language
    }
    public init(entropy: Data, language: BIP39Language = .english) throws {
        guard entropy.count >= 16, entropy.count % 4 == 0 else { throw Error.invalidEntropySize }
        let checksum = entropy.sha256()
        let checksumBits = entropy.count * 8 / 32
        var fullEntropy = Data()
        fullEntropy.append(entropy)
        fullEntropy.append(checksum[0 ..< (checksumBits + 7) / 8])
        var wordList = [String]()
        for i in 0 ..< fullEntropy.count * 8 / 11 {
            let bits = fullEntropy.bitsInRange(i * 11, 11)
            let index = Int(bits)
            let word = language.words[index]
            wordList.append(word)
        }
        let separator = language.separator
        self.entropy = entropy
        self.string = wordList.joined(separator: separator)
        self.language = language
    }
    public func seed() -> Data {
        return Mnemonics.seed(from: string, password: password)
    }
}

extension Mnemonics: CustomStringConvertible {
    public var description: String {
        return string
    }
}

