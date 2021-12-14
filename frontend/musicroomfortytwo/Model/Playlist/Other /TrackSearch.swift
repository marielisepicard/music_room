//
//  TrackSearch.swift
//  musicroomfortytwo
//
//  Created by ML on 01/02/2021.
//

import Foundation
import UIKit

/*
        Make a request to the Spotify Catalogue so that the connected user
        can find his favorites tracks !
 
        ViewController: Search
 */

struct FoundedTrack {
    var title: String
    var artist: String
    var duration: Int
    var imageUrl: String
    var image: UIImage
    var id: String
}

class TrackSearch {
    
    static let shared = TrackSearch()
    private init() {}
    var foundedTracks: [FoundedTrack] = []
    private var task: URLSessionDataTask?
    
    func printSearchResult(foundedTracks: [FoundedTrack]) {
        let count = foundedTracks.count
        for i in 0...(count - 1) {
            print("Chanson n°", String(i + 1), " titre : ", foundedTracks[i].title)
        }
    }
    
    func searchTracks(textfield: String, callback: @escaping (Bool) -> Void) {
        let userSearch = textfield
        let parameters = ["q":userSearch, "type":"track", "market": "FR", "limit":"20"]
        var components = URLComponents(string: "https://api.spotify.com/v1/search")!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        var request = URLRequest(url: components.url!)
        let token = UserDefaults.standard.string(forKey: "spotifyToken")!
        let bearer = "Bearer " + token
        request.setValue(bearer, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode, error == nil else {
                callback(false)
                return
            }
            do {
                _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                let decoder = JSONDecoder()
                self.foundedTracks.removeAll()
                let itemSearchResult = try decoder.decode(SpotifyTrackResult.self, from: data)
                let count = itemSearchResult.tracks.items.count
                if count > 0 {
                    self.createSearchResult(itemSearchResult: itemSearchResult)
                }
            } catch let parsingError {
                print("Error", parsingError)
            }
            callback(true)
            return
        }
        task.resume()
    }
    
    func createSearchResult(itemSearchResult: SpotifyTrackResult) {
        let count = itemSearchResult.tracks.items.count
        for i in 0...(count - 1) {
            let title = itemSearchResult.tracks.items[i].name ?? ""
            let artist = itemSearchResult.tracks.items[i].artists![0].name ?? ""
            let duration_ms = itemSearchResult.tracks.items[i].duration_ms ?? 0
            let imageUrl = itemSearchResult.tracks.items[i].album.images[0].url
            let image = UIImage(url: URL(string: imageUrl))!
            let trackId = itemSearchResult.tracks.items[i].id ?? ""
            let newTrack = FoundedTrack(title: title, artist: artist, duration: duration_ms, imageUrl: imageUrl, image: image, id: trackId)
            foundedTracks.append(newTrack)
        }
    }
}
