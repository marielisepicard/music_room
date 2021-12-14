//
//  CreatePlaylist.swift
//  musicroomfortytwo
//
//  Created by ML on 01/02/2021.
//

import Foundation

class CreatePlaylist {
    
    static let shared = CreatePlaylist()
    private init() {}
    private var task: URLSessionDataTask?
    
    func createNewPlaylist(title: String, publicPlaylist: Bool, editionRight: Bool, musicalStyle: String, callback: @escaping (Int) -> Void) {
        
        var publicP = ""
        var editionR = ""
        
        if publicPlaylist == true {
            publicP = "true"
        } else {
            publicP = "false"
        }
        if editionRight == true {
            editionR = "true"
        } else {
            editionR = "false"
        }
        
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/users/" + UserDefaults.standard.string(forKey: "userId")! + "/playlists")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "name=" + title + "&public=" + publicP + "&editionRight=" + editionR + "&musicalStyle=" + musicalStyle
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue(UIDevice.modelName, forHTTPHeaderField: "deviceModel")
        request.addValue(UIDevice.current.systemVersion, forHTTPHeaderField: "deviceOSVersion")
        request.addValue(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String, forHTTPHeaderField: "musicRoomVersion")
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
                        if response.statusCode == 201 {
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
