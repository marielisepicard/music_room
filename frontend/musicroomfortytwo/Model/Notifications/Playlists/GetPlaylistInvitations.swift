//
//  GetPlaylistInvitations.swift
//  musicroomfortytwo
//
//  Created by ML on 15/02/2021.
//

import Foundation

struct PendingPlaylistInvit: Decodable {
    let code: String
    let playlistsInvitations: [PlaylistsInvitations]
}

struct PlaylistsInvitations: Decodable {
    let friendPseudo: String
    let playlistId: String
    let playlistName: String
}

class GetPlaylistInvitations {
    
    static let shared = GetPlaylistInvitations()
    private init() {}
    private var task: URLSessionDataTask?
    
    var playlistInvitationsResult: [PlaylistsInvitations] = []
    
    func getPlaylistInvitations(callback: @escaping (Int) -> Void) {
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/users/" + userId + "/playlistsInvitations")!
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
                    let result = try decoder.decode(PendingPlaylistInvit.self, from: data)
                    self.recordData(invitations: result.playlistsInvitations)
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
    
    func recordData(invitations: [PlaylistsInvitations]) {
        self.playlistInvitationsResult.removeAll()
        let count = invitations.count
        if count > 0 {
            for i in 0...(count - 1) {
                let newElem = PlaylistsInvitations(friendPseudo: invitations[i].friendPseudo, playlistId: invitations[i].playlistId, playlistName: invitations[i].playlistName)
                self.playlistInvitationsResult.append(newElem)
            }
        }
    }
    
    func printResult() {
        let count = self.playlistInvitationsResult.count
        if count > 0 {
            for i in 0...(count - 1) {
                print("Invitation ", String(i + 1), " ID Playlist : ", self.playlistInvitationsResult[i].playlistId, " nom : ", self.playlistInvitationsResult[i].playlistName, " de la part : ", self.playlistInvitationsResult[i].friendPseudo)
            }
        }
    }
}
