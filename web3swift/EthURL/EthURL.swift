//
//  EthURL.swift
//  web3swift
//
//  Created by Dmitry on 02/10/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

public class EthURL {
  public enum Error: Swift.Error {
    case corrupted
  }

  public var payPrefix: Bool
  public var targetAddress: String
  public var chainId: BigInt?
  public var functionName: String?
  public var parameters = [String: String]()

  public init(string: String) throws {
    let slicer = StringSlicer(string: string)
    try slicer.check("ethereum:")
    payPrefix = try slicer.next(is: "pay-")
    if payPrefix {
      slicer.skip("pay-")
    }
    if try slicer.next(is: "0x") {
      targetAddress = try slicer.next(80)
    } else {
      var set = Set("@/?")
      var lastCharacter: Character
      (targetAddress, lastCharacter) = try slicer.next(until: set, includeLastCharacter: false)
      if lastCharacter == "@" {
        set.remove("@")
        let chainId: String
        (chainId, lastCharacter) = try slicer.next(until: set, includeLastCharacter: false)
        self.chainId = BigInt(chainId, radix: 16)
      }
      if lastCharacter == "/" {
        set.remove("/")
        let functionName: String
        (functionName, lastCharacter) = try slicer.next(until: set, includeLastCharacter: false)
        self.functionName = functionName
      }
      if lastCharacter == "?" {
        set.remove("?")
        let parameters = slicer.string[slicer.position...]
        let slice = parameters.split(separator: "&")
        for parameter in slice {
          let a = parameter.split(separator: "=")
          guard a.count == 2 else { throw Error.corrupted }
          let key = String(a[0])
          let value = String(a[1])
          self.parameters[key] = value
        }
      }
    }
  }
}

private class StringSlicer {
  enum Error: Swift.Error {
    case notFound, outOfRange
  }
  var position = 0
  var string: String
  init(string: String) {
    self.string = string
  }
  @inline(__always)
  func next(is string: String) throws -> Bool {
    return try view(string.count) == string
  }
  @inline(__always)
  func skip(_ string: String) {
    position += string.count
  }
  @inline(__always)
  func skip(_ count: Int) {
    position += count
  }
  func view(_ size: Int) throws -> String {
    let end = position + size
    guard string.count < end else { throw Error.outOfRange }
    return string[position..<end]
  }
  func check(_ a: String) throws {
    let b = try next(string.count)
    guard a == b else { throw Error.notFound }
  }
  func next(_ size: Int) throws -> String {
    let end = position + size
    guard string.count < end else { throw Error.outOfRange }
    let result = string[position..<end]
    position = end
    return result
  }
  func next(until character: Character) throws -> String {
    guard let index = string[position...].index(of: character) else { throw Error.notFound }
    return try next(index.encodedOffset)
  }
  func next(until set: Set<Character>, includeLastCharacter: Bool) throws -> (String, Character) {
    for (index,character) in string[position...].enumerated() {
      if set.contains(character) {
        if includeLastCharacter {
          return (try next(index), character)
        } else {
          return (try next(index-1), character)
        }
      }
    }
    return (string[position...], " ")
  }
}
