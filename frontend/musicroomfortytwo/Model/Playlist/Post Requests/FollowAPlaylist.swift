//
//  FollowAPlaylist.swift
//  musicroomfortytwo
//
//  Created by ML on 04/02/2021.
//

import Foundation

class FollowAPlaylist {
    
    static let shared = FollowAPlaylist()
    private init() {}
    private var task: URLSessionDataTask?
    
    func followAPlaylist(playlistId: String, callback: @escaping (Bool) -> Void) {
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/users/" + userId + "/playlists/" + playlistId + "/follow")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
                    callback(false)
                    return
                }
                if let _ = try? JSONDecoder().decode([String: String].self, from: data) {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            callback(true)
                            return
                        } else if response.statusCode == 400 {
                            callback(false)
                            return
                        }
                        callback(false)
                        return
                    }
                 }
                callback(false)
                return
             }
         }
         task?.resume()
    }
}
