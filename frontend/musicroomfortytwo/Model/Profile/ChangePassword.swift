//
//  ChangePassword.swift
//  musicroomfortytwo
//
//  Created by ML on 12/02/2021.
//

import Foundation

class ChangePassword {
    
    static let shared = ChangePassword()
    private init() {}
    private var task: URLSessionDataTask?
    
    func changePassword(currentPassword: String, newPassword: String, callback: @escaping (Int) -> Void) {
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/users/" + userId + "/password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "currentPassword=" + currentPassword + "&newPassword=" + newPassword
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
                if let responseJSON = try? JSONDecoder().decode([String: String].self, from: data) {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            callback(1)
                            return
                        } else if response.statusCode == 400 {
                            if responseJSON["code"] == "0" {
                                callback(2) // Invalid current password!
                                return
                            } else {
                                callback(3) //Invalid new password format!
                                return
                            }
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
