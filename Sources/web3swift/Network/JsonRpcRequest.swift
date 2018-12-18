//
//  Request.swift
//  web3swift
//
//  Created by Dmitry on 14/12/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//

import Foundation
import PromiseKit

/// WIP
enum JsonRpcError: Error {
    case syntaxError(code: Int, message: String)
    case responseError(code: Int, message: String)
    var localizedDescription: String {
        switch self {
        case let .syntaxError(code: code, message: message):
            return "Json rpc syntax error: \(message) (\(code))"
        case let .responseError(code: code, message: message):
            return "Request failed: \(message) (\(code))"
        }
    }
}

/// WIP
class Request {
    var id = Counter.increment()
    var method: String
    var promise: Promise<DictionaryReader>
    var resolver: Resolver<DictionaryReader>
    
    init(method: String) {
        self.method = method
        (promise,resolver) = Promise.pending()
    }
    
    func response(data: DictionaryReader) throws {
        
    }
    func failed(error: Error) {
        
    }
    func request() -> [Any] {
        return []
    }
    
    func requestBody() -> Any {
        var dictionary = [String: Any]()
        dictionary["jsonrpc"] = "2.0"
        dictionary["method"] = method
        dictionary["id"] = id
        dictionary["params"] = request()
        return dictionary
    }
    
    func request(url: URL) throws -> URLRequest {
        var urlRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody(), options: [])
        return urlRequest
    }
    
    func checkJsonRpcSyntax(data: DictionaryReader) throws {
        try data.at("jsonrpc").string().starts(with: "2.")
        if let error = try? data.at("error") {
            let code = try error.at("code").int()
            let message = try error.at("message").string()
            if data.contains("id") {
                throw JsonRpcError.responseError(code: code, message: message)
            } else {
                throw JsonRpcError.syntaxError(code: code, message: message)
            }
        } else {
            try data.at("id").int()
        }
    }
    func _response(data: DictionaryReader) throws {
        try checkJsonRpcSyntax(data: data)
        try response(data: data.at("result"))
        resolver.fulfill(data)
    }
    func _failed(error: Error) {
        failed(error: error)
        resolver.reject(error)
    }
}

/// WIP
class CustomRequest: Request {
    var parameters: [Any]
    init(method: String, parameters: [Any]) {
        self.parameters = parameters
        super.init(method: method)
    }
    override func request() -> [Any] {
        return parameters
    }
}

/// WIP
class RequestBatch: Request {
    private(set) var requests = [Request]()
    init() {
        super.init(method: "")
    }
    func append(_ request: Request) {
        if let batch = request as? RequestBatch {
            requests.append(contentsOf: batch.requests)
        } else {
            requests.append(request)
        }
    }
    override func response(data: DictionaryReader) throws {
        try data.array {
            let id = try $0.at("id").int()
            guard let request = requests.first(where: {$0.id == id}) else { return }
            do {
                try request._response(data: $0)
            } catch {
                request._failed(error: error)
            }
        }
    }
    override func requestBody() -> Any {
        return requests.map { $0.requestBody() }
    }
}
