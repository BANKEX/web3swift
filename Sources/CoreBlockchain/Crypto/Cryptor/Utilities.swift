//
//  Utilities.swift
//  Cryptor
//
// 	Licensed under the Apache License, Version 2.0 (the "License");
// 	you may not use this file except in compliance with the License.
// 	You may obtain a copy of the License at
//
// 	http://www.apache.org/licenses/LICENSE-2.0
//
// 	Unless required by applicable law or agreed to in writing, software
// 	distributed under the License is distributed on an "AS IS" BASIS,
// 	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// 	See the License for the specific language governing permissions and
// 	limitations under the License.
//

import Foundation

//
//	Replaces Swift's native `fatalError` function to allow redirection
//	For more details about how this all works see:
//	  https://marcosantadev.com/test-swift-fatalerror/
//
func fatalError(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> Never {
	
	FatalErrorUtil.fatalErrorClosure(message(), file, line)
}

// Convert an UnsafeMutablePointer<Int8>? to a String, providing a
// default value of empty string if the pointer is nil.
//
//	- Parameter ptr: Pointer to string to be converted.
//
//	- Returns: Converted string.
//
func errToString(_ ptr: UnsafeMutablePointer<Int8>?) -> String {
    if let ptr = ptr {
        return String(cString: ptr)
    } else {
        return ""
    }
}

///
/// Allows redirection of `fatalError` for Unit Testing or for
/// library users that want to handle such errors in another way.
///
struct FatalErrorUtil {
	
	static var fatalErrorClosure: (String, StaticString, UInt) -> Never = defaultFatalErrorClosure
	private static let defaultFatalErrorClosure = { Swift.fatalError($0, file: $1, line: $2) }
	static func replaceFatalError(closure: @escaping (String, StaticString, UInt) -> Never) {
		fatalErrorClosure = closure
	}
	static func restoreFatalError() {
		fatalErrorClosure = defaultFatalErrorClosure
	}
	
}

///
/// Various utility functions for conversions
///
public struct CryptoUtils {
	///
	/// Zero pads a byte array such that it is an integral number of `blockSizeinBytes` long.
	///
	/// - Parameters:
 	///		- byteArray: 		The byte array
	/// 	- blockSizeInBytes: The block size in bytes.
	///
	/// - Returns: A Swift string
	///
	public static func zeroPad(byteArray: [UInt8], blockSize: Int) -> [UInt8] {
		
		let pad = blockSize - (byteArray.count % blockSize)
		guard pad != 0 else {
			return byteArray
		}
		return byteArray + Array<UInt8>(repeating: 0, count: pad)
	}
	
	///
	/// Zero pads a String (after UTF8 conversion)  such that it is an integral number of `blockSizeinBytes` long.
	///
	/// - Parameters:
 	///		- string: 			The String
	/// 	- blockSizeInBytes:	The block size in bytes
	///
	/// - Returns: A byte array
	///
	public static func zeroPad(string: String, blockSize: Int) -> [UInt8] {
		
		return zeroPad(byteArray: Array<UInt8>(string.utf8), blockSize: blockSize)
	}
	
}
