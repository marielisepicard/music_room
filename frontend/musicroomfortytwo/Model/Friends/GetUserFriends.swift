//
//  GetUserFriends.swift
//  musicroomfortytwo
//
//  Created by ML on 04/02/2021.
//

import Foundation

// The 2 structures bellow are necessary to receive the response object
// from our request
struct UserFriends: Decodable {
    let code: String
    let friends: [FriendsList]
}

// This structure is also used to save our result infos
struct FriendsList: Decodable {
    let _id: String
    let pseudo: String
}

class GetUserFriends {
    
    static let shared = GetUserFriends()
    private init() {}
    private var task: URLSessionTask?
    var friendsList: [FriendsList] = []
    
    func getUserFriends(callback: @escaping (Int) -> Void) {
        friendsList.removeAll()
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/users/" + userId + "/friends")!
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
                    return
                }
                do {
                    // vérifier le code erreur !
                    _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    let decoder = JSONDecoder()
                    let userFriends = try decoder.decode(UserFriends.self, from: data)
                    self.recordFriends(friendList: userFriends.friends)
//                    self.printResult(friendlist: userFriends.friends)
                    callback(1)
                    return

                } catch let parsingError {
                    print("Error", parsingError)
                    callback(0)
                    return
                }
             }
         }
         task?.resume()
    }
    
    func printResult(friendlist: [FriendsList]) {
        print("Let's print our user's friends ! :-) ")
        let count = friendlist.count
        if (count > 0) {
            for i in 0...(count - 1){
                print("result : ", friendlist[i].pseudo, " ", friendlist[i]._id)
            }
        }
    }
    
    func recordFriends(friendList: [FriendsList]) {
        let count = friendList.count
        if count > 0 {
            for i in 0...(count - 1){
                let newElem = FriendsList(_id: friendList[i]._id, pseudo: friendList[i].pseudo)
                self.friendsList.append(newElem)
            }
        }
    }
}
