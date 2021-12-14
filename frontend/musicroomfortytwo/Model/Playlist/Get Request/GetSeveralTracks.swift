//
//  GetSeveralTracks.swift
//  musicroomfortytwo
//
//  Created by ML on 02/02/2021.
//

import Foundation
import UIKit

struct DisplayablePlaylist {
    let id: String
    let name: String
    let uri: String
    let duration_ms: Int
    let imageHdUrl: String
    let image: UIImage
    let imageUrl: String
    let artists: String
}

class GetSeveralTracks {
    static let shared = GetSeveralTracks()
    private var task: URLSessionDataTask?
    var displayablePlaylist: [DisplayablePlaylist] = []
    
    func removeTrack(at index: Int) {
        displayablePlaylist.remove(at: index)
    }

    func getSeveralTracks(trackslist: String, callback: @escaping (Bool) -> Void) {
        let parameters = ["ids":trackslist, "market": "FR"]
        var components = URLComponents(string: "https://api.spotify.com/v1/tracks")!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        var request = URLRequest(url: components.url!)
        let token = UserDefaults.standard.string(forKey: "spotifyToken")!
        let bearer = "Bearer " + token
        request.setValue(bearer, forHTTPHeaderField: "Authorization")
        request.addValue(UIDevice.modelName, forHTTPHeaderField: "deviceModel")
        request.addValue(UIDevice.current.systemVersion, forHTTPHeaderField: "deviceOSVersion")
        request.addValue(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String, forHTTPHeaderField: "musicRoomVersion")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode, error == nil else {
                self.displayablePlaylist.removeAll()
                callback(false)
                return
            }
            do {
                _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                let decoder = JSONDecoder()
                let getTracksResult = try decoder.decode(GetSeveralTrack.self, from: data)
                self.recordDisplayablePlaylist(getTracksResult: getTracksResult)
                callback(true)
                return
            } catch let parsingError {
                print("Error", parsingError)
            }
            callback(false)
            return
        }
        task.resume()
    }
    
    func recordDisplayablePlaylist(getTracksResult: GetSeveralTrack) {
        self.displayablePlaylist.removeAll()
        let count = getTracksResult.tracks.count
        if count > 0 {
            for i in 0...(count - 1) {
                let id = getTracksResult.tracks[i].id
                let name = getTracksResult.tracks[i].name
                let uri = getTracksResult.tracks[i].uri
                let duration_ms = getTracksResult.tracks[i].duration_ms
                let imageHdUrl = getTracksResult.tracks[i].album.images[0].url
                let imageUrl = getTracksResult.tracks[i].album.images[2].url
                let image = UIImage(url: URL(string: imageHdUrl))!
                let artists = getTracksResult.tracks[i].artists![0].name ?? ""
                let newTrack = DisplayablePlaylist(id: id, name: name, uri: uri, duration_ms: duration_ms, imageHdUrl: imageHdUrl, image: image, imageUrl: imageUrl, artists: artists)
                displayablePlaylist.append(newTrack)
            }
        }
    }
}
    
