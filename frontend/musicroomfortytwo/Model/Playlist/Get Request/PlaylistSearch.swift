//
//  PlaylistSearch.swift
//  musicroomfortytwo
//
//  Created by ML on 03/02/2021.
//

import Foundation

/*
        This Modele makes the API Request so that the user can find public playlists
 */

struct FoundPlaylists: Decodable {
    let _id: String
    let name: String
    let creator: String
}

class PlaylistSearch {
    
    static let shared = PlaylistSearch()
    private init() {}
    
    private var task: URLSessionDataTask?
    
    func playlistSearch(keyWord: String, filtre: String, callback: @escaping (Bool, [FoundPlaylists]?) -> Void) {
        let parameters = ["value": keyWord, "type": "playlists", "musicalStyle": filtre]
        let route = UserDefaults.standard.string(forKey: "route")!
        var components = URLComponents(string: route + "/search")!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        let token = UserDefaults.standard.string(forKey: "userToken")!
        let bearer = "Bearer " + token
        request.setValue(bearer, forHTTPHeaderField: "Authorization")
        request.addValue(UIDevice.modelName, forHTTPHeaderField: "deviceModel")
        request.addValue(UIDevice.current.systemVersion, forHTTPHeaderField: "deviceOSVersion")
        request.addValue(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String, forHTTPHeaderField: "musicRoomVersion")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode, error == nil else {
                callback(false, nil)
                return
            }
            do {
                _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                let decoder = JSONDecoder()
                let getPlaylistsResult = try decoder.decode([FoundPlaylists].self, from: data)
                print(getPlaylistsResult)
                callback(true, getPlaylistsResult)
                return
            } catch let parsingError {
                print("Error", parsingError)
            }
            callback(false, nil)
            return
        }
        task.resume()
    }
}
