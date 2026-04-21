//
//  SpotifyUserDefaults.swift
//  WellNewProject
//
//  Created by Yen Lin on 2025/10/31.
//

import Foundation

// MARK: - Custom Suite UserDefaults Manager

final class AppUserDefaults {
    
    // MARK: - Suite Name
        
    static let shared = AppUserDefaults()
    
    private let defaults: UserDefaults
    private let suiteName: String
    
    init(suiteName: String = "com.Spotify.Settings") {
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            fatalError("無法建立 UserDefaults suite: \(suiteName)")
        }
        self.defaults = defaults
        self.suiteName = suiteName
    }
    
    // MARK: - Keys
    
    enum CustomKey: String {
        /// Token 有效期間
        case tokenDuration = "token_duration"
        /// Token 到期時間
        case tokenExpiryDate = "token_expiry_date"
    }
    
    // MARK: - Getter / Setter
    
    private func set<T>(_ value: T, forKey key: CustomKey) {
        defaults.set(value, forKey: key.rawValue)
    }
    
    private func get<T>(forKey key: CustomKey) -> T? {
        defaults.object(forKey: key.rawValue) as? T
    }
    
    private func bool(forKey key: CustomKey) -> Bool {
        defaults.bool(forKey: key.rawValue)
    }
    
    private func string(forKey key: CustomKey) -> String? {
        defaults.string(forKey: key.rawValue)
    }
    
    private func integer(forKey key: CustomKey) -> Int? {
        defaults.object(forKey: key.rawValue) as? Int
    }
    
    private func double(forKey key: CustomKey) -> Double? {
        defaults.object(forKey: key.rawValue) as? Double
    }
    
    private func remove(forKey key: CustomKey) {
        defaults.removeObject(forKey: key.rawValue)
    }
    
    // MARK: - 常用便利屬性
    
    var tokenDuration: Int? {
        get { integer(forKey: .tokenDuration) }
        set {
            if let newValue {
                set(newValue, forKey: .tokenDuration)

            } else {
                remove(forKey: .tokenDuration)
            }
        }
    }
    
    var tokenExpiryDate: Double? {
        get { double(forKey: .tokenExpiryDate) }
        set {
            if let newValue {
                set(newValue, forKey: .tokenExpiryDate)

            } else {
                remove(forKey: .tokenExpiryDate)
            }
        }
    }
    
    // MARK: - 清除所有資料（登出時用）
    
    func clearAll() {
        defaults.removePersistentDomain(forName: suiteName)
    }
}
