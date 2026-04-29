//
//  KeychainManager.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/18.
//

import Foundation
import Security

final class KeychainManager: KeychainManagerProtocol {

    static let shared = KeychainManager()

    // MARK: - Keys

    enum KeychainKey: String {
        case accessToken  = "access_token"
        case refreshToken = "refresh_token"
    }

    // MARK: - Errors

    enum KeychainError: Error {
        case saveFailed(OSStatus)
        case deleteFailed(OSStatus)
    }

    // MARK: - Private

    /// 用 Bundle ID 命名，隔離其他 app 的 Keychain items
    private let service = Bundle.main.bundleIdentifier ?? "com.spotifyclone"

    private init() {}

    // MARK: - Public Methods

    /// 儲存字串到 Keychain
    func save(_ value: String, forKey key: KeychainKey) throws {
        // 先刪除舊值，避免 errSecDuplicateItem
        try? delete(forKey: key)

        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue,
            kSecValueData:   Data(value.utf8)
        ]
        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else { throw KeychainError.saveFailed(status) }
    }

    /// 讀取 Keychain 字串，不存在時回傳 nil
    func read(forKey key: KeychainKey) -> String? {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue,
            kSecReturnData:  true,
            kSecMatchLimit:  kSecMatchLimitOne
        ]
        var result: AnyObject?
        SecItemCopyMatching(query as CFDictionary, &result)
        guard let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    /// 刪除 Keychain item，不存在視為成功
    func delete(forKey key: KeychainKey) throws {
        let query: [CFString: Any] = [
            kSecClass:       kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: key.rawValue
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }
}
