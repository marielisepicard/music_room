//
//  GetUserPlaylist.swift
//  musicroomfortytwo
//
//  Created by ML on 02/02/2021.
//

import Foundation

// The Object return by the request that get all user playlists
private struct AllUserPlaylistRequest: Decodable {
    let playlists: [AllUserPlaylists]
}

// A list of playlists
private struct AllUserPlaylists: Decodable {
    let _id: String?
    let playlist: Playlist
    let playlistType: Int
}

// A playlist object
private struct Playlist: Decodable {
    let `public`: Bool?
    let _id: String?
    let name: String?
    let creator: Creator?
    let tracks: [TracksPlaylist?]
}

private struct Creator: Decodable {
    let userInfo: Pseudo
}

private struct Pseudo: Decodable {
    let pseudo: String
}

private struct TracksPlaylist: Decodable {
    let trackId: String
}

// This structure contains all the playlist of the user. This will be used in the rest of the Project.
struct UserPlaylists {
    let id: String
    let name: String
    let creator: String
    let track: String
    var trackImage: UIImage?
}

/*
    This class gives every playlist that belong to the user
 */
class GetUserPlaylist {
    init() {}
    var userPlaylists: [[UserPlaylists]] = []
    private var task: URLSessionDataTask?
    
    func printPlaylist() {
        print("we are going to print the playlist ! ")
        var len = 0
        let count = userPlaylists.count
        if count > 0 {
            for i in 0...(count - 1) {
                len = userPlaylists[i].count
                for j in 0...(len) {
                    print("playlist n°", String(i + 1), " title: ", userPlaylists[i][j].name, " id : ", userPlaylists[i][j].id)
                }
            }
        }
    }
    
    func getUserPlaylist(callback: @escaping (Int) -> Void) {
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/users/" + UserDefaults.standard.string(forKey: "userId")! + "/playlists")!
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
                    let userPlaylists = try decoder.decode(AllUserPlaylistRequest.self, from: data)
                    self.recordPlaylistsInfo(playlists: userPlaylists)
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
    
    private func recordPlaylistsInfo(playlists: AllUserPlaylistRequest) {
        let count = playlists.playlists.count
        userPlaylists.removeAll()
        if count > 0 {
            userPlaylists.append([])
            userPlaylists.append([])
            userPlaylists.append([])
            for i in 0...(count - 1) {
                let id = playlists.playlists[i].playlist._id!
                let name = playlists.playlists[i].playlist.name!
                let creator = playlists.playlists[i].playlist.creator!.userInfo.pseudo
                var track = ""
                if (playlists.playlists[i].playlist.tracks.count > 0) {
                    track = playlists.playlists[i].playlist.tracks[0]!.trackId
                }
                let playlist = UserPlaylists(id: id, name: name, creator: creator, track: track)
                userPlaylists[playlists.playlists[i].playlistType].append(playlist)
            }
        }
    }
}
