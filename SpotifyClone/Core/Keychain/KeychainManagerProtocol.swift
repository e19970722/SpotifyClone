//
//  KeychainManagerProtocol.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/4/16.
//

protocol KeychainManagerProtocol {
    func save(_ value: String, forKey key: KeychainManager.KeychainKey) throws
    func read(forKey key: KeychainManager.KeychainKey) -> String?
    func delete(forKey key: KeychainManager.KeychainKey) throws
}
