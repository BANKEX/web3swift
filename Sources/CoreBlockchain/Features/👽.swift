//
//  Pointers.swift
//  DefinitionsParser
//
//  Created by Dmitry on 18/01/2019.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import Foundation

prefix operator •
prefix func • <T>(v: T) -> UnsafeRawPointer {
    return withUnsafeBytes(of: v) { $0.baseAddress! }
}
prefix func • <T>(v: Array<T>) -> UnsafeRawPointer {
    return v.withUnsafeBytes({$0.baseAddress!})
}
prefix func • <T>(v: ContiguousArray<T>) -> UnsafeRawPointer {
    return v.withUnsafeBytes({$0.baseAddress!})
}
prefix func • (v: Data) -> UnsafeRawPointer {
    return UnsafeRawPointer(•••v)
}
func • (l: UnsafeRawPointer, r: Int) -> UnsafeRawPointer {
    return l+r
}
func • (l: UnsafeMutableRawPointer, r: Int) -> UnsafeMutableRawPointer {
    return l+r
}

prefix operator ••
prefix func •• <T>(v: inout T) -> UnsafeMutableRawPointer {
    return withUnsafeMutableBytes(of: &v) { $0.baseAddress! }
}
prefix func •• <T>(v: inout Array<T>) -> UnsafeMutableRawPointer {
    return v.withUnsafeMutableBytes({$0.baseAddress!})
}
prefix func •• <T>(v: inout ContiguousArray<T>) -> UnsafeMutableRawPointer {
    return v.withUnsafeMutableBytes({$0.baseAddress!})
}
prefix func •• (v: inout Data) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(••••v)
}


infix operator •: AdditionPrecedence
func • <T>(v: UnsafeRawPointer, t: T.Type) -> UnsafePointer<T> {
    return v.assumingMemoryBound(to: t)
}
func • <T>(v: UnsafeMutableRawPointer, t: T.Type) -> UnsafeMutablePointer<T> {
    return v.assumingMemoryBound(to: t)
}
func • <T>(v: UnsafePointer<T>, o: Int) -> T {
    return v[o]
}
func • <T>(v: UnsafeMutablePointer<T>, o: Int) -> T {
    return v[o]
}

prefix operator •••
prefix func •••<T>(v: T) -> UnsafePointer<UInt8> {
    return •v•UInt8.self
}
prefix func •••<T>(v: Array<T>) -> UnsafePointer<UInt8> {
    return •v•UInt8.self
}
prefix func •••<T>(v: ContiguousArray<T>) -> UnsafePointer<UInt8> {
    return •v•UInt8.self
}
prefix func •••(v: Data) -> UnsafePointer<UInt8> {
    return v.withUnsafeBytes { $0 }
}
prefix operator ••••
prefix func •••• <T>(v: inout T) -> UnsafeMutablePointer<UInt8> {
    return ••v•UInt8.self
}
prefix func •••• <T>(v: inout Array<T>) -> UnsafeMutablePointer<UInt8> {
    return ••v•UInt8.self
}
prefix func •••• <T>(v: inout ContiguousArray<T>) -> UnsafeMutablePointer<UInt8> {
    return ••v•UInt8.self
}
prefix func •••• (v: inout Data) -> UnsafeMutablePointer<UInt8> {
    return v.withUnsafeMutableBytes { $0 }
}
