//
//  DeleteATrack.swift
//  musicroomfortytwo
//
//  Created by ML on 03/02/2021.
//

import Foundation

class DeleteATrack {
    
    static let shared = DeleteATrack()
    private init() {}
    private var task: URLSessionDataTask?
    
    func deleteATrack(playlistId: String, index: Int, callback: @escaping (Bool) -> Void) {
        let route = UserDefaults.standard.string(forKey: "route")!
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let url = URL(string: route + "/playlists/" + playlistId + "/tracks" + "?userId=" + userId + "&index=" + String(index))!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
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
                    callback(false)
                    return
                }
                if let _ = try? JSONDecoder().decode([String: String].self, from: data) {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            callback(true)
                            return
                        }
                    }
                 }
                callback(false)
                return
             }
         }
         task?.resume()
    }
}
