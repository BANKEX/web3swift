//
//  CryptoExtensions.swift
//  web3swift
//
//  Created by Alexander Vlasov on 04.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

//import Cryptor
import Foundation

/**
 Scrypt function. Used to generate derivedKey from password, salt, n, r, p
 */


//func toByteArray<T>(_ value: T) -> [UInt8] {
//    var value = value
//    return withUnsafeBytes(of: &value) { Array($0) }
//}
//
//enum ScryptError: Error {
//    case nIsTooLarge
//    case rIsTooLarge
//    case nMustBeAPowerOf2GreaterThan1
//    
//    var localizedDescription: String {
//        switch self {
//        case .nIsTooLarge:
//            return "Scrypt error: N is too large"
//        case .rIsTooLarge:
//            return "Scrypt error: R is too large"
//        case .nMustBeAPowerOf2GreaterThan1:
//            return "Scrypt error: N must be a power of two and greater than 1"
//        }
//    }
//}
