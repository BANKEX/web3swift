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
    case wrongScheme
    case addressCorrupted
    case hostCorrupted
    case userCorrupted
    case notURL
  }
  
  public var isPay: Bool
  public var targetAddress: String
  public var chainId: BigInt?
  public var functionName: String?
  public var parameters = [String: String]()
  public var string: String {
    var string = "ethereum:"
    if isPay {
      string += "pay-"
    }
    string += targetAddress
    if let chainId = chainId {
      string += "@" + chainId.description
    }
    if let name = functionName {
      string += "/" + name
    }
    if !parameters.isEmpty {
      string += "?" + parameters.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
    }
    return string
  }
  public var url: URL {
    return URL(string: string)!
  }
  
  public init(address: String) {
    isPay = false
    self.targetAddress = address
  }
  
  public init(string: String) throws {
    let prefix = "ethereum:"
    guard string.hasPrefix(prefix) else { throw Error.wrongScheme }
    var string = string
    if !string[prefix.endIndex...].hasPrefix("//") {
      string.insert(contentsOf: "//", at: prefix.endIndex)
    }
    
    
    guard let url = URLComponents(string: string) else { throw Error.notURL }
    var address: String
    if let user = url.user {
      address = user
      guard let host = url.host else { throw Error.userCorrupted }
      chainId = BigInt(host, radix: 16)
    } else {
      guard let host = url.host else { throw Error.hostCorrupted }
      address = host
    }
    let payPrefix = "pay-"
    if address.hasPrefix(payPrefix) {
      self.isPay = true
      address = String(address[payPrefix.endIndex...])
    } else {
      self.isPay = false
    }
    if address.hasPrefix("0x") {
      guard address.count == 42 else { throw Error.addressCorrupted }
      self.targetAddress = address
    } else {
      self.targetAddress = address
    }
    
    functionName = url.path
    url.queryItems?.forEach {
      guard let value = $0.value else { return }
      parameters[$0.name] = value
    }
  }
  
}
