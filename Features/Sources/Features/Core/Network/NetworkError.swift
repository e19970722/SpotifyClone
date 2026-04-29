//
//  NetworkError.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/11.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case timeout
    case decodingFailed(Error)
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .invalidResponse:
            return "Invalid server response."
        case .statusCode(let code):
            return "Request failed with status code \(code)."
        case .timeout:
            return "Request timed out."
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .underlying(let error):
            return error.localizedDescription
        }
    }
}
