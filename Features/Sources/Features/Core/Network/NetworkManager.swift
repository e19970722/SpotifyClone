//
//  NetworkManager.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/11.
//

import Foundation

final class NetworkManager: NetworkManagerProtocol {
    static let shared = NetworkManager()

    private let session: URLSession
    private let decoder: JSONDecoder
    private let timeoutInterval: TimeInterval

    init(
        session: URLSession = .shared,
        decoder: JSONDecoder = .init(),
        timeoutInterval: TimeInterval = 30
    ) {
        self.session = session
        self.decoder = decoder
        self.timeoutInterval = timeoutInterval
    }

    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        var urlRequest = try endpoint.urlRequest()
        urlRequest.timeoutInterval = timeoutInterval

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: urlRequest)
            Utilities.shared.logMessage(target: endpoint.path,
                                        message: String(data: data, encoding: .utf8) ?? "",
                                        isSuccess: true)
            
        } catch let urlError as URLError where urlError.code == .timedOut {
            throw NetworkError.timeout
            
        } catch {
            Utilities.shared.logMessage(target: endpoint.path,
                                        message: error.localizedDescription,
                                        isSuccess: true)
            throw NetworkError.underlying(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw NetworkError.statusCode(http.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
