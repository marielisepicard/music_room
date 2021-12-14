//
//  changeOrderTracks.swift
//  musicroomfortytwo
//
//  Created by Jerome on 23/03/2021.
//

import Foundation


class ChangeOrderTracks {
    
    static let shared = ChangeOrderTracks()
    private init() {}
    private var task: URLSessionDataTask?
    
    func changeOrderTracks(oldIndex: Int, newIndex: Int, callback: @escaping (Int) -> Void) {
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let playlistId = UserDefaults.standard.string(forKey: "idOfSelectedPlaylist")!
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/playlists/" + playlistId + "/changeTracksOrder")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue(UIDevice.modelName, forHTTPHeaderField: "deviceModel")
        request.addValue(UIDevice.current.systemVersion, forHTTPHeaderField: "deviceOSVersion")
        request.addValue(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String, forHTTPHeaderField: "musicRoomVersion")
        let body = "userId=" + userId + "&oldIndex=" + String(oldIndex) + "&newIndex=" + String(newIndex)
        request.httpBody = body.data(using: .utf8)
        let session = URLSession(configuration: .default)
        task?.cancel()
        task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    callback(0)
                    return
                }
                if let _ = try? JSONDecoder().decode([String: String].self, from: data) {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            callback(1)
                            return
                        }
                        callback(0)
                        return
                    }
                 }
                callback(0)
                return
             }
         }
         task?.resume()
    }
}
