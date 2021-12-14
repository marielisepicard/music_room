//
//  LogUser.swift
//  musicroomfortytwo
//
//  Created by ML on 31/01/2021.
//

import Foundation

class LogUser {
    
    static let shared = LogUser()
    private init() {}
    private var task: URLSessionTask?
    
    func logUser(mail: String, password: String, callback: @escaping (Int) -> Void) {
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "email=" + mail + "&password=" + password
        request.httpBody = body.data(using: .utf8)
        let session = URLSession(configuration: .default)
        print(request)
        task?.cancel()
        task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    callback(0)
                    return
                }
                if let responseJSON = try? JSONDecoder().decode([String: String].self, from: data) {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 { // Success
                            self.saveUserInfo(user: responseJSON)
                            callback(200)
                            return
                        }
                        else if response.statusCode == 400 {
                            if responseJSON["code"] == "1" {
                                callback(401) /* invalid user email */
                                return
                            } else if responseJSON["code"] == "2" {
                                callback(402) /* unactivated account */
                                return
                            } else if responseJSON["code"] == "3" {
                                callback(403) /* invalid password */
                                return
                            } else if responseJSON["code"] == "4" {
                                callback(404) /* Compte bloqué */
                                return
                            }
                        }
                        else {
                            callback(500) /* Servor or internal Error */
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
