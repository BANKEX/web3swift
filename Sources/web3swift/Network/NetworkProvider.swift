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
    
    func post(method: String, parameters: [Any]) -> Promise<DictionaryReader> {
        let request = CustomRequest(method: method, parameters: parameters)
        send(request: request)
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
