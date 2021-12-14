//
//  GetPlaylistCreator.swift
//  musicroomfortytwo
//
//  Created by ML on 14/02/2021.
//

import Foundation

/*
    This class makes a request : you give a playlistId and in the playlistCreator
    variable is saved the userId of the creator of the playlist.
    With this information, you can compare it to the current userId and know
    if he is the creator of the playlist.
 
    You can also know if the playlist is public or private.
 
    You can also know if the playlist has editionRight 
 */

struct SpecifiedPlaylistRes: Decodable {
    let playlist: SpecifiedPlaylistSubRes
}

struct SpecifiedPlaylistSubRes: Decodable {
    let creator: String
    let `public`: Bool
    let editionRight: Bool
    let musicalStyle: String
}

class GetPlaylistCreator {
    
    static let shared = GetPlaylistCreator()
    private init() {}
    var playlistCreator = ""
    var publicPlaylist = false
    var editionRightPlaylist = false
    var musicalStyle = ""
    private var task: URLSessionDataTask?
    
    func getPlaylistCreator(playlistId: String, callback: @escaping (Int) -> Void) {
        playlistCreator = ""
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
                    let requestResult = try decoder.decode(SpecifiedPlaylistRes.self, from: data)
                    self.playlistCreator = requestResult.playlist.creator
                    self.publicPlaylist = requestResult.playlist.public
                    self.editionRightPlaylist = requestResult.playlist.editionRight
                    self.musicalStyle = requestResult.playlist.musicalStyle
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
