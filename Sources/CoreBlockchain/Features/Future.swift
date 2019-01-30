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

public typealias Promise = Future
public typealias Resolver = Future

func when<T>(fulfilled promises: [Promise<T>]) -> Promise<[T]> {
    let future = Future<[T]>()
    var array = [T]()
    var failed = false
    for promise in promises {
        promise.pipe { value in
            lock.lock()
            defer { lock.unlock() }
            guard !failed else { return }
            switch value {
            case .success(let value):
                array.append(value)
                if array.count == promises.count {
                    future.success(array)
                }
            case .failure(let error):
                failed = true
                future.fail(error)
            }
        }
    }
    return future
}
extension Future {
    static func pending() -> (Future<T>,Future<T>) {
        let future = Future<T>()
        return (future,future)
    }
    func fulfill(_ value: T) {
        success(value)
    }
    func reject(_ error: Error) {
        fail(error)
    }
    @discardableResult
    public func done(on queue: DispatchQueue, _ callback: @escaping (T) throws -> ()) -> Self {
        lock.lock()
        defer { lock.unlock() }
        pipes.append(ResultPipe<T>.Async(on: queue, callback))
        return self
    }
    @discardableResult
    public func `catch`(on queue: DispatchQueue, _ callback: @escaping (Error) throws -> ()) -> Self {
        lock.lock()
        defer { lock.unlock() }
        pipes.append(ErrorPipe<T>.Async(on: queue, callback))
        return self
    }
    public func map<U>(on queue: DispatchQueue, _ transform: @escaping (T) throws -> (U)) -> Future<U> {
        let future = Future<U>()
        pipe(on: queue) { result in
            switch result {
            case .success(let value):
                try future.success(transform(value))
            case .failure(let error):
                future.fail(error)
            }
        }
        return future
    }
    public func then<U>(on queue: DispatchQueue, _ makeFuture: @escaping (T) throws -> (Future<U>)) -> Future<U> {
        let future = Future<U>()
        pipe(on: queue) { value in
            switch value {
            case .success(let value):
                let future2 = try makeFuture(value)
                future2.pipe(future.resolve)
            case .failure(let error):
                future.fail(error)
            }
        }
        return future
    }
}


private let lock = NSLock()
public class Future<T> {
    public private(set) var value: FutureValue<T>?
//    var options: FutureOptions = .default
    fileprivate var pipes = [Pipe<T>]()

    public init() {

    }
    public init(error: Error) {
        self.value = .failure(error)
    }
    public init(value: T) {
        self.value = .success(value)
    }

    public func pipe(_ callback: @escaping (FutureValue<T>) throws -> ()) {
        lock.lock()
        defer { lock.unlock() }
        pipes.append(AnyPipe<T>(callback))
    }
    public func pipe(on queue: DispatchQueue, _ callback: @escaping (FutureValue<T>) throws -> ()) {
        lock.lock()
        defer { lock.unlock() }
        pipes.append(AnyPipe<T>.Async(on: queue, callback))
    }
    public func success(_ callback: @escaping (T) throws -> ()) {
        lock.lock()
        defer { lock.unlock() }
        pipes.append(ResultPipe<T>(callback))
    }
    public func fail(_ callback: @escaping (Error) throws -> ()) {
        lock.lock()
        defer { lock.unlock() }
        pipes.append(ErrorPipe<T>(callback))
    }
    public func map<U>(_ transform: @escaping (T) throws -> (U)) -> Future<U> {
        let future = Future<U>()
        pipe { result in
            switch result {
            case .success(let value):
                try future.success(transform(value))
            case .failure(let error):
                future.fail(error)
            }
        }
        return future
    }
    public func then<U>(_ makeFuture: @escaping (T) throws -> (Future<U>)) -> Future<U> {
        let future = Future<U>()
        pipe { value in
            switch value {
            case .success(let value):
                let future2 = try makeFuture(value)
                future2.pipe(future.resolve)
            case .failure(let error):
                future.fail(error)
            }
        }
        return future
    }
    
    public func success(_ value: T) {
        resolve(.success(value))
    }
    public func fail(_ error: Error) {
        resolve(.failure(error))
    }
    public func resolve(_ resolver: () throws -> (T)) {
        do {
            let result = try resolver()
            success(result)
        } catch {
            fail(error)
        }
    }
    public func resolve(_ value: FutureValue<T>) {
        lock.lock()
        self.value = value
        let pipes = self.pipes
        lock.unlock()
        
        switch value {
        case .success(let value):
            success(value, 0, pipes)
        case .failure(let error):
            failed(error, 0, pipes)
        }
    }
    private func success(_ value: T, _ index: Int, _ pipes: [Pipe<T>]) {
        guard index < pipes.count else { return }
        pipes[index].success(value) { error in
            if let error = error {
                self.value = .failure(error)
                self.failed(error, index, pipes)
            } else {
                self.success(value, index + 1, pipes)
            }
        }
    }
    private func failed(_ error: Error, _ index: Int, _ pipes: [Pipe<T>]) {
        guard index < pipes.count else { return }
        pipes[index].fail(error) { newError in
            if let error = newError {
                self.value = .failure(error)
                self.failed(error, index + 1, pipes)
            } else {
                self.failed(error, index + 1, pipes)
            }
        }
    }
}

public enum FutureValue<T> {
    case success(T)
    case failure(Error)
}

private class Pipe<T> {
    func success(_ value: T, completion: @escaping (Error?) -> ()) {
        completion(nil)
    }
    func fail(_ error: Error, completion: @escaping (Error?) -> ()) {
        completion(nil)
    }
}
private class AnyPipe<T>: Pipe<T> {
    let callback: (FutureValue<T>) throws -> ()
    init(_ callback: @escaping (FutureValue<T>) throws -> ()) {
        self.callback = callback
    }
    override func success(_ value: T, completion: @escaping (Error?) -> ()) {
        do {
            try callback(.success(value))
            completion(nil)
        } catch {
            completion(error)
        }
    }
    override func fail(_ error: Error, completion: @escaping (Error?) -> ()) {
        do {
            try callback(.failure(error))
            completion(nil)
        } catch {
            completion(error)
        }
    }
    class Async: AnyPipe<T> {
        let queue: DispatchQueue
        init(on queue: DispatchQueue, _ callback: @escaping (FutureValue<T>) throws -> ()) {
            self.queue = queue
            super.init(callback)
        }
        override func success(_ value: T, completion: @escaping (Error?) -> ()) {
            queue.async {
                super.success(value, completion: completion)
            }
        }
        override func fail(_ error: Error, completion: @escaping (Error?) -> ()) {
            queue.async {
                super.fail(error, completion: completion)
            }
        }
    }
}
private class ResultPipe<T>: Pipe<T> {
    let callback: (T) throws -> ()
    init(_ callback: @escaping (T) throws -> ()) {
        self.callback = callback
    }
    override func success(_ value: T, completion: @escaping (Error?) -> ()) {
        do {
            try callback(value)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    class Async: ResultPipe<T> {
        let queue: DispatchQueue
        init(on queue: DispatchQueue, _ callback: @escaping (T) throws -> ()) {
            self.queue = queue
            super.init(callback)
        }
        override func success(_ value: T, completion: @escaping (Error?) -> ()) {
            queue.async {
                super.success(value, completion: completion)
            }
        }
    }
}
private class ErrorPipe<T>: Pipe<T> {
    let callback: (Error) throws -> ()
    init(_ callback: @escaping (Error) throws -> ()) {
        self.callback = callback
    }
    override func fail(_ error: Error, completion: @escaping (Error?) -> ()) {
        do {
            try callback(error)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    class Async: ErrorPipe<T> {
        let queue: DispatchQueue
        init(on queue: DispatchQueue, _ callback: @escaping (Error) throws -> ()) {
            self.queue = queue
            super.init(callback)
        }
        override func fail(_ error: Error, completion: @escaping (Error?) -> ()) {
            queue.async {
                super.fail(error, completion: completion)
            }
        }
    }
}

