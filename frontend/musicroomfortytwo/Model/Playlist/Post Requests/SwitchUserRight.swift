//
//  SwitchUserRight.swift
//  musicroomfortytwo
//
//  Created by ML on 17/02/2021.
//

import Foundation

struct SwitchResponse: Decodable {
    let code: String
    let message: String
    let editionRight: String
}

/*
    The goal of this class is to make a request to switch the
    Edition Right of a user that is associated in a playlist
 */

class SwitchUserRight {
    
    static let shared = SwitchUserRight()
    private init() {}
   
    private var task: URLSessionDataTask?

    func switchUserRight(playlistId: String, friendId: String, callback: @escaping (Bool, Bool?) -> Void) {
        
        let userId = UserDefaults.standard.string(forKey: "userId")!
        
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/users/" + userId + "/playlists/" + playlistId + "/associatedUser/" + friendId + "/switchEditionRight")!

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
                    callback(false, nil)
                    return
                }
                if let jsonResponse = try? JSONDecoder().decode([String: String].self, from: data) {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 { // Success
                            if (jsonResponse["editionRight"] == "1") {
                                callback(true, true)
                            } else {
                                callback(true, false)
                            }
                            return
                        }
                    }
                }
                callback(false, nil)
                return
            }
         }
         task?.resume()
     }
}
