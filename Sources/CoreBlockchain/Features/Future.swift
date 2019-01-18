//
//  Future.swift
//  web3swift
//
//  Created by Dmitry on 1/14/19.
//  Copyright © 2019 Bankex Foundation. All rights reserved.
//

import Foundation

//public struct FutureOptions: OptionSet {
//    public let rawValue: Int
//    public init(rawValue: Int) { self.rawValue = rawValue }
//    static let isCompleted = FutureOptions(rawValue: 0b1)
//    static let isRunning = FutureOptions(rawValue: 0b10)
//    static let isCancellable = FutureOptions(rawValue: 0b100)
//    static let isCancelled = FutureOptions(rawValue: 0b1000)
//    static let `default` = FutureOptions(rawValue: 0)
//}



//private let lock = NSLock()
//public class Future<T> {
//    var value: FutureValue<T>?
////    var options: FutureOptions = .default
//    var pipes = [(FutureValue<T>) throws -> ()]()
//
//    init() {
//
//    }
//    init(error: Error) {
//        self.value = .failure(error)
//    }
//    init(value: T) {
//        self.value = .success(value)
//    }
//
//    func pipe(_ callback: @escaping (FutureValue<T>) throws -> ()) {
//        pipes.append(callback)
//    }
//    func success(_ callback: @escaping (T) throws -> ()) {
//        pipe { result in
//            try result.onSuccess(callback)
//        }
//    }
//    func fail(_ callback: @escaping (Error) throws -> ()) {
//
//    }
//}
//
//public struct APromise<T> {
//    let future = Future<T>()
//    init() {
//
//    }
//    func success(_ value: T) {
//        resolve(.success(value))
//    }
//    func fail(_ error: Error) {
//        resolve(.failure(error))
//    }
//    func resolve(_ value: FutureValue<T>) {
//        lock.lock()
//        defer { lock.unlock() }
//        switch value {
//        case .success(let value):
//            for (index,pipe) in future.pipes.enumerated() {
//                do {
//
//                } catch {
//                    return
//                }
//            }
//        case .failure(let error):
//
//        }
//        var value = value
//        for pipe in future.pipes {
//
//        }
//    }
//    private func send(value: FutureValue<T>, toFuturesFromIndex index: Int) {
//        for pipe in future.pipes[index...] {
//            try? pipe(value)
//        }
//    }
//}
//
//public enum FutureValue<T> {
//    case success(T)
//    case failure(Error)
//    func onSuccess(_ execute: (T) throws -> ()) rethrows {
//        guard case .success(let v) = self else { return }
//        try execute(v)
//    }
//    func onFailure(_ execute: (Error) throws -> ()) rethrows {
//        guard case .failure(let v) = self else { return }
//        try execute(v)
//    }
//}
