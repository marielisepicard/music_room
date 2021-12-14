//
//  GetPlaylistTracks.swift
//  musicroomfortytwo
//
//  Created by ML on 02/02/2021.
//

import Foundation

struct Tracks: Decodable
{
    let tracks: [String]
}

class GetPlaylistTracks {
    
    static let shared = GetPlaylistTracks()
    private init() {}
    
    var allTracks: [String] = [] /* All tracks Spotify Ids inside a given playlist */
    
    private var task: URLSessionDataTask?
    
    func getTheTracksOfAPlaylist(playlistId: String, callback: @escaping (Int) -> Void) {
        allTracks.removeAll()
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/playlists/" + playlistId + "/tracks")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue(UIDevice.modelName, forHTTPHeaderField: "deviceModel")
        request.addValue(UIDevice.current.systemVersion, forHTTPHeaderField: "deviceOSVersion")
        request.addValue(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String, forHTTPHeaderField: "musicRoomVersion")
        let session = URLSession(configuration: .default)
        task?.cancel()
        task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    callback(0)
                    return
                }
                do {
                    _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    let decoder = JSONDecoder()
                    let testTracks = try decoder.decode(Tracks.self, from: data)
                    self.allTracks = testTracks.tracks
                    callback(1)
                    return
                    
                } catch let parsingError {
                    print("Error", parsingError)
                }
                callback(0)
                return
            }
         }
         task?.resume()
     }
}
