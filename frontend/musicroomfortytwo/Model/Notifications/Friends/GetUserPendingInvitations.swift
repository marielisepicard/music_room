//
//  GetUserPendingInvitations.swift
//  musicroomfortytwo
//
//  Created by ML on 04/02/2021.
//

import Foundation

struct FriendsInvitationsArray: Decodable {
    let friendsInvitations: [FriendsInvitations]
}

struct FriendsInvitations: Decodable {
    let userId: String
    let pseudo: String
}

// This structure allows to save our request results
struct PendingInvitationsResult {
    let userId: String
    let pseudo: String
}

class GetUserPendingInvitations {
    
    static let shared = GetUserPendingInvitations()
    private init() {}
    private var task: URLSessionTask?
    
    var pendingInvitationsResult: [PendingInvitationsResult] = []
    
    func getUserPendingInvitations(callback: @escaping (Int) -> Void) {
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/users/" + userId + "/friendsInvitations")!
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
                    _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    let decoder = JSONDecoder()
                    let friendsInvitationsArray = try decoder.decode(FriendsInvitationsArray.self, from: data)
                    self.recordInfo(invits: friendsInvitationsArray.friendsInvitations)
                    callback(1)
                    return
                } catch let parsingError {
                    print("Error", parsingError)
                }
                callback(0)
                return
             }
         }
         task?.resume()
    }
    
    func recordInfo(invits: [FriendsInvitations]) {
        pendingInvitationsResult.removeAll()
        let count = invits.count
        if count > 0 {
            for i in 0...(count - 1) {
                let newElem = PendingInvitationsResult(userId: invits[i].userId, pseudo: invits[i].pseudo)
                self.pendingInvitationsResult.append(newElem)
            }
        }
    }
    
    func printResult() {
        let count = self.pendingInvitationsResult.count
        if count > 0 {
            for i in 0...(count - 1) {
                print("invit : ", self.pendingInvitationsResult[i].pseudo)
            }
        }
    }
}
