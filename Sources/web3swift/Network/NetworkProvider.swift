//
//  NetworkProvider.swift
//  web3swift
//
//  Created by Dmitry on 14/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit

/// WIP
class NetworkProvider {
    let url: URL
    let lock = NSLock()
    
    var interval: Double = 0.1
    
    private(set) var queue = RequestBatch()
    private(set) var isWaiting: Bool = false
    
    let transport: NetworkProtocol
    
    init(url: URL) {
        transport = URLSession(configuration: .default)
        self.url = url
    }
    
    init(url: URL, transport: NetworkProtocol) {
        self.transport = transport
        self.url = url
    }
    
    /// Send jsonrpc request.
    /// Automatically waits for promises to complete then adds request to the queue.
    ///
    /// - Parameters:
    ///   - method: Api method
    ///   - parameters: Input parameters
    /// - Returns: Promise with response
    func send(_ method: String, _ parameters: JsonRpcInput...) -> Promise<DictionaryReader> {
        // Mapping types, requesting promises
        let mapped = parameters.map { $0.jsonRpcValue(with: self) }
        
        // Making request with mapped parameters
        // We will replace promises later after they complete
        let request = CustomRequest(method: method, parameters: mapped)
        
        // Checking for promises and waiting
        let promises = mapped.compactMap { $0 as? Promise<Any> }
        when(fulfilled: promises).done { _ in
            // Mapping promise results
            request.parameters = parameters.map { element in
                if let promise = element as? Promise<Any> {
                    return (promise.value! as! JsonRpcInput).jsonRpcValue(with: self)
                } else {
                    return element
                }
            }
            // Sending request
            self.send(request: request)
        }.catch(request.resolver.reject)
        return request.promise
    }
    func send(requests: [Request]) {
        sync {
            requests.forEach { queue.append($0) }
            cancel()
            sendAll()
        }
    }
    func append(request: Request) {
        sync {
            queue.append(request)
            wait()
        }
    }
    func send(request: Request) {
        sync {
            queue.append(request)
            cancel()
            sendAll()
        }
    }
    func sendAll() {
        lock.lock()
        let request = queue
        queue = RequestBatch()
        lock.unlock()
        transport.send(request: request, to: url)
    }
    
    
    private func sync(_ execute: ()->()) {
        lock.lock()
        execute()
        lock.unlock()
    }
    private func wait() {
        guard !isWaiting else { return }
        isWaiting = true
        after(seconds: interval).done(waited)
    }
    private func waited() {
        lock.lock()
        defer { lock.unlock() }
        guard isWaiting else { return }
        isWaiting = false
        sendAll()
    }
    private func cancel() {
        guard isWaiting else { return }
        isWaiting = false
    }
}
