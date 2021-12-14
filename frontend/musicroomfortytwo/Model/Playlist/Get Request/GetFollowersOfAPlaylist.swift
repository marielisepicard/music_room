//
//  GetFollowersOfAPlaylist.swift
//  musicroomfortytwo
//
//  Created by ML on 17/02/2021.
//

import Foundation

struct FollowersOfAPlaylistResult: Decodable {
    let playlist: PlaylistObjectToGetFollowers
}

struct PlaylistObjectToGetFollowers: Decodable {
    let followers: [Followers]
    let associatedUsers: [AssociatedUsers]
}

struct Followers: Decodable {
    let userId: String
    let userPseudo: String
}

struct AssociatedUsers: Decodable {
    let userId: String
    let userPseudo: String
    let editionRight: Bool
}

class GetFollowersOfAPlaylist {
    
    static let shared = GetFollowersOfAPlaylist()
    private init() {}
    private var task: URLSessionDataTask?
    
    var followers: [Followers] = []
    var associatedUser: [AssociatedUsers] = []
    
    func getFollowersOfAPlaylist(playlistId: String, callback: @escaping (Int) -> Void) {
        self.followers.removeAll()
        self.associatedUser.removeAll()
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/playlists/" + playlistId)!
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
                    callback(0)
                    return
                }
                do {
                    _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    let decoder = JSONDecoder()
                    let requestResult = try decoder.decode(FollowersOfAPlaylistResult.self, from: data)
                    var count = requestResult.playlist.followers.count
                    print("count")
                    if count > 0 {
                        for i in 0...(count - 1) {
                            let newElem = Followers(userId: requestResult.playlist.followers[i].userId, userPseudo: requestResult.playlist.followers[i].userPseudo)
                            self.followers.append(newElem)
                        }
                    }
                    count = requestResult.playlist.associatedUsers.count
                    if count > 0 {
                        for i in 0...(count - 1) {
                            let newElem = AssociatedUsers(userId: requestResult.playlist.associatedUsers[i].userId, userPseudo: requestResult.playlist.associatedUsers[i].userPseudo, editionRight: requestResult.playlist.associatedUsers[i].editionRight)
                            self.associatedUser.append(newElem)
                        }
                    }
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
}
