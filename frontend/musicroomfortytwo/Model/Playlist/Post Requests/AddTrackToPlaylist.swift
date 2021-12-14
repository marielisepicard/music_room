//
//  AddTrackToPlaylist.swift
//  musicroomfortytwo
//
//  Created by ML on 03/02/2021.
//

import Foundation

class AddTrackToPlaylist {
    
    static let shared = AddTrackToPlaylist()
    private init() {}
    private var task: URLSessionDataTask?
    
    func addTrackToPlaylist(callback: @escaping (Int) -> Void) {
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let playlistId = UserDefaults.standard.string(forKey: "idOfSelectedPlaylist")!
        let trackId = UserDefaults.standard.string(forKey: "idOfSelectedTrack")!
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/playlists/" + playlistId + "/tracks/" + trackId)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let duration = String(UserDefaults.standard.integer(forKey: "durationOfSelectedTrack"))
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue(UIDevice.modelName, forHTTPHeaderField: "deviceModel")
        request.addValue(UIDevice.current.systemVersion, forHTTPHeaderField: "deviceOSVersion")
        request.addValue(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String, forHTTPHeaderField: "musicRoomVersion")
        let body = "userId=" + userId + "&duration=" + duration//TEST
        request.httpBody = body.data(using: .utf8)
        let session = URLSession(configuration: .default)
        task?.cancel()
        task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    callback(0)
                    return
                }
                if let json = try? JSONDecoder().decode([String: String].self, from: data) {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            callback(1)
                            return
                        } else if response.statusCode == 400 {
                            if json["code"] == "3" {
                                callback(3)
                                return
                            }
                        }
                        callback(0)
                        return
                    }
                 }
                callback(0)
                return
             }
         }
         task?.resume()
    }
}
