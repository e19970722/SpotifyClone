//
//  SpotifyUserDefaults.swift
//  WellNewProject
//
//  Created by Yen Lin on 2025/10/31.
//

import Combine
import Foundation
import Moya

/// Spotify 專屬 UserDefaults
/// ```
/// 設定範例：SpotifyUserDefaults.shared.hasExample = true
/// 存取範例：if SpotifyUserDefaults.shared.hasExample { }
/// ```
class SpotifyUserDefaults: UserDefaults {

    static let shared = SpotifyUserDefaults()
    static let suitName = "com.Spotify.Settings"
    lazy var Spotify: SpotifyUserDefaults? = .init(suiteName: SpotifyUserDefaults.suitName)
    
    // MARK: - Initializer
    
    override private init?(suiteName name: String?) {
        super.init(suiteName: name)
    }

    // MARK: - Functions
    
    /// The integer value associated with the specified key.
    /// If the specified key doesn‘t exist, this method returns 0.
    func integer(forSpotify key: SpotifyKey) -> Int {
        return SpotifyUserDefaults.shared.Spotify?.integer(forKey: key.rawValue) ?? 0
    }
    
    /// The bool value associated with the specified key.
    /// If the specified key doesn‘t exist, this method returns false.
    func bool(forSpotify key: SpotifyKey) -> Bool {
        return SpotifyUserDefaults.shared.Spotify?.bool(forKey: key.rawValue) ?? false
    }
    
    /// The string value associated with the specified key.
    /// If the specified key doesn‘t exist, this method returns nil.
    func string(forSpotify key: SpotifyKey) -> String? {
        return SpotifyUserDefaults.shared.Spotify?.string(forKey: key.rawValue)
    }
    
    /// The array value associated with the specified key.
    /// If the specified key doesn‘t exist, this method returns nil.
    func array(forSpotify key: SpotifyKey) -> [Any]? {
        return SpotifyUserDefaults.shared.Spotify?.array(forKey: key.rawValue) ?? nil
    }

    func setValue(_ value: Any?, forSpotify key: SpotifyKey) {
        SpotifyUserDefaults.shared.Spotify?.setValue(value, forKey: key.rawValue)
        SpotifyUserDefaults.shared.Spotify?.synchronize()
    }
    
    func removeValue(forSpotify key: SpotifyKey) {
        if SpotifyUserDefaults.shared.Spotify?.object(forKey: key.rawValue) != nil {
            SpotifyUserDefaults.shared.Spotify?.removeObject(forKey: key.rawValue)
            SpotifyUserDefaults.shared.Spotify?.synchronize()
        }
    }
}

// MARK: - forSpotify UserDefault keys

extension SpotifyUserDefaults {
    enum SpotifyKey: String {
        /// Key值範例
        case example = "Example"
        /// 第三方登入取得的 Token
        case accessToken = "access_token"
        /// 更新Token
        case refreshToken = "refresh_token"
        /// Token 到期時間
        case expiryToken = "expiry_token"
        /// 上一次為登入或註冊，true為登入，false為註冊
        case loginMode = "loginMode"
        /// 當前貼文內容 HTML
        case currentPostHTML = "currentPostHTML"
        /// Token 到期的絕對時間（Unix timestamp，Double）
        case tokenExpiryDate = "token_expiry_date"
    }
    
    /// 是否存在範例？
    var hasExample: Bool {
        get { SpotifyUserDefaults.shared.bool(forSpotify: .example) }
        set { SpotifyUserDefaults.shared.setValue(newValue, forSpotify: .example) }
    }
    
    /// Token期限
    var expiryToken: Int? {
        get { SpotifyUserDefaults.shared.integer(forSpotify: .expiryToken) }
        set { SpotifyUserDefaults.shared.setValue(newValue, forSpotify: .expiryToken) }
    }
    
    /// 第三方登入取得的 Token
    var accessToken: String? {
        get { SpotifyUserDefaults.shared.string(forSpotify: .accessToken) }
        set { SpotifyUserDefaults.shared.setValue(newValue, forSpotify: .accessToken) }
    }
    
    /// 登入取得的 RefreshToken
    var refreshToken: String? {
        get { SpotifyUserDefaults.shared.string(forSpotify: .refreshToken) }
        set { SpotifyUserDefaults.shared.setValue(newValue, forSpotify: .refreshToken) }
    }
    
    /// 上一次為登入或註冊，true為登入，false為註冊
    var loginMode: Bool {
        get { SpotifyUserDefaults.shared.bool(forSpotify: .loginMode) }
        set { SpotifyUserDefaults.shared.setValue(newValue, forSpotify: .loginMode) }
    }
    
    /// 當前貼文內容 HTML
    var currentPostHTML: String? {
        get { SpotifyUserDefaults.shared.string(forSpotify: .currentPostHTML) }
        set { SpotifyUserDefaults.shared.setValue(newValue, forSpotify: .currentPostHTML) }
    }

    /// Token 到期的絕對時間（Unix timestamp，nil 代表未設定）
    var tokenExpiryDate: Double? {
        get {
            let val = SpotifyUserDefaults.shared.Spotify?.double(forKey: SpotifyKey.tokenExpiryDate.rawValue) ?? 0
            return val == 0 ? nil : val
        }
        set { SpotifyUserDefaults.shared.setValue(newValue, forSpotify: .tokenExpiryDate) }
    }
    
    /// 清除所有UserDefaults內容
    func resetAllWellWUserDefaults() {
        SpotifyUserDefaults.shared.removeValue(forSpotify: .example)
    }
    
    /// 刪除 accessToken - 登出
    func clearAccessToken() {
        SpotifyUserDefaults.shared.removeValue(forSpotify: .accessToken)
        SpotifyUserDefaults.shared.removeValue(forSpotify: .refreshToken)
    }
}
