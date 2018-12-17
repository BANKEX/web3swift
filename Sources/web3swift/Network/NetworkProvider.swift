//
//  NetworkProvider.swift
//  web3swift
//
//  Created by Dmitry on 14/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit
import BigInt

protocol JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any
}
extension Int: JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return self
    }
}
extension BigUInt: JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return "0x" + String(self, radix: 16, uppercase: false)
    }
}
extension Address: JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return address
    }
}
extension String: JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return self
    }
}
extension BlockNumber: JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return promise(network: network).jsonRpcValue(with: network)
    }
}
extension Data: JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return hex.withHex
    }
}
extension Promise: JsonRpcInput where T: JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return map { $0 as Any }
    }
}
extension Dictionary: JsonRpcInput where Key == String, Value: JsonRpcInput {
    func jsonRpcValue(with network: NetworkProvider) -> Any {
        return mapValues { $0.jsonRpcValue(with: network) }
    }
}

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
    
    func send(_ method: String, _ parameters: JsonRpcInput...) -> Promise<DictionaryReader> {
        let request = CustomRequest(method: method, parameters: parameters)
        let promises = parameters.compactMap { $0 as? Promise<Any> }
        when(fulfilled: promises).done { _ in
            request.parameters = parameters.map { element in
                if let promise = element as? Promise<Any> {
                    return (promise.value! as! JsonRpcInput).jsonRpcValue(with: self)
                } else {
                    return element
                }
            }
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
