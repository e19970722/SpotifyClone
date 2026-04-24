//
//  UserManagerTokenTests.swift
//  SpotifyCloneTests
//
//  Created by Yen Lin on 2026/4/16.
//

import Testing
import Foundation
@testable import SpotifyClone
import UIKit

// MARK: - Test Helpers

private func futureTimestamp(secondsFromNow: TimeInterval) -> Double {
    Date().addingTimeInterval(secondsFromNow).timeIntervalSince1970
}

private func pastTimestamp(secondsAgo: TimeInterval) -> Double {
    Date().addingTimeInterval(-secondsAgo).timeIntervalSince1970
}

private func makeSUT(
    keychain: MockKeychainManager,
    refresher: MockTokenRefresher,
    defaults: AppUserDefaults
) -> UserManager {
    UserManager.makeForTesting(
        service: MockUserService(),
        keychainManager: keychain,
        tokenRefresher: refresher,
        userDefaults: defaults
    )
}

private func makeTokenResponse(
    accessToken: String = "new_access",
    refreshToken: String? = "new_refresh",
    expiresIn: Int = 3600
) -> SpotifyTokenResponse {
    SpotifyTokenResponse(
        accessToken:  accessToken,
        tokenType:    "Bearer",
        expiresIn:    expiresIn,
        refreshToken: refreshToken,
        scope:        nil
    )
}

// MARK: - App 啟動 - Token 未到期

@MainActor @Suite("App 啟動 - Token 未到期", .serialized)
struct AppStartTokenValid {

    let keychain = MockKeychainManager()
    let refresher = MockTokenRefresher()
    let defaults: AppUserDefaults

    init() {
        let testSuiteName = "com.Spotify.Settings.Test.AppStartTokenValid"
        defaults = AppUserDefaults(suiteName: testSuiteName)
        defaults.clearAll()
    }

    // #1 - 無任何 token
    @Test func noTokens_needLoginTrue() async throws {
        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(sut.needLogin == true)
    }

    // #2 - 有 accessToken 但無 tokenExpiryDate（舊版資料）→ 直接登入，不設 timer，不 refresh
    @Test func accessTokenWithoutExpiryDate_notNeedLogin_noRefresh() async throws {
        try? keychain.save("old_token", forKey: .accessToken)

        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(sut.needLogin == false)
        #expect(refresher.callCount == 0)
    }

    // #3 - token 未到期 → needLogin = false，不 refresh
    @Test func validToken_notNeedLogin_noRefresh() async throws {
        try? keychain.save("valid_access", forKey: .accessToken)
        try? keychain.save("refresh_token", forKey: .refreshToken)
        defaults.tokenExpiryDate = futureTimestamp(secondsFromNow: 3600)

        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        try await Task.sleep(nanoseconds: 100_000_000)
        #expect(sut.needLogin == false)
        #expect(refresher.callCount == 0)
    }
}

// MARK: - App 啟動 - Token 已到期

@MainActor @Suite("App 啟動 - Token 已到期", .serialized)
struct AppStartTokenExpired {

    let keychain = MockKeychainManager()
    let refresher = MockTokenRefresher()
    let defaults: AppUserDefaults

    init() {
        let testSuiteName = "com.Spotify.Settings.Test.AppStartTokenExpired"
        defaults = AppUserDefaults(suiteName: testSuiteName)
        defaults.clearAll()
    }

    // #4 - 已到期 + refresh 成功 → 維持登入，新 token 寫入
    @Test func expiredToken_refreshSuccess_staysLoggedIn() async throws {
        try? keychain.save("old_access", forKey: .accessToken)
        try? keychain.save("old_refresh", forKey: .refreshToken)
        defaults.tokenExpiryDate = pastTimestamp(secondsAgo: 10)
        refresher.result = .success(makeTokenResponse())

        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        try await Task.sleep(nanoseconds: 500_000_000)
        #expect(sut.needLogin == false)
        #expect(sut.isLoading == false)
        #expect(keychain.read(forKey: .accessToken) == "new_access")
    }

    // #5 - 已到期 + refresh 失敗 → needLogin = true
    @Test func expiredToken_refreshFail_isLoggedOut() async throws {
        try? keychain.save("old_access", forKey: .accessToken)
        try? keychain.save("old_refresh", forKey: .refreshToken)
        defaults.tokenExpiryDate = pastTimestamp(secondsAgo: 10)
        refresher.result = .failure(URLError(.badServerResponse))

        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        try await Task.sleep(nanoseconds: 500_000_000)
        #expect(sut.needLogin == true)
        #expect(sut.isLoading == false)
    }

    // #6 - 已到期 + 無 refreshToken → 直接 forceLogout，不呼叫 refresher
    @Test func expiredToken_noRefreshToken_forceLogout() async throws {
        try? keychain.save("old_access", forKey: .accessToken)
        defaults.tokenExpiryDate = pastTimestamp(secondsAgo: 10)

        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        try await Task.sleep(nanoseconds: 200_000_000)
        #expect(sut.needLogin == true)
        #expect(refresher.callCount == 0)
    }
}

// MARK: - Timer 到期（App 使用中）

@MainActor @Suite("Timer 到期 - App 使用中", .serialized)
struct TimerExpiryWhileActive {

    let keychain = MockKeychainManager()
    let refresher = MockTokenRefresher()
    let defaults: AppUserDefaults

    init() {
        let testSuiteName = "com.Spotify.Settings.Test.TimerExpiryWhileActive"
        defaults = AppUserDefaults(suiteName: testSuiteName)
        defaults.clearAll()
    }

    // #7 - Timer 觸發，refresh 成功 → 新 token 寫入
    @Test func timerFires_refreshSuccess_newTokenSaved() async throws {
        try? keychain.save("old_access", forKey: .accessToken)
        try? keychain.save("old_refresh", forKey: .refreshToken)
        // 設定 tokenExpiryDate 為 2 秒後，讓 Timer 啟動
        defaults.tokenExpiryDate = Date().addingTimeInterval(2).timeIntervalSince1970
        refresher.result = .success(makeTokenResponse(accessToken: "timer_new_access"))

        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        try await Task.sleep(nanoseconds: 3_000_000_000)
        #expect(refresher.callCount == 1)
        #expect(sut.needLogin == false)
        #expect(keychain.read(forKey: .accessToken) == "timer_new_access")
    }

    // #8 - Timer 觸發，refresh 失敗 → needLogin = true
    @Test func timerFires_refreshFail_isLoggedOut() async throws {
        try? keychain.save("old_access", forKey: .accessToken)
        try? keychain.save("old_refresh", forKey: .refreshToken)
        defaults.tokenExpiryDate = Date().addingTimeInterval(2).timeIntervalSince1970
        refresher.result = .failure(URLError(.notConnectedToInternet))

        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        try await Task.sleep(nanoseconds: 3_000_000_000)
        #expect(sut.needLogin == true)
    }

    // #9 - Timer 觸發，無 refreshToken → 直接 forceLogout
    @Test func timerFires_noRefreshToken_forceLogout() async throws {
        try? keychain.save("old_access", forKey: .accessToken)
        defaults.tokenExpiryDate = Date().addingTimeInterval(2).timeIntervalSince1970

        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        try await Task.sleep(nanoseconds: 3_000_000_000)
        #expect(sut.needLogin == true)
        #expect(refresher.callCount == 0)
    }

    // #10 - 進後景時 Timer 停止，timeout 後 refresh 不被呼叫
    @Test func enterBackground_timerStops_noRefresh() async throws {
        try? keychain.save("old_access", forKey: .accessToken)
        try? keychain.save("old_refresh", forKey: .refreshToken)
        defaults.tokenExpiryDate = Date().addingTimeInterval(2).timeIntervalSince1970

        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)

        // 模擬 0.5 秒後進後景，停止 Timer
        // 延遲是為了避免 UserManager 還在 init
        try await Task.sleep(nanoseconds: 0_500_000_000)
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: nil)

        // 等超過原本到期時間
        try await Task.sleep(nanoseconds: 3_000_000_000)
        #expect(refresher.callCount == 0)
        _ = sut
    }
}

// MARK: - 回前景

@MainActor @Suite("App 從背景回前景", .serialized)
struct ForegroundReturn {

    let keychain = MockKeychainManager()
    let refresher = MockTokenRefresher()
    let defaults: AppUserDefaults

    init() {
        let testSuiteName = "com.Spotify.Settings.Test.ForegroundReturn"
        defaults = AppUserDefaults(suiteName: testSuiteName)
        defaults.clearAll()
    }

    // #11 - token 仍有效 → 重算 timer，不 refresh，isRefreshingToken 維持 false
    @Test func foreground_tokenValid_noRefresh() async throws {
        try? keychain.save("valid_access", forKey: .accessToken)
        try? keychain.save("refresh_token", forKey: .refreshToken)
        defaults.tokenExpiryDate = futureTimestamp(secondsFromNow: 3600)

        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        try await Task.sleep(nanoseconds: 200_000_000)

        #expect(sut.isLoading == false)
        #expect(refresher.callCount == 0)
        #expect(sut.needLogin == false)
    }

    // #12 - token 已過期，refresh 成功 → 維持登入
    @Test func foreground_tokenExpired_refreshSuccess() async throws {
        try? keychain.save("old_access", forKey: .accessToken)
        try? keychain.save("old_refresh", forKey: .refreshToken)
        defaults.tokenExpiryDate = pastTimestamp(secondsAgo: 10)
        refresher.result = .success(makeTokenResponse(accessToken: "fg_new_access"))

        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        // init 時已觸發一次 refresh，等完成
        try await Task.sleep(nanoseconds: 500_000_000)
        let countAfterInit = refresher.callCount

        // 模擬回前景再觸發一次
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        try await Task.sleep(nanoseconds: 500_000_000)

        #expect(sut.needLogin == false)
        #expect(sut.isLoading == false)
        #expect(refresher.callCount == 1) // 回前景後多呼叫一次
    }

    // #13 - token 已過期，refresh 失敗 → forceLogout
    @Test func foreground_tokenExpired_refreshFail_logout() async throws {
        try? keychain.save("old_access", forKey: .accessToken)
        try? keychain.save("old_refresh", forKey: .refreshToken)
        defaults.tokenExpiryDate = pastTimestamp(secondsAgo: 10)
        refresher.result = .failure(URLError(.badServerResponse))

        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        try await Task.sleep(nanoseconds: 500_000_000)

        #expect(sut.needLogin == true)
        #expect(sut.isLoading == false)
    }

    // #14 - 未登入狀態回前景 → 不執行任何動作
    @Test func foreground_notLoggedIn_noAction() async throws {
        // 不放任何 token → needLogin = true
        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)
        try await Task.sleep(nanoseconds: 200_000_000)

        #expect(sut.needLogin == true)
        #expect(refresher.callCount == 0)
    }
}

// MARK: - Edge Cases

@MainActor @Suite("Edge Cases", .serialized)
struct EdgeCases {

    let keychain = MockKeychainManager()
    let refresher = MockTokenRefresher()
    let defaults: AppUserDefaults

    init() {
        let testSuiteName = "com.Spotify.Settings.Test.EdgeCases"
        defaults = AppUserDefaults(suiteName: testSuiteName)
        defaults.clearAll()
    }

    // #15 - 接近到期：expiresIn=360 → tokenExpiryDate 約 60 秒後（now + 360 - 300）
    @Test func saveSession_nearExpiry_expiryDateCorrect() {
        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        let before = Date()
        sut.saveSession(accessToken: "token", refreshToken: "refresh", expiresIn: 360)
        let after = Date()

        let saved = defaults.tokenExpiryDate!
        let savedDate = Date(timeIntervalSince1970: saved)
        let expectedMin = before.addingTimeInterval(360 - 300 - 1)
        let expectedMax = after.addingTimeInterval(360 - 300 + 1)
        #expect(savedDate >= expectedMin && savedDate <= expectedMax)
    }

    // #16 - expiresIn = 0 → expiryDate 已在過去，立即 checkTokenExpiry → refresh 被呼叫
    @Test func expiresInZero_immediateCheckAndRefresh() async throws {
        try? keychain.save("access", forKey: .accessToken)
        try? keychain.save("refresh", forKey: .refreshToken)
        refresher.result = .success(makeTokenResponse())

        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        sut.saveSession(accessToken: "access", refreshToken: "refresh", expiresIn: 0)
        try await Task.sleep(nanoseconds: 500_000_000)

        #expect(refresher.callCount >= 1)
        _ = sut
    }

    // #17 - tokenExpiryDate 剛好等於 now → 視為過期，觸發 refresh
    @Test func expiryDateExactlyNow_treatedAsExpired() async throws {
        try? keychain.save("access", forKey: .accessToken)
        try? keychain.save("refresh", forKey: .refreshToken)
        defaults.tokenExpiryDate = Date().timeIntervalSince1970
        refresher.result = .success(makeTokenResponse())

        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        try await Task.sleep(nanoseconds: 500_000_000)

        #expect(refresher.callCount >= 1)
        _ = sut
    }

    // #18 - Race condition：連續呼叫兩次 checkTokenExpiry，needLogin 最終為 false，不誤登出
    @Test func doubleCheckExpiry_noSpuriousLogout() async throws {
        try? keychain.save("old_access", forKey: .accessToken)
        try? keychain.save("old_refresh", forKey: .refreshToken)
        defaults.tokenExpiryDate = pastTimestamp(secondsAgo: 1)
        refresher.delay = 0.2
        refresher.result = .success(makeTokenResponse())

        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)

        // 同時觸發兩次（模擬 Timer + foreground 雙觸發）
        sut.checkTokenExpiry(showLoading: true)
        sut.checkTokenExpiry(showLoading: true)

        try await Task.sleep(nanoseconds: 500_000_000)
        #expect(sut.needLogin == false)
        #expect(sut.isLoading == false)
    }
}

// MARK: - saveSession

@MainActor @Suite("saveSession", .serialized)
struct SaveSessionTests {

    let keychain = MockKeychainManager()
    let refresher = MockTokenRefresher()
    let defaults: AppUserDefaults

    init() {
        let testSuiteName = "com.Spotify.Settings.Test.SaveSessionTests"
        defaults = AppUserDefaults(suiteName: testSuiteName)
        defaults.clearAll()
    }

    // #19 - tokenExpiryDate 計算正確（now + expiresIn - 300）
    @Test func saveSession_expiryDateCalculation() {
        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        let before = Date()
        sut.saveSession(accessToken: "a", refreshToken: "r", expiresIn: 3600)
        let after = Date()

        let savedDate = Date(timeIntervalSince1970: defaults.tokenExpiryDate!)
        let expectedMin = before.addingTimeInterval(3600 - 300 - 1)
        let expectedMax = after.addingTimeInterval(3600 - 300 + 1)
        #expect(savedDate >= expectedMin && savedDate <= expectedMax)
    }

    // #20 - saveSession 傳 nil refreshToken → refreshToken 不寫入 Keychain
    @Test func saveSession_nilRefreshToken_notSavedToKeychain() {
        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        sut.saveSession(accessToken: "access_only", refreshToken: nil, expiresIn: 3600)

        #expect(keychain.read(forKey: .accessToken) == "access_only")
        #expect(keychain.read(forKey: .refreshToken) == nil)
    }
}

// MARK: - logout

@MainActor @Suite("logout", .serialized)
struct LogoutTests {

    let keychain = MockKeychainManager()
    let refresher = MockTokenRefresher()
    let defaults: AppUserDefaults

    init() {
        let testSuiteName = "com.Spotify.Settings.Test.LogoutTests"
        defaults = AppUserDefaults(suiteName: testSuiteName)
        defaults.clearAll()
    }

    // #21 - logout 清除 Keychain + UserDefaults + needLogin = true
    @Test func logout_clearsAllAndSetsLoggedOut() async throws {
        try? keychain.save("access", forKey: .accessToken)
        try? keychain.save("refresh", forKey: .refreshToken)
        defaults.tokenExpiryDate = futureTimestamp(secondsFromNow: 3600)

        let sut = makeSUT(keychain: keychain, refresher: refresher, defaults: defaults)
        try await Task.sleep(nanoseconds: 100_000_000)

        sut.logout()

        try await Task.sleep(nanoseconds: 100_000_000)
        
        #expect(sut.needLogin == true)
        #expect(keychain.read(forKey: .accessToken) == nil)
        #expect(keychain.read(forKey: .refreshToken) == nil)
        #expect(defaults.tokenExpiryDate == nil)
        #expect(defaults.tokenDuration == nil)
    }
}
