//
//  MakeAPlaylistPublic.swift
//  musicroomfortytwo
//
//  Created by ML on 14/02/2021.
//

import Foundation

class MakeAPlaylistPublic {
    
    static let shared = MakeAPlaylistPublic()
    private init() {}
   
    private var task: URLSessionDataTask?
    
    func makeAPlaylistPublic(playlistId: String, callback: @escaping (Int) -> Void) {
        
        let userId = UserDefaults.standard.string(forKey: "userId")!
        
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/users/" + userId + "/playlists/" + playlistId + "/public")!

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
                    callback(0)
                    return
                }
                if let _ = try? JSONDecoder().decode([String: String].self, from: data) {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 { // Success
                            callback(200)
                            return
                        }
                    }
                }
                callback(0)
                return
            }
         }
         task?.resume()
     }
    
    
}

