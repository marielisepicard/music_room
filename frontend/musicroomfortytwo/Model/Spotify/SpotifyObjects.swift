//
//  SpotifyObjects.swift
//  musicroomfortytwo
//
//  Created by ML on 01/02/2021.
//

import Foundation

// The Object we receive when a request "Search for an item" is done
struct SpotifyTrackResult: Decodable {
    let tracks: SpotifyTrack
}

struct SpotifyTrack: Decodable {
    let href: String
    let items: [SpotifyItem]
    let limit: Int
    let total: Int
}

struct SpotifyItem: Decodable {
    let artists: [SpotifyArtist]?
    let duration_ms: Int?
    let name: String?
    let album: SpotifyAlbum
    let id: String?
}

struct SpotifyArtist: Decodable {
    let name: String?
}

struct SpotifyAlbum: Decodable {
    let images: [SpotifyImage]
}

struct SpotifyImage: Decodable {
    let url: String
}

// The Object we receive when a request "Get Several Tracks " is done
struct GetSeveralTrack: Decodable {
    let tracks: [SpotifySeveralTrackObject]
}

struct SpotifySeveralTrackObject: Decodable {
    let id: String
    let name: String
    let uri: String
    let duration_ms: Int
    let album: SpotifyAlbum
    let artists: [SpotifyArtist]?
}
