//
//  InviteFriendToPlaylist.swift
//  musicroomfortytwo
//
//  Created by ML on 14/02/2021.
//

import Foundation

class InviteFriendToPlaylist {
    
    static let shared = InviteFriendToPlaylist()
    private init() {}
    private var task: URLSessionDataTask?
    
    func inviteFriendToPlaylist(userId: String, playlistId: String, friendId: String, editionRight: Int, callback: @escaping (Int) -> Void) {

        var editionR = "false"
        if editionRight == 1 {
            editionR = "true"
        }
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/users/" + userId + "/playlists/" + playlistId + "/invite/friend/" + friendId)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue(UIDevice.modelName, forHTTPHeaderField: "deviceModel")
        request.addValue(UIDevice.current.systemVersion, forHTTPHeaderField: "deviceOSVersion")
        request.addValue(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String, forHTTPHeaderField: "musicRoomVersion")
        let body = "editionRight=" + editionR
        request.httpBody = body.data(using: .utf8)
        let session = URLSession(configuration: .default)
        task?.cancel()
        task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    callback(0)
                    return
                }
                if let responseJSON = try? JSONDecoder().decode([String: String].self, from: data) {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            callback(1)
                            return
                        } else if response.statusCode == 400 {
                            if responseJSON["code"] == "0" {
                                callback(0)
                                return
                                // playlist doesn't exist
                            } else if responseJSON["code"] == "1" {
                                callback(0)
                                return
                            } else if responseJSON["code"] == "2" {
                                callback(0)
                                return
                            } else if responseJSON["code"] == "3" {
                                callback(2)
                                return // not the right to invite
                            } else if responseJSON["code"] == "4" {
                                callback(3)
                                return // already associated
                            } else if responseJSON["code"] == "5" {
                                callback(4)
                                return // already pending invitation
                            } else if responseJSON["code"] == "6" {
                                callback(0)
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
