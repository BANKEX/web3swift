//
//  CryptoExtensions.swift
//  web3swift
//
//  Created by Alexander Vlasov on 04.12.2017.
//  Copyright © 2017 Alexander Vlasov. All rights reserved.
//

import Foundation
import CryptoSwift
//import libsodium

func toByteArray<T>(_ value: T) -> [UInt8] {
    var value = value
    return withUnsafeBytes(of: &value) { Array($0) }
}

//public func scryptLibSodium (password: String, salt: Data, length: Int, N: Int, R: Int, P: Int) -> Data? {
//    let BytesMin = Int(crypto_generichash_bytes_min())
//    let BytesMax = Int(crypto_generichash_bytes_max())
//    if length < BytesMin || length > BytesMax {
//        return nil
//    }
//
//    var output = Data(count: length)
//    guard let passwordData = password.data(using: .utf8) else {return nil}
//    let passwordLen = passwordData.count
//    let saltLen = salt.count
//    let result = output.withUnsafeMutableBytes { (outputPtr:UnsafeMutablePointer<UInt8>) -> Int32 in
//        salt.withUnsafeBytes { (saltPointer:UnsafePointer<UInt8>) -> Int32 in
//            passwordData.withUnsafeBytes{ (passwordPointer:UnsafePointer<UInt8>) -> Int32 in
//                let res = crypto_pwhash_scryptsalsa208sha256_ll(passwordPointer, passwordLen,
//                    saltPointer, saltLen,
//                    UInt64(N), UInt32(R), UInt32(P),
//                    outputPtr, length)
//                return res
//            }
//        }
//    }
//    if result != 0 {
//        return nil
//    }
//    return output
//}

public func scrypt (password: String, salt: Data, length: Int, N: Int, R: Int, P: Int) -> Data? {
    guard let passwordData = password.data(using: .utf8) else {return nil}
    guard let deriver = try? Scrypt(password: passwordData.bytes, salt: salt.bytes, dkLen: length, N: N, r: R, p: P) else {return nil}
    guard let result = try? deriver.calculate() else {return nil}
    return Data(result)
}
enum ScryptError: Error {
  case nIsTooLarge
  case rIsTooLarge
  case nMustBeAPowerOf2GreaterThan1
}

/// Implementation of the scrypt key derivation function.
private class Scrypt {
  enum Error: Swift.Error {
    case invalidPassword
    case invalidSalt
  }
  
  /// Configuration parameters.
  private let salt: Array<UInt8> // S
  private let password: Array<UInt8>
  fileprivate let blocksize: Int // 128 * r
  private let dkLen: Int
  private let N: Int
  private let r: Int
  private let p: Int
  
  init(password: Array<UInt8>, salt: Array<UInt8>, dkLen: Int, N: Int, r: Int, p: Int) throws {
    precondition(dkLen > 0)
    precondition(N > 0)
    precondition(r > 0)
    precondition(p > 0)
    
    guard !(N < 2 || (N & (N - 1)) != 0) else { throw ScryptError.nMustBeAPowerOf2GreaterThan1 }
    
    guard N <= .max / 128 / r else { throw ScryptError.nIsTooLarge }
    guard r <= .max / 128 / p else { throw ScryptError.rIsTooLarge }
    
    self.blocksize = 128 * r
    self.N = N
    self.r = r
    self.p = p
    self.password = password
    self.salt = salt
    self.dkLen = dkLen
  }
  
  private var salsaBlock = [UInt32](repeating: 0, count: 16)
  
  
  /// Runs the key derivation function with a specific password.
  func calculate() throws -> [UInt8] {
    // Allocate memory.
    let B = UnsafeMutableRawPointer.allocate(byteCount: 128 * r * p, alignment: 64)
    let XY = UnsafeMutableRawPointer.allocate(byteCount: 256 * r + 64, alignment: 64)
    let V = UnsafeMutableRawPointer.allocate(byteCount: 128 * r * N, alignment: 64)
    
    // Deallocate memory when done
    defer {
      B.deallocate()
      XY.deallocate()
      V.deallocate()
    }
    
    /* 1: (B_0 ... B_{p-1}) <-- PBKDF2(P, S, 1, p * MFLen) */
    let barray = try PKCS5.PBKDF2(password: password, salt: [UInt8](salt), iterations: 1, keyLength: p * 128 * r, variant: .sha256).calculate()
    barray.withUnsafeBytes { p in
      B.copyMemory(from: p.baseAddress!, byteCount: barray.count)
    }
    
    /* 2: for i = 0 to p - 1 do */
    for i in 0 ..< p {
      /* 3: B_i <-- MF(B_i, N) */
      smix(B + i * 128 * r, V.assumingMemoryBound(to: UInt32.self), XY.assumingMemoryBound(to: UInt32.self))
    }
    
    /* 5: DK <-- PBKDF2(P, B, 1, dkLen) */
    let pointer = B.assumingMemoryBound(to: UInt8.self)
    let bufferPointer = UnsafeBufferPointer(start: pointer, count: p * 128 * r)
    let block = [UInt8](bufferPointer)
    return try PKCS5.PBKDF2(password: password, salt: block, iterations: 1, keyLength: dkLen, variant: .sha256).calculate()
  }
  
  /// Computes `B = SMix_r(B, N)`.
  ///
  /// The input `block` must be `128*r` bytes in length; the temporary storage `v` must be `128*r*n` bytes in length;
  /// the temporary storage `xy` must be `256*r + 64` bytes in length. The arrays `block`, `v`, and `xy` must be
  /// aligned to a multiple of 64 bytes.
  private func smix(_ block: UnsafeMutableRawPointer, _ v: UnsafeMutablePointer<UInt32>, _ xy: UnsafeMutablePointer<UInt32>) {
    let X = xy
    let Y = xy + 32 * r
    let Z = xy + 64 * r
    
    /* 1: X <-- B */
    for k in 0 ..< 32 * r {
      X[k] = (block + 4 * k).load(as: UInt32.self)
    }
    
    /* 2: for i = 0 to N - 1 do */
    for i in stride(from: 0, to: N, by: 2) {
      /* 3: V_i <-- X */
      UnsafeMutableRawPointer(v + i * (32 * r)).copyMemory(from: X, byteCount: 128 * r)
      
      /* 4: X <-- H(X) */
      blockMixSalsa8(X, Y, Z)
      
      /* 3: V_i <-- X */
      UnsafeMutableRawPointer(v + (i + 1) * (32 * r)).copyMemory(from: Y, byteCount: 128 * r)
      
      /* 4: X <-- H(X) */
      blockMixSalsa8(Y, X, Z)
    }
    
    /* 6: for i = 0 to N - 1 do */
    for _ in stride(from: 0, to: N, by: 2) {
      /* 7: j <-- Integerify(X) mod N */
      var j = Int(integerify(X) & UInt64(N - 1))
      
      /* 8: X <-- H(X \xor V_j) */
      blockXor(X, v + j * 32 * r, 128 * r)
      blockMixSalsa8(X, Y, Z)
      
      /* 7: j <-- Integerify(X) mod N */
      j = Int(integerify(Y) & UInt64(N - 1))
      
      /* 8: X <-- H(X \xor V_j) */
      blockXor(Y, v + j * 32 * r, 128 * r)
      blockMixSalsa8(Y, X, Z)
    }
    
    /* 10: B' <-- X */
    for k in 0 ..< 32 * r {
      UnsafeMutableRawPointer(block + 4 * k).storeBytes(of: X[k], as: UInt32.self)
    }
  }
  
  /// Returns the result of parsing `B_{2r-1}` as a little-endian integer.
  private func integerify(_ block: UnsafeRawPointer) -> UInt64 {
    let bi = block + (2 * r - 1) * 64
    return bi.load(as: UInt64.self)
  }
  
  /// Compute `bout = BlockMix_{salsa20/8, r}(bin)`.
  ///
  /// The input `bin` must be `128*r` bytes in length; the output `bout` must also be the same size. The temporary
  /// space `x` must be 64 bytes.
  private func blockMixSalsa8(_ bin: UnsafePointer<UInt32>, _ bout: UnsafeMutablePointer<UInt32>, _ x: UnsafeMutablePointer<UInt32>) {
    /* 1: X <-- B_{2r - 1} */
    UnsafeMutableRawPointer(x).copyMemory(from: bin + (2 * r - 1) * 16, byteCount: 64)
    
    /* 2: for i = 0 to 2r - 1 do */
    for i in stride(from: 0, to: 2 * r, by: 2) {
      /* 3: X <-- H(X \xor B_i) */
      blockXor(x, bin + i * 16, 64)
      salsa20_8(x)
      
      /* 4: Y_i <-- X */
      /* 6: B' <-- (Y_0, Y_2 ... Y_{2r-2}, Y_1, Y_3 ... Y_{2r-1}) */
      UnsafeMutableRawPointer(bout + i * 8).copyMemory(from: x, byteCount: 64)
      
      /* 3: X <-- H(X \xor B_i) */
      blockXor(x, bin + i * 16 + 16, 64)
      salsa20_8(x)
      
      /* 4: Y_i <-- X */
      /* 6: B' <-- (Y_0, Y_2 ... Y_{2r-2}, Y_1, Y_3 ... Y_{2r-1}) */
      UnsafeMutableRawPointer(bout + i * 8 + r * 16).copyMemory(from: x, byteCount: 64)
    }
  }
  
  /// Applies the salsa20/8 core to the provided block.
  private func salsa20_8(_ block: UnsafeMutablePointer<UInt32>) {
    salsaBlock.withUnsafeMutableBytes { pointer in
      pointer.baseAddress!.copyMemory(from: UnsafeRawPointer(block), byteCount: 64)
    }
    
    for _ in stride(from: 0, to: 8, by: 2) {
      func R(_ a: UInt32, _ b: UInt32) -> UInt32 {
        return (a << b) | (a >> (32 - b))
      }
      
      // Operate on columns.
      // swiftlint:disable comma
      salsaBlock[ 4] ^= R(salsaBlock[ 0] &+ salsaBlock[12], 7)
      salsaBlock[ 8] ^= R(salsaBlock[ 4] &+ salsaBlock[ 0], 9)
      salsaBlock[12] ^= R(salsaBlock[ 8] &+ salsaBlock[ 4],13)
      salsaBlock[ 0] ^= R(salsaBlock[12] &+ salsaBlock[ 8],18)
      
      salsaBlock[ 9] ^= R(salsaBlock[ 5] &+ salsaBlock[ 1], 7)
      salsaBlock[13] ^= R(salsaBlock[ 9] &+ salsaBlock[ 5], 9)
      salsaBlock[ 1] ^= R(salsaBlock[13] &+ salsaBlock[ 9],13)
      salsaBlock[ 5] ^= R(salsaBlock[ 1] &+ salsaBlock[13],18)
      
      salsaBlock[14] ^= R(salsaBlock[10] &+ salsaBlock[ 6], 7)
      salsaBlock[ 2] ^= R(salsaBlock[14] &+ salsaBlock[10], 9)
      salsaBlock[ 6] ^= R(salsaBlock[ 2] &+ salsaBlock[14],13)
      salsaBlock[10] ^= R(salsaBlock[ 6] &+ salsaBlock[ 2],18)
      
      salsaBlock[ 3] ^= R(salsaBlock[15] &+ salsaBlock[11], 7)
      salsaBlock[ 7] ^= R(salsaBlock[ 3] &+ salsaBlock[15], 9)
      salsaBlock[11] ^= R(salsaBlock[ 7] &+ salsaBlock[ 3],13)
      salsaBlock[15] ^= R(salsaBlock[11] &+ salsaBlock[ 7],18)
      
      // Operate on rows.
      salsaBlock[ 1] ^= R(salsaBlock[ 0] &+ salsaBlock[ 3], 7)
      salsaBlock[ 2] ^= R(salsaBlock[ 1] &+ salsaBlock[ 0], 9)
      salsaBlock[ 3] ^= R(salsaBlock[ 2] &+ salsaBlock[ 1],13)
      salsaBlock[ 0] ^= R(salsaBlock[ 3] &+ salsaBlock[ 2],18)
      
      salsaBlock[ 6] ^= R(salsaBlock[ 5] &+ salsaBlock[ 4], 7)
      salsaBlock[ 7] ^= R(salsaBlock[ 6] &+ salsaBlock[ 5], 9)
      salsaBlock[ 4] ^= R(salsaBlock[ 7] &+ salsaBlock[ 6],13)
      salsaBlock[ 5] ^= R(salsaBlock[ 4] &+ salsaBlock[ 7],18)
      
      salsaBlock[11] ^= R(salsaBlock[10] &+ salsaBlock[ 9], 7)
      salsaBlock[ 8] ^= R(salsaBlock[11] &+ salsaBlock[10], 9)
      salsaBlock[ 9] ^= R(salsaBlock[ 8] &+ salsaBlock[11],13)
      salsaBlock[10] ^= R(salsaBlock[ 9] &+ salsaBlock[ 8],18)
      
      salsaBlock[12] ^= R(salsaBlock[15] &+ salsaBlock[14], 7)
      salsaBlock[13] ^= R(salsaBlock[12] &+ salsaBlock[15], 9)
      salsaBlock[14] ^= R(salsaBlock[13] &+ salsaBlock[12],13)
      salsaBlock[15] ^= R(salsaBlock[14] &+ salsaBlock[13],18)
      // swiftlint:enable comma
    }
    for i in 0 ..< 16 {
      block[i] = block[i] &+ salsaBlock[i]
    }
  }
  
  private func blockXor(_ dest: UnsafeMutableRawPointer, _ src: UnsafeRawPointer, _ len: Int) {
    let D = dest.assumingMemoryBound(to: UInt.self)
    let S = src.assumingMemoryBound(to: UInt.self)
    let L = len / MemoryLayout<UInt>.size
    
    for i in 0 ..< L {
      D[i] ^= S[i]
    }
  }
}
