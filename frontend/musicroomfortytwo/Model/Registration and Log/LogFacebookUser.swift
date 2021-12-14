//
//  LogFacebookUser.swift
//  musicroomfortytwo
//
//  Created by ML on 23/02/2021.
//

import Foundation

class LogFacebookUser {
    
    static let shared = LogFacebookUser()
    private init() {}
    private var task: URLSessionTask?
    
    func logFacebookUser(callback: @escaping (Int) -> Void) {
        let route = UserDefaults.standard.string(forKey: "route")!
        let googleUrl = URL(string: route + "/auth/login/facebook")!
        let token: String = UserDefaults.standard.value(forKey: "facebookToken") as! String
        var request = URLRequest(url: googleUrl)
        request.httpMethod = "POST"
        let body = "token=" + token
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
                            self.saveUserInfo(user: responseJSON)
                            callback(1)
                            return
                        } else if response.statusCode == 400 {
                            if responseJSON["code"] == "0" {
                                callback(2)
                            } else if responseJSON["code"] == "4" {
                                callback(4)
                            }
                            callback(0)
                            return
                        } else {
                            callback(0)
                            return
                        }
                    }
                }
            }
        }
        task?.resume()
    }
    func saveUserInfo(user: [String:String]) {
        let userId: String
        let userPseudo: String
        let token: String
        userId = user["userId"] ?? ""
        userPseudo = user["userPseudo"] ?? ""
        token = user["token"] ?? ""
        UserDefaults.standard.setValue(userId, forKey: "userId")
        UserDefaults.standard.setValue(userPseudo, forKey: "userPseudo")
        UserDefaults.standard.setValue(token, forKey: "userToken")
        UserDefaults.standard.setValue(true, forKey: "connected")
        var roomControlDelegation: RoomControlDelegation!
        var friendsListControlDelegation: [FriendsListControlDelegation?] = []
        friendsListControlDelegation.removeAll()
        friendsListControlDelegation.append(FriendsListControlDelegation.init(friendId: UserDefaults.standard.string(forKey: "userId")!, friendPseudo: UserDefaults.standard.string(forKey: "userPseudo")!))
        roomControlDelegation = RoomControlDelegation.init(roomId: "", friendsList: friendsListControlDelegation)
        UserDefaults.standard.set(try? PropertyListEncoder().encode(roomControlDelegation), forKey:"roomControlDelegation")
    }
    
}
