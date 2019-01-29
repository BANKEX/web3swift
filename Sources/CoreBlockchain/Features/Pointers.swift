//
//  Pointers.swift
//  DefinitionsParser
//
//  Created by Dmitry on 18/01/2019.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import Foundation

public func raw<T>(_ v: T) -> UnsafeRawPointer {
    return withUnsafeBytes(of: v) { $0.baseAddress! }
}
public func raw<T>(_ v: Array<T>) -> UnsafeRawPointer {
    return v.withUnsafeBytes({$0.baseAddress!})
}
public func raw<T>(_ v: ContiguousArray<T>) -> UnsafeRawPointer {
    return v.withUnsafeBytes({$0.baseAddress!})
}
public func raw(_ v: Data) -> UnsafeRawPointer {
    return UnsafeRawPointer(pointer(v))
}
public func raw<T>(_ v: inout T) -> UnsafeMutableRawPointer {
    return withUnsafeMutableBytes(of: &v) { $0.baseAddress! }
}
public func raw<T>(_ v: inout Array<T>) -> UnsafeMutableRawPointer {
    return v.withUnsafeMutableBytes({$0.baseAddress!})
}
public func raw<T>(_ v: inout ContiguousArray<T>) -> UnsafeMutableRawPointer {
    return v.withUnsafeMutableBytes({$0.baseAddress!})
}
public func raw(_ v: inout Data) -> UnsafeMutableRawPointer {
    return UnsafeMutableRawPointer(pointer(&v))
}
public func pointer<T>(_ v: T) -> UnsafePointer<UInt8> {
    return raw(v).as(UInt8.self)
}
public func pointer<T>(_ v: Array<T>) -> UnsafePointer<UInt8> {
    return raw(v).as(UInt8.self)
}
public func pointer<T>(_ v: ContiguousArray<T>) -> UnsafePointer<UInt8> {
    return raw(v).as(UInt8.self)
}
public func pointer(_ v: Data) -> UnsafePointer<UInt8> {
    return v.withUnsafeBytes { $0 }
}
public func pointer<T>(_ v: inout T) -> UnsafeMutablePointer<UInt8> {
    return raw(&v).as(UInt8.self)
}
public func pointer<T>(_ v: inout Array<T>) -> UnsafeMutablePointer<UInt8> {
    return raw(&v).as(UInt8.self)
}
public func pointer<T>(_ v: inout ContiguousArray<T>) -> UnsafeMutablePointer<UInt8> {
    return raw(&v).as(UInt8.self)
}
public func pointer(_ v: inout Data) -> UnsafeMutablePointer<UInt8> {
    return v.withUnsafeMutableBytes { $0 }
}

public extension Data {
    func `as`<T>(_ type: T.Type) -> T {
        return withUnsafeBytes { (p: UnsafePointer<T>) in p.pointee }
    }
}
public extension UnsafeRawPointer {
    func `as`<T>(_ type: T.Type) -> UnsafePointer<T> {
        return assumingMemoryBound(to: type)
    }
    func offset(_ n: Int) -> UnsafeRawPointer {
        return advanced(by: n)
    }
}
public extension UnsafeMutableRawPointer {
    func `as`<T>(_ type: T.Type) -> UnsafeMutablePointer<T> {
        return assumingMemoryBound(to: type)
    }
    func offset(_ n: Int) -> UnsafeMutableRawPointer {
        return advanced(by: n)
    }
}
public extension UnsafePointer {
    func at(_ index: Int) -> Pointee {
        return self[index]
    }
}
public extension UnsafeMutablePointer {
    func at(_ index: Int) -> Pointee {
        return self[index]
    }
}
