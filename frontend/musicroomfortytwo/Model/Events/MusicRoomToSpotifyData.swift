//
//  MusicRoomToSpotifyData.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 08/03/2021.
//

import Foundation
import UIKit

extension Event {
    func fillTrackListWithSpotifyData(callback: @escaping (Bool) -> Void) {
        let preparedTrackList = prepareTrackListForSpotify()
        if preparedTrackList == nil {
            callback(true)
        }
        let parameters = ["ids":preparedTrackList, "market": "FR"]
        var components = URLComponents(string: "https://api.spotify.com/v1/tracks")!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        var request = URLRequest(url: components.url!)
        let token = UserDefaults.standard.string(forKey: "spotifyToken")!
        let bearer = "Bearer " + token
        request.setValue(bearer, forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode, error == nil else {
                return
            }
            do {
                _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                let decoder = JSONDecoder()
                let getTracksResult = try decoder.decode(GetSeveralTrack.self, from: data)
                for i in 0 ..< getTracksResult.tracks.count {
                    self.tracks[i].name = getTracksResult.tracks[i].name
                    self.tracks[i].artist = getTracksResult.tracks[i].artists![0].name
                    self.tracks[i].uri = getTracksResult.tracks[i].uri
                    self.tracks[i].duration_ms = getTracksResult.tracks[i].duration_ms
                    self.tracks[i].coverUrl = getTracksResult.tracks[i].album.images[1].url
                    self.tracks[i].coverImg = UIImage(url: URL(string: self.tracks[i].coverUrl!))
                } 
                callback(true)
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    } 
    func prepareTrackListForSpotify() -> String? {
        var preparedTrackList: String?
        for track in self.tracks {
            if preparedTrackList != nil {
                    preparedTrackList = preparedTrackList! + "," + track.id!
            } else {
                preparedTrackList = track.id!
            }
        }
        return preparedTrackList
    }
}
