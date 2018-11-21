//
//  SolidityDataReader.swift
//  web3swift
//
//  Created by Dmitry on 11/21/18.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import BigInt

private extension Int {
	var solidityFormatted: Int {
		return (self / 32 + 1) * 32
	}
}

public enum SolidityDataReaderError: Error {
	case notFound
	case wrongType
	case overflows
}
public class SolidityDataReader {
	public let data: Data
	public var position = 0
	public var headerSize = 0
	public init(_ data: Data) {
		self.data = data
	}
	public func uint256() throws -> BigUInt {
		return try BigUInt(next(32))
	}
	public func address() throws -> Address {
		try skip(12)
		return try Address(next(20))
	}
	public func bool() throws -> Bool {
		let value = try BigUInt(next(32))
		guard value < 2 else { throw SolidityDataReaderError.wrongType }
		return value == 1
	}
	public func string32() throws -> String {
		var data = try next(32)
		let index = data.withUnsafeBytes { (pointer: UnsafePointer<UInt8>) -> Int? in
			for i in 0..<data.count where pointer[i] == 0 {
				return i
			}
			return nil
		}
		if let index = index {
			data = data[0..<index]
		}
		guard let string = String(data: data, encoding: .utf8) else { throw SolidityDataReaderError.wrongType }
		return string
	}
	public func string() throws -> String {
		let pointer = try view { try uint256() }
		if pointer == 0 {
			// we already checked next 32 bytes so this shouldn't crash
			try! skip(32)
			return ""
		} else if pointer < Int.max {
			return try stringPointer()
		} else {
			return try string32()
		}
	}
	public func stringPointer() throws -> String {
		return try pointer {
			let length = try intCount()
			guard length > 0 else { return "" }
			let data = try self.next(length)
			guard let string = String(data: data, encoding: .utf8) else { throw SolidityDataReaderError.wrongType }
			return string
		}
	}
	public func array<T>(builder: (SolidityDataReader)throws->(T)) throws -> [T] {
		return try pointer {
			let count = try intCount()
			var array = [T]()
			array.reserveCapacity(count)
			for _ in 0..<count {
				try array.append(builder(self))
			}
			return array
		}
	}
	
	public func header(_ size: Int) throws -> Data {
		let range = position..<position+size
		guard range.upperBound <= data.count else { throw SolidityDataReaderError.notFound }
		position = range.upperBound
		headerSize = size
		return self.data[range]
	}
	public func skip(_ count: Int) throws {
		let end = position+count
		guard end <= data.count else { throw SolidityDataReaderError.notFound }
		position = end
	}
	public func next(_ size: Int) throws -> Data {
		let range = position..<position+size
		guard range.upperBound <= data.count else { throw SolidityDataReaderError.notFound }
		position = range.upperBound
		return self.data[range]
	}
	public func pointer<T>(at: Int, block: ()throws->T) throws -> T {
		let pos = position
		position = at + headerSize
		defer { position = pos }
		return try block()
	}
	public func pointer<T>(block: ()throws->T) throws -> T {
		let pointer = try intCount()
		let pos = position
		position = pointer + headerSize
		defer { position = pos }
		return try block()
	}
	public func view<T>(block: ()throws->T) throws -> T {
		let pos = position
		defer { position = pos }
		return try block()
	}
}
public extension SolidityDataReader {
	private func unsigned<T: BinaryInteger>(max: BigUInt) throws -> T {
		let number = try uint256()
		guard number <= max else { throw SolidityDataReaderError.overflows }
		return T(number)
	}
	private func signed<T: BinaryInteger>(min: BigInt, max: BigInt) throws -> T {
		let number = try uint256()
		guard number >= min && number <= max else { throw SolidityDataReaderError.overflows }
		return T(number)
	}
	func uint8() throws -> UInt8 {
		return try unsigned(max: 0xff)
	}
	func uint16() throws -> UInt16 {
		return try unsigned(max: 0xffff)
	}
	func uint32() throws -> UInt32 {
		return try unsigned(max: 0xffffffff)
	}
	func uint64() throws -> UInt64 {
		return try unsigned(max: 0xffffffffffffffff)
	}
	func uint() throws -> Int64 {
		return try unsigned(max: BigUInt(UInt.max))
	}
	func int8() throws -> Int8 {
		return try signed(min: -0x80, max: 0x7f)
	}
	func int16() throws -> Int16 {
		return try signed(min: -0x8000, max: 0x7fff)
	}
	func int32() throws -> Int32 {
		return try signed(min: -0x80000000, max: 0x7fffffff)
	}
	func int64() throws -> Int64 {
		return try signed(min: -0x8000000000000000, max: 0x7fffffffffffffff)
	}
	func int() throws -> Int64 {
		return try signed(min: BigInt(Int.min), max: BigInt(Int.max))
	}
	func intCount() throws -> Int {
		return try signed(min: 0, max: BigInt(Int.max))
	}
}
