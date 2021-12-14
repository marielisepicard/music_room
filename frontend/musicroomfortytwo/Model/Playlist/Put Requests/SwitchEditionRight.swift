//
//  SwitchEditionRight.swift
//  musicroomfortytwo
//
//  Created by ML on 14/02/2021.
//

import Foundation

class SwitchEditionRight {
    
    static let shared = SwitchEditionRight()
    private init() {}
    private var task: URLSessionTask?
    
    func switchEditionRight(playlistId: String, callback: @escaping (Int) -> Void) {
        
        let userId = UserDefaults.standard.string(forKey: "userId")!
        
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/users/" + userId + "/playlists/" + playlistId + "/switchEditionRight")!

        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue(UIDevice.modelName, forHTTPHeaderField: "deviceModel")
        request.addValue(UIDevice.current.systemVersion, forHTTPHeaderField: "deviceOSVersion")
        request.addValue(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String, forHTTPHeaderField: "musicRoomVersion")
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        let jsonDictionary: [String: String] = [:]
        
        let data = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
        URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
            if let error = error {
                print("Error making PUT request: \(error.localizedDescription)")
                return
            }
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                guard responseCode == 200 else {
                    print("Invalid response code: \(responseCode)")
                    callback(0)
                    return
                }
                if let _ = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) {
                    callback(1)
                    return
                }
            }
        }.resume()
        
    }
    
}
