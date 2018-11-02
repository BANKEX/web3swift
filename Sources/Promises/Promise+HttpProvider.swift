//
//  Promise+HttpProvider.swift
//  web3swift
//
//  Created by Alexander Vlasov on 16.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit

extension Web3HttpProvider {
    static func post(_ request: JsonRpcRequest, providerURL: URL, queue: DispatchQueue = .main, session: URLSession) -> Promise<JsonRpcResponse> {
        let rp = Promise<Data>.pending()
        var task: URLSessionTask?
        queue.async {
            do {
                let encoder = JSONEncoder()
                let requestData = try encoder.encode(request)
                var urlRequest = URLRequest(url: providerURL, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData)
                urlRequest.httpMethod = "POST"
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
                urlRequest.httpBody = requestData
//                let debugValue = try JSONSerialization.jsonObject(with: requestData, options: JSONSerialization.ReadingOptions(rawValue: 0))
//                print(debugValue)
//                let debugString = String(data: requestData, encoding: .utf8)
//                print(debugString)
                task = session.dataTask(with: urlRequest) { data, _, error in
                    guard error == nil else {
                        rp.resolver.reject(error!)
                        return
                    }
                    guard data != nil else {
                        rp.resolver.reject(Web3Error.nodeError("Node response is empty"))
                        return
                    }
                    rp.resolver.fulfill(data!)
                }
                task?.resume()
            } catch {
                rp.resolver.reject(error)
            }
        }
        return rp.promise.ensure(on: queue) {
            task = nil
            }.map(on: queue) { (data: Data) throws -> JsonRpcResponse in
                let parsedResponse = try JSONDecoder().decode(JsonRpcResponse.self, from: data)
            if parsedResponse.error != nil {
                throw Web3Error.nodeError("Received an error message from node\n" + String(describing: parsedResponse.error!))
            }
            return parsedResponse
        }
    }

    static func post(_ request: JsonRpcRequestBatch, providerURL: URL, queue: DispatchQueue = .main, session: URLSession) -> Promise<JsonRpcResponseBatch> {
        let rp = Promise<Data>.pending()
        var task: URLSessionTask?
        queue.async {
            do {
                let encoder = JSONEncoder()
                let requestData = try encoder.encode(request)
                var urlRequest = URLRequest(url: providerURL, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData)
                urlRequest.httpMethod = "POST"
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
                urlRequest.httpBody = requestData
//                let debugValue = try JSONSerialization.jsonObject(with: requestData, options: JSONSerialization.ReadingOptions(rawValue: 0))
//                print(debugValue)
//                let debugString = String(data: requestData, encoding: .utf8)
//                print(debugString)
                task = session.dataTask(with: urlRequest) { data, _, error in
                    guard error == nil else {
                        rp.resolver.reject(error!)
                        return
                    }
                    guard data != nil, data!.count != 0 else {
                        rp.resolver.reject(Web3Error.nodeError("Node response is empty"))
                        return
                    }
                    rp.resolver.fulfill(data!)
                }
                task?.resume()
            } catch {
                rp.resolver.reject(error)
            }
        }
        return rp.promise.ensure(on: queue) {
            task = nil
            }.map(on: queue) { (data: Data) throws -> JsonRpcResponseBatch in
//                let debugValue = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
//                print(debugValue)
            let parsedResponse = try JSONDecoder().decode(JsonRpcResponseBatch.self, from: data)
            return parsedResponse
        }
    }

    public func sendAsync(_ request: JsonRpcRequest, queue: DispatchQueue = .main) -> Promise<JsonRpcResponse> {
        return Web3HttpProvider.post(request, providerURL: url, queue: queue, session: session)
    }

    public func sendAsync(_ requests: JsonRpcRequestBatch, queue: DispatchQueue = .main) -> Promise<JsonRpcResponseBatch> {
        return Web3HttpProvider.post(requests, providerURL: url, queue: queue, session: session)
    }
}
