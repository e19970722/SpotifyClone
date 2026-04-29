//
//  Endpoint.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/11.
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

struct Endpoint {
    let baseURL: URL
    let path: String
    let method: HTTPMethod
    let headers: [String: String]
    let queryItems: [URLQueryItem]?
    let body: Data?

    init(
        baseURL: URL,
        path: String,
        method: HTTPMethod = .GET,
        headers: [String: String] = [:],
        queryItems: [URLQueryItem]? = nil,
        body: Data? = nil
    ) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
    }

    func urlRequest() throws -> URLRequest {
        var components = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        components?.queryItems = queryItems

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }

#if DEBUG
        var requestStr = request.url?.absoluteString ?? "empty url"
        if !headers.isEmpty {
            requestStr += "\n📋 Headers: "
            if let headersData = try? JSONSerialization.data(withJSONObject: headers, options: .prettyPrinted),
               let headersJSON = String(data: headersData, encoding: .utf8) {
                requestStr += headersJSON
            } else {
                requestStr += "\(headers)"
            }
        }
        
        if let body = body {
            requestStr += "\n📄 Body: "
            if let bodyString = String(data: body, encoding: .utf8) {
                requestStr += bodyString
            } else {
                requestStr += "\(body.count) bytes (binary data)"
            }
        }
        print("========================================")
        print("📦 Request: \(requestStr)")
#endif
        
        return request
    }
}
