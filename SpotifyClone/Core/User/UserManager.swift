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

    @Published var needLogin: Bool = false
    @Published var defaultUser: SpotifyUser? = nil
    @Published var isLoading: Bool = false

    // MARK: - Private

    private let service: UserServiceProtocol
    private let keychainManager: KeychainManagerProtocol
    private let tokenRefresher: TokenRefreshProtocol
    private let userDefaults: AppUserDefaults
    private var tokenTimer: Timer?
    private var refreshTokenTask: Task<Void, Error>?

    private init(
        service: UserServiceProtocol = UserService(),
        keychainManager: KeychainManagerProtocol = KeychainManager.shared,
        tokenRefresher: TokenRefreshProtocol = OAuthManager.instance,
        userDefaults: AppUserDefaults = .shared
    ) {
        self.service = service
        self.keychainManager = keychainManager
        self.tokenRefresher = tokenRefresher
        self.userDefaults = userDefaults
        
        self.restoreSession()
        self.observeAppLifecycle()
    }

    /// 僅供測試使用，繞過 singleton 限制
    static func makeForTesting(
        service: UserServiceProtocol = UserService(),
        keychainManager: KeychainManagerProtocol,
        tokenRefresher: TokenRefreshProtocol,
        userDefaults: AppUserDefaults
    ) -> UserManager {
        UserManager(
            service: service,
            keychainManager: keychainManager,
            tokenRefresher: tokenRefresher,
            userDefaults: userDefaults
        )
    }

    // MARK: - Public Functions

    /// 首次登入後儲存完整 token 資訊並啟動 expiry timer
    func saveSession(accessToken: String, refreshToken: String?, expiresIn: Int) {
        try? keychainManager.save(accessToken, forKey: .accessToken)
        if let refreshToken {
            try? keychainManager.save(refreshToken, forKey: .refreshToken)
        }
        persistExpiryDate(expiresIn: expiresIn)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.needLogin = false
        }
        
        fetchUserInfo()
    }
    
    func logout() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.clearTokensFromKeychain()
            self.defaultUser = nil
            self.needLogin = true
        }
    }

    func userImageURL() -> URL? {
        URL(string: defaultUser?.images?.first?.url ?? "")
    }
    
    func fetchUserInfo() {
        Task {
            if let user = try? await service.fetchCurrentUser() {
                await MainActor.run {
                    defaultUser = user
                }
            }
        }
    }

    // MARK: - Private: Session Restore

    private func restoreSession() {
        let hasAccessToken = keychainManager.read(forKey: .accessToken) != nil
        let hasRefreshToken = keychainManager.read(forKey: .refreshToken) != nil

        guard hasAccessToken || hasRefreshToken else {
            logout()
            return
        }

        if let expiryTimestamp = userDefaults.tokenExpiryDate {
            let expiryDate = Date(timeIntervalSince1970: expiryTimestamp)
            if expiryDate > Date() {
                scheduleExpiryTimer(at: expiryDate)
                fetchUserInfo()

            } else if hasRefreshToken {
                handleTokenExpired(showLoading: true)

            } else {
                logout()
            }

        } else if hasRefreshToken {
            handleTokenExpired(showLoading: true)
        }
    }

    // MARK: - Private: Token Persistence

    private func persistExpiryDate(expiresIn: Int) {
        let expiryDate = Date().addingTimeInterval(TimeInterval(expiresIn) - 300)
        userDefaults.tokenExpiryDate = expiryDate.timeIntervalSince1970
        userDefaults.tokenDuration = expiresIn
        scheduleExpiryTimer(at: expiryDate)
    }

    private func persistTokens(result: SpotifyTokenResponse) {
        try? keychainManager.save(result.accessToken, forKey: .accessToken)
        if let refreshToken = result.refreshToken {
            try? keychainManager.save(refreshToken, forKey: .refreshToken)
        }
        persistExpiryDate(expiresIn: result.expiresIn)
        
        guard defaultUser == nil else { return }
        fetchUserInfo()
    }

    // MARK: - Private: Expiry Check

    func checkTokenExpiry(showLoading: Bool = false) {
        guard let expiryTimestamp = userDefaults.tokenExpiryDate else { return }
        let expiryDate = Date(timeIntervalSince1970: expiryTimestamp)

        if Date() >= expiryDate {
            handleTokenExpired(showLoading: showLoading)
        } else {
            scheduleExpiryTimer(at: expiryDate)
        }
    }

    private func handleTokenExpired(showLoading: Bool = false) {
       guard let refreshToken = keychainManager.read(forKey: .refreshToken) else {
            logout()
            return
        }

        refreshTokenTask?.cancel()
        refreshTokenTask = Task {
            await MainActor.run {
                if showLoading {
                    isLoading = true
                }
            }
            do {
                let result = try await tokenRefresher.refreshAccessToken(refreshToken: refreshToken)
                try Task.checkCancellation()
                persistTokens(result: result)
                
                await MainActor.run {
                    isLoading = false
                }
                
            } catch is CancellationError {
                // 取消時不做事
            } catch {
                await MainActor.run {
                    logout()
                    isLoading = false
                }
            }
        }
    }

    private func clearTokensFromKeychain() {
        stopTokenTimer()
        try? keychainManager.delete(forKey: .accessToken)
        try? keychainManager.delete(forKey: .refreshToken)
        userDefaults.tokenExpiryDate = nil
        userDefaults.tokenDuration = nil
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
            guard let self = self, !needLogin else { return }
            self.checkTokenExpiry(showLoading: true)
        }
    }
}
