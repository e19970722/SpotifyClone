//
//  UserManager.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/18.
//

import Combine
import SwiftUI

final class UserManager: ObservableObject {
    // MARK: - Public

    static let instance = UserManager()

    @Published var isLoggedIn: Bool = false
    @Published var defaultUser: SpotifyUser? = nil
    @Published var playlists: [PlaylistItem]? = nil
    @Published var isRefreshingToken: Bool = false

    // MARK: - Private

    private let service: UserServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var tokenTimer: Timer?
    private var refreshTokenTask: Task<Void, Error>?

    private init(service: UserServiceProtocol = UserService()) {
        self.service = service
        restoreSession()
        observeAppLifecycle()
    }

    // MARK: - Public Functions

    /// 首次登入後儲存完整 token 資訊並啟動 expiry timer
    func saveSession(accessToken: String, refreshToken: String?, expiresIn: Int) {
        try? KeychainManager.shared.save(accessToken, forKey: .accessToken)
        if let refreshToken {
            try? KeychainManager.shared.save(refreshToken, forKey: .refreshToken)
        }
        persistExpiryDate(expiresIn: expiresIn)
        fetchHomeInfo()
    }

    func logout() {
        clearTokensFromKeychain()
        defaultUser = nil
        isLoggedIn = false
    }

    func userImageURL() -> URL? {
        return URL(string: defaultUser?.images?.first?.url ?? "")
    }

    // MARK: - Private: Session Restore

    private func restoreSession() {
        let hasAccessToken = KeychainManager.shared.read(forKey: .accessToken) != nil
        let hasRefreshToken = KeychainManager.shared.read(forKey: .refreshToken) != nil

        guard hasAccessToken || hasRefreshToken else {
            // 無任何憑證 → 未登入
            clearTokensFromKeychain()
            isLoggedIn = false
            return
        }

        if let expiryTimestamp = SpotifyUserDefaults.shared.tokenExpiryDate {
            let expiryDate = Date(timeIntervalSince1970: expiryTimestamp)
            if expiryDate > Date() {
                // Token 仍有效 → 直接恢復登入狀態並重新啟動 timer
                isLoggedIn = true
                scheduleExpiryTimer(at: expiryDate)
                fetchHomeInfo()
            } else if hasRefreshToken {
                // Token 已過期但有 refresh token → 顯示 loading 並靜默更新
                isLoggedIn = true
                handleTokenExpired(showLaunchScreen: true)
            } else {
                clearTokensFromKeychain()
                isLoggedIn = false
            }
        } else if hasRefreshToken {
            // 無 expiryDate 記錄但有 refresh token → 嘗試更新
            isLoggedIn = true
            handleTokenExpired(showLaunchScreen: true)
        } else {
            // 有 accessToken 但無 expiryDate 也無 refreshToken（舊資料）→ 直接使用，不設 timer
            isLoggedIn = true
            fetchHomeInfo()
        }
    }

    // MARK: - Private: Token Persistence

    private func persistExpiryDate(expiresIn: Int) {
        let expiryDate = Date().addingTimeInterval(TimeInterval(expiresIn) - 300)
        SpotifyUserDefaults.shared.tokenExpiryDate = expiryDate.timeIntervalSince1970
        SpotifyUserDefaults.shared.expiryToken = expiresIn
        scheduleExpiryTimer(at: expiryDate)
    }

    private func persistTokens(result: SpotifyTokenResponse) {
        try? KeychainManager.shared.save(result.accessToken, forKey: .accessToken)
        if let refreshToken = result.refreshToken {
            try? KeychainManager.shared.save(refreshToken, forKey: .refreshToken)
        }
        persistExpiryDate(expiresIn: result.expiresIn)
    }

    // MARK: - Private: Expiry Check

    func checkTokenExpiry(showLaunchScreen: Bool = false) {
        guard let expiryTimestamp = SpotifyUserDefaults.shared.tokenExpiryDate else { return }
        let expiryDate = Date(timeIntervalSince1970: expiryTimestamp)

        if Date() >= expiryDate {
            handleTokenExpired(showLaunchScreen: showLaunchScreen)
        } else {
            // Token 仍有效，重新計算剩餘時間並重新啟動 timer
            scheduleExpiryTimer(at: expiryDate)
        }
    }

    private func handleTokenExpired(showLaunchScreen: Bool = false) {
        if showLaunchScreen {
            DispatchQueue.main.async { self.isRefreshingToken = true }
        }

        guard let refreshToken = KeychainManager.shared.read(forKey: .refreshToken) else {
            forceLogout()
            return
        }

        refreshTokenTask?.cancel()
        refreshTokenTask = Task {
            do {
                let result = try await OAuthManager.instance.refreshAccessToken(refreshToken: refreshToken)
                try Task.checkCancellation()
                await MainActor.run {
                    self.persistTokens(result: result)
                    self.isRefreshingToken = false
                }
            } catch {
                await MainActor.run {
                    self.forceLogout()
                    self.isRefreshingToken = false
                }
            }
        }
    }

    private func forceLogout() {
        clearTokensFromKeychain()
        defaultUser = nil
        isLoggedIn = false
    }

    private func clearTokensFromKeychain() {
        stopTokenTimer()
        try? KeychainManager.shared.delete(forKey: .accessToken)
        try? KeychainManager.shared.delete(forKey: .refreshToken)
        SpotifyUserDefaults.shared.tokenExpiryDate = nil
        SpotifyUserDefaults.shared.expiryToken = nil
    }

    // MARK: - Private: Timer

    private func scheduleExpiryTimer(at date: Date) {
        stopTokenTimer()
        let interval = date.timeIntervalSinceNow
        guard interval > 0 else {
            checkTokenExpiry()
            return
        }
        tokenTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: false) { [weak self] _ in
            self?.checkTokenExpiry()
        }
    }

    private func stopTokenTimer() {
        tokenTimer?.invalidate()
        tokenTimer = nil
    }

    // MARK: - Private: App Lifecycle

    private func observeAppLifecycle() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.stopTokenTimer()
        }

        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self, self.isLoggedIn else { return }
            self.checkTokenExpiry(showLaunchScreen: true)
        }
    }

    // MARK: - Private: Data Fetch

    private func fetchHomeInfo() {
        Task {
            if let user = try? await service.fetchCurrentUser() {
                await MainActor.run {
                    self.defaultUser = user
                }
            }

            if let returnedValue = try? await service.fetchUserPlaylists(limit: 8, offset: 0),
               let playlists = returnedValue.playlists {
                await MainActor.run {
                    self.playlists = playlists
                }
            }
        }
    }
}
