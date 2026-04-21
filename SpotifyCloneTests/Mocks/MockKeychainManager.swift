//
//  MockKeychainManager.swift
//  SpotifyCloneTests
//
//  Created by Yen Lin on 2026/4/16.
//

@testable import SpotifyClone

final class MockKeychainManager: KeychainManagerProtocol {

    var storage: [String: String] = [:]
    var shouldThrowOnSave: Bool = false

    func save(_ value: String, forKey key: KeychainManager.KeychainKey) throws {
        if shouldThrowOnSave {
            throw KeychainManager.KeychainError.saveFailed(-1)
        }
        storage[key.rawValue] = value
    }

    func read(forKey key: KeychainManager.KeychainKey) -> String? {
        storage[key.rawValue]
    }

    func delete(forKey key: KeychainManager.KeychainKey) throws {
        storage.removeValue(forKey: key.rawValue)
    }
}
