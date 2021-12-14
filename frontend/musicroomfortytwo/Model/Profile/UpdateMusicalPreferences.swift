//
//  UpdateMusicalPreferences.swift
//  musicroomfortytwo
//
//  Created by ML on 12/02/2021.
//

import Foundation

class UpdateMusicalPreferences {
    
    static let shared = UpdateMusicalPreferences()
    private init() {}
    private var task: URLSessionTask?
    
    var userSavedInfos = GetUserProfile.shared.userInfos
    
    func updateUserInfos(newMusicalPreferences: String, callback: @escaping (Int) -> Void) {
        userSavedInfos = GetUserProfile.shared.userInfos
        AdjustStringFormat.shared.prepareStringFormat(userSavedInfos.musicalPreferences!)
        let currentMusicalPreferences = UserDefaults.standard.string(forKey: "testString")!
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/users/" + userId)!
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
        let jsonDictionary: [String: String] = [
            "musicalPreferences": newMusicalPreferences
        ]
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
