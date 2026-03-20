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
