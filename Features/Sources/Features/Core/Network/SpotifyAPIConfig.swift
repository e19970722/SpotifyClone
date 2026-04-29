//
//  SpotifyAPIConfig.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/19.
//

import Foundation

enum SpotifyAPI {

    /// Spotify Web API base URL，所有 service 共用
    static let baseURL = URL(string: "https://api.spotify.com/v1")!

    /// 從 Keychain 讀取 token，組成 Authorization header
    /// 若 token 不存在回傳空字典（request 會因 401 失敗）
    static var authHeader: [String: String] {
        guard let token = KeychainManager.shared.read(forKey: .accessToken) else { return [:] }
        return ["Authorization": "Bearer \(token)"]
    }
}
