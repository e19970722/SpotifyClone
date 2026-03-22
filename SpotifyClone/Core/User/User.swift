//
//  User.swift
//  SpotifyClone
//
//  Created by Yen Lin on 2026/3/19.
//

import Foundation

struct SpotifyUser: Decodable, Identifiable {
    let id: String
    let displayName: String?
    let email: String?
    let country: String?
    let product: String?
    let href: String?
    let uri: String?
    let images: [SpotifyImage]?
    let followers: SpotifyFollowers?
    let externalUrls: SpotifyExternalUrls?

    enum CodingKeys: String, CodingKey {
        case id
        case displayName  = "display_name"
        case email
        case country
        case product
        case href
        case uri
        case images
        case followers
        case externalUrls = "external_urls"
    }
}

struct SpotifyImage: Decodable {
    let url: String
    let height: Int?
    let width: Int?
}

struct SpotifyFollowers: Decodable {
    let total: Int
}

struct SpotifyExternalUrls: Decodable {
    let spotify: String?
}

struct SpotifyUserPlaylistResponse: Decodable {
    let href: String?
    let limit: Int?
    let offset: Int?
    let total: Int?
    let items: [SpotifyUserPlaylist]?
    /// (自定義) 播放清單
    let playlists: [PlaylistItem]?
    
    enum CodingKeys: CodingKey {
        case href
        case limit
        case offset
        case total
        case items
        case playlists
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.href = try container.decodeIfPresent(String.self, forKey: .href)
        self.limit = try container.decodeIfPresent(Int.self, forKey: .limit)
        self.offset = try container.decodeIfPresent(Int.self, forKey: .offset)
        self.total = try container.decodeIfPresent(Int.self, forKey: .total)
        self.items = try container.decodeIfPresent([SpotifyUserPlaylist].self, forKey: .items)
        if let items = items {
            self.playlists = items.compactMap { returnedPlaylist in
                return PlaylistItem(id: returnedPlaylist.id ?? UUID().uuidString,
                                    title: returnedPlaylist.name,
                                    imageURL: URL(string: returnedPlaylist.images?.first?.url ?? ""))
            }
            
        } else {
            self.playlists = nil
        }
    }
}

struct SpotifyUserPlaylist: Decodable, Identifiable {
    let collaborative: Bool?
    let description: String?
    let href: String?
    let id: String?
    let images: [SpotifyImage]?
    let name: String?
    let itemPublic: Bool?
    let snapshotID: String?
    
    enum CodingKeys: String, CodingKey {
        case collaborative, description
        case href, id, images, name
        case itemPublic = "public"
        case snapshotID = "snapshot_id"
    }
}
