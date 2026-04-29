//
//  NetworkManagerProtocol.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/11.
//

import Foundation

protocol NetworkManagerProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}
