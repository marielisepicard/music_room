//
//  InviteAFriend.swift
//  musicroomfortytwo
//
//  Created by ML on 04/02/2021.
//

import Foundation

class InviteAFriend {
    
    static let shared = InviteAFriend()
    private init() {}
    private var task: URLSessionTask?
    
    func inviteAFriend(friendId: String, callback: @escaping (Int) -> Void) {
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/users/" + userId + "/friends/" + friendId + "/invite")!
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
                    return
                }
                if let responseJSON = try? JSONDecoder().decode([String: String].self, from: data) {
                    if let response = response as? HTTPURLResponse {
                        
                        if response.statusCode == 200{
                            callback(1)
                            return
                        } else if response.statusCode == 400 {
                            if responseJSON["code"]! == "0" {
                                callback(2) // Intern Error
                                return
                            } else if responseJSON["code"]! == "1" {
                                callback(3) // The user is trying to be his own friend
                                return
                            } else if responseJSON["code"]! == "2" {
                                callback(4) // The users are already friend
                                return
                            } else if responseJSON["code"]! == "3" {
                                callback(5) // The invitation is already pending
                                return
                            }
                        } else {
                            callback(2) // Intern Error
                            return
                        }
                    }
                 }
             }
         }
         task?.resume()
    }
}
