//
//  MockTokenRefresher.swift
//  SpotifyCloneTests
//
//  Created by Yen Lin on 2026/4/16.
//

import Foundation
@testable import SpotifyClone

final class MockTokenRefresher: TokenRefreshProtocol {

    var result: Result<SpotifyTokenResponse, Error> = .success(
        SpotifyTokenResponse(
            accessToken:  "new_access_token",
            tokenType:    "Bearer",
            expiresIn:    3600,
            refreshToken: "new_refresh_token",
            scope:        nil
        )
    )
    /// refresh 次數
    var callCount: Int = 0
    /// 可選：人工延遲（秒），用來模擬 refresh 需要時間完成
    var delay: TimeInterval = 0

    func refreshAccessToken(refreshToken: String) async throws -> SpotifyTokenResponse {
        callCount += 1
        if delay > 0 {
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
        return try result.get()
    }
}
