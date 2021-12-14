//
//  UpdateUserInfos.swift
//  musicroomfortytwo
//
//  Created by ML on 10/02/2021.
//

import Foundation

struct PutUserProfileResult: Decodable {
    let message: PutUserProfile
}

struct PutUserProfile: Decodable {
    let userInfo: PutUserInfo
}

struct PutUserInfo: Decodable {
    var firstName: String
    var lastName: String
    var pseudo: String
}

class UpdateUserInfos {
    
    static let shared = UpdateUserInfos()
    private init() {}
    private var task: URLSessionTask?
    
    var userSavedInfos = GetUserProfile.shared.userInfos
    
    func updateUserInfos(userNewInfos: UserInfos, callback: @escaping (Int) -> Void) {
        
        var firstName = ""
        var lastName = ""
        var pseudo = ""
        
        if userSavedInfos.firstName != userNewInfos.firstName {
            firstName = userNewInfos.firstName
        } else {
            firstName = userSavedInfos.firstName
        }
        if userSavedInfos.lastName != userNewInfos.lastName {
            lastName = userNewInfos.lastName
        } else {
            lastName = userSavedInfos.lastName
        }
        if userSavedInfos.pseudo != userNewInfos.pseudo {
            pseudo = userNewInfos.pseudo
        } else {
            pseudo = userSavedInfos.pseudo
        }
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
            "pseudo": pseudo,
            "firstName": firstName,
            "lastName": lastName,
        ]
        let data = try! JSONSerialization.data(withJSONObject: jsonDictionary, options: .prettyPrinted)
        URLSession.shared.uploadTask(with: request, from: data) { (responseData, response, error) in
            if let error = error {
                print("Error making PUT request: \(error.localizedDescription)")
                return
            }
            if let responseCode = (response as? HTTPURLResponse)?.statusCode, let responseData = responseData {
                guard responseCode == 200 else {
                    if let json = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments) as? [String: String] {
                        if (json["code"] == "5") {
                            callback(5)
                            return
                        } else {
                            callback(6)
                            return
                        }
                    }
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
