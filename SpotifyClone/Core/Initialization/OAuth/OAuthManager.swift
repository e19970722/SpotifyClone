//
//  OAuthManager.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2025/10/31.
//

import Foundation
import AuthenticationServices
import CryptoKit

// MARK: - Token Response Model

struct SpotifyTokenResponse: Decodable {
    let accessToken: String
    let tokenType: String
    let expiresIn: Int
    let refreshToken: String?
    let scope: String?

    enum CodingKeys: String, CodingKey {
        case accessToken  = "access_token"
        case tokenType    = "token_type"
        case expiresIn    = "expires_in"
        case refreshToken = "refresh_token"
        case scope
    }
}

// MARK: - OAuthManager

class OAuthManager: NSObject {

    // MARK: - Private Enums

    private enum OAuthError: Error {
        case invalidURL
        case invalidCallbackURL
        case missingCode
        case tokenExchangeFailed
        case cancelled
    }

    // MARK: - Spotify Config

    private let clientID    = "70cf3e0b631148cc95f004f8f7b62b1d"
    private let redirectURI = "spotifyclone://callback"
    private let scopes      = "user-read-private user-library-read user-read-email playlist-read-private playlist-read-collaborative"

    // MARK: - Internal Properties

    static let instance = OAuthManager()

    // MARK: - Private Properties

    private var authSession: ASWebAuthenticationSession?
    private var codeVerifier: String = ""

    // MARK: - Init

    private override init() {}

    // MARK: - Public Methods

    /// 發起 Spotify 登入，成功後回傳完整 token 資訊
    func loginWithSpotify() async throws -> SpotifyTokenResponse {
        codeVerifier = generateCodeVerifier()
        let codeChallenge = generateCodeChallenge(from: codeVerifier)

        guard let authURL = buildAuthURL(codeChallenge: codeChallenge) else {
            throw OAuthError.invalidURL
        }

        let code = try await openAuthSession(url: authURL)
        return try await exchangeCodeForToken(code)
    }

    /// 用 refresh token 取得新的 access token
    func refreshAccessToken(refreshToken: String) async throws -> SpotifyTokenResponse {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else {
            throw OAuthError.invalidURL
        }

        let body = [
            "grant_type":    "refresh_token",
            "refresh_token": refreshToken,
            "client_id":     clientID
        ]
        .map { "\($0.key)=\($0.value)" }
        .joined(separator: "&")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw OAuthError.tokenExchangeFailed
        }

        return try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
    }

    // MARK: - Private Methods

    private func buildAuthURL(codeChallenge: String) -> URL? {
        var components = URLComponents(string: "https://accounts.spotify.com/authorize")
        components?.queryItems = [
            URLQueryItem(name: "client_id",             value: clientID),
            URLQueryItem(name: "response_type",         value: "code"),
            URLQueryItem(name: "redirect_uri",          value: redirectURI),
            URLQueryItem(name: "scope",                 value: scopes),
            URLQueryItem(name: "code_challenge",        value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256")
        ]
        return components?.url
    }

    private func openAuthSession(url: URL) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: "spotifyclone"
            ) { [weak self] callbackURL, error in
                guard let _ = self else { return }

                if let error = error as? ASWebAuthenticationSessionError,
                   error.code == .canceledLogin {
                    continuation.resume(throwing: OAuthError.cancelled)
                    return
                }

                guard let callbackURL else {
                    continuation.resume(throwing: OAuthError.invalidCallbackURL)
                    return
                }

                guard let code = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?
                    .queryItems?
                    .first(where: { $0.name == "code" })?
                    .value
                else {
                    continuation.resume(throwing: OAuthError.missingCode)
                    return
                }

                continuation.resume(returning: code)
            }

            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = true
            self.authSession = session
            session.start()
        }
    }

    private func exchangeCodeForToken(_ code: String) async throws -> SpotifyTokenResponse {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else {
            throw OAuthError.invalidURL
        }

        let body = [
            "grant_type":    "authorization_code",
            "code":          code,
            "redirect_uri":  redirectURI,
            "client_id":     clientID,
            "code_verifier": codeVerifier
        ]
        .map { "\($0.key)=\($0.value)" }
        .joined(separator: "&")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = body.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw OAuthError.tokenExchangeFailed
        }

        return try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
    }

    // MARK: - PKCE Helpers

    private func generateCodeVerifier() -> String {
        var bytes = [UInt8](repeating: 0, count: 64)
        _ = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)
        return Data(bytes).base64URLEncoded()
    }

    private func generateCodeChallenge(from verifier: String) -> String {
        let data = Data(verifier.utf8)
        let hash = SHA256.hash(data: data)
        return Data(hash).base64URLEncoded()
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding

extension OAuthManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? ASPresentationAnchor()
    }
}

// MARK: - Data+Base64URL

private extension Data {
    /// Base64url encoding（RFC 4648）：將標準 Base64 的 +/= 替換成 URL 安全字元
    func base64URLEncoded() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
