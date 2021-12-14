//
//  GetUserProfile.swift
//  musicroomfortytwo
//
//  Created by ML on 10/02/2021.
//

import Foundation

/*  This Class is requesting basic infos of our connected user (firstname, lastname, pseudo) */

struct GetUserProfileResult: Decodable {
    var userProfile: UserProfile
}

struct UserProfile: Decodable {
    var userInfo: UserInfos
    var userData: UserData
}

struct UserInfos: Decodable {
    var firstName: String
    var lastName: String
    var pseudo: String
    var email: String
    var secondaryEmail: String?
    var musicalPreferences: [String]?
}

struct UserData: Decodable {
    var friendsId: [String]
    var playlists: [UserPlaylistObject]
    var events: [UserEvents]
}

struct UserPlaylistObject: Decodable {
    var playlist: String
}

struct UserEvents: Decodable {
    var eventsId: String
}

class GetUserProfile {
    static let shared = GetUserProfile()
    private init() {}
    private var task: URLSessionTask?
    
    var userInfos = UserInfos(firstName: "", lastName: "", pseudo: "", email: "", musicalPreferences: [""])
    var userData = UserData(friendsId: [], playlists: [], events: [])
    
    func getUserProfile(callback: @escaping (Int) -> Void) {
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/me")!
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
                let httpResponse = response as? HTTPURLResponse
                if httpResponse?.statusCode != 200 {
                    callback(0)
                    return
                }
                guard let data = data, error == nil else {
                    callback(0)
                    return
                }
                do {
                    self.userData.events.removeAll()
                    self.userData.friendsId.removeAll()
                    self.userData.playlists.removeAll()
                    let _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    let decoder = JSONDecoder()
                    let userProfileResult = try decoder.decode(GetUserProfileResult.self, from: data)
                    self.userInfos.firstName = userProfileResult.userProfile.userInfo.firstName
                    self.userInfos.lastName = userProfileResult.userProfile.userInfo.lastName
                    self.userInfos.pseudo = userProfileResult.userProfile.userInfo.pseudo
                    self.userInfos.email = userProfileResult.userProfile.userInfo.email
                    if userProfileResult.userProfile.userInfo.secondaryEmail != nil {
                        self.userInfos.secondaryEmail = userProfileResult.userProfile.userInfo.secondaryEmail
                    } else {
                        self.userInfos.secondaryEmail = nil
                    }
                    self.userInfos.musicalPreferences = userProfileResult.userProfile.userInfo.musicalPreferences
                    for i in 0 ..< userProfileResult.userProfile.userData.friendsId.count {
                        self.userData.friendsId.append(userProfileResult.userProfile.userData.friendsId[i])
                    }
                    for i in 0 ..< userProfileResult.userProfile.userData.playlists.count {
                        self.userData.playlists.append(userProfileResult.userProfile.userData.playlists[i])
                    }
                    for i in 0 ..< userProfileResult.userProfile.userData.events.count {
                        self.userData.events.append(userProfileResult.userProfile.userData.events[i])
                    }
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
