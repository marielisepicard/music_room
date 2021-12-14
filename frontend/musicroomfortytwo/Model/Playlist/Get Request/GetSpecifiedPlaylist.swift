//
//  GetSpecifiedPlaylist.swift
//  musicroomfortytwo
//
//  Created by ML on 04/02/2021.
//

import Foundation

struct SpecifiedPlaylistObject: Decodable {
    var playlist: SpecifiedPlaylist
}

struct SpecifiedPlaylist: Decodable {
    let creator: SpecifiedPlaylistCreator
    var associatedUsers: [SpecifiedPlaylistAssociated]
    let followers: [SpecifiedPlaylistFollowers]
    let name: String
    var musicalStyle: String
    var `public`: Bool
    var editionRight: Bool
    var tracks: [SpecifiedPlaylistTracks]
}

struct SpecifiedPlaylistTracks: Decodable {
    let trackId: String
}

struct SpecifiedPlaylistUser: Decodable {
    var userId: String?
    var userStatus: Int?
    var userRight: Bool?
}

struct SpecifiedPlaylistCreator: Decodable {
    let userId: String
    let userPseudo: String
}

struct SpecifiedPlaylistAssociated: Decodable {
    let userId: String
    let userPseudo: String
    var editionRight: Bool
}

struct SpecifiedPlaylistFollowers: Decodable {
    let userId: String
    let userPseudo: String
}


/*
        This request allows us to check if the creator of the playlist
        is our connected user.
 */

class GetSpecifiedPlaylist {
    
    static let shared = GetSpecifiedPlaylist()
    private init() {}
    private var task: URLSessionDataTask?
    
    func getSpecifiedPlaylist(id: String, callback: @escaping (Int, SpecifiedPlaylistObject?, SpecifiedPlaylistUser?) -> Void) {
        let userId = UserDefaults.standard.string(forKey: "userId")!
        // id parameter is a playlistId
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/playlists/" + id)!
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
                    callback(0, nil, nil)
                    return
                }
                do {
                    if let _ = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    {
                        do {
                            let specifiedPlaylist = try JSONDecoder().decode(SpecifiedPlaylistObject.self, from: data)
                            let playlist = specifiedPlaylist.playlist
                            var user = SpecifiedPlaylistUser()
                            user.userId = userId
                            user.userStatus = 3
                            user.userRight = false
                            if (userId == playlist.creator.userId) {
                                user.userStatus = 0
                                user.userRight = true
                            } else {
                                for i in 0 ..< playlist.associatedUsers.count {
                                    if (userId == playlist.associatedUsers[i].userId) {
                                        user.userStatus = 1
                                        user.userRight = playlist.associatedUsers[i].editionRight
                                    }
                                }
                                if (user.userStatus == 3) {
                                    for i in 0 ..< playlist.followers.count {
                                        if (userId == playlist.followers[i].userId) {
                                            user.userStatus = 2
                                        }
                                    }
                                }
                            }
                            if (user.userRight == false && user.userStatus != 3) {
                                user.userRight = playlist.editionRight
                            }                            
                            callback(1, specifiedPlaylist, user)
                            return
                        }
                    }
                } catch let parsingError {
                    print("Error", parsingError)
                }
                callback(0, nil, nil)
                return
             }
         }
         task?.resume()
    }
}
