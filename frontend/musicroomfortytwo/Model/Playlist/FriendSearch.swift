//
//  FriendSearch.swift
//  musicroomfortytwo
//
//  Created by ML on 04/02/2021.
//

import Foundation

// The 2 structures bellow are necessary to receive the response object
// from our request
struct FriendSearchResult: Decodable {
    let _id: String
    let userInfo: UserInfo
}

struct UserInfo: Decodable {
    let pseudo: String
}

// This structure allows to save the result
struct SearchResult {
    let _id: String
    let pseudo: String
}

class FriendSearch {
    
    static let shared = FriendSearch()
    private init() {}
    private var task: URLSessionTask?
    var searchResult: [SearchResult] = []
    
    func friendSearch(keyWord: String, callback: @escaping (Bool) -> Void) {
        let route = UserDefaults.standard.string(forKey: "route")!
        let parameters = ["value": keyWord, "type": "pseudos"]
        var components = URLComponents(string: route + "/search")!
        components.queryItems = parameters.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        let token = UserDefaults.standard.string(forKey: "userToken")!
        let bearer = "Bearer " + token
        request.setValue(bearer, forHTTPHeaderField: "Authorization")
        request.addValue(UIDevice.modelName, forHTTPHeaderField: "deviceModel")
        request.addValue(UIDevice.current.systemVersion, forHTTPHeaderField: "deviceOSVersion")
        request.addValue(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String, forHTTPHeaderField: "musicRoomVersion")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode, error == nil else {
                callback(false)
                return
            }
            do {
                _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                let decoder = JSONDecoder()
                let getFriendsResult = try decoder.decode([FriendSearchResult].self, from: data)
                self.recordFriendsResult(friendResult: getFriendsResult)
                callback(true)
                return
            } catch let parsingError {
                print("Error", parsingError)
            }
            callback(false)
            return
        }
        task.resume()
    }
 
    func recordFriendsResult(friendResult: [FriendSearchResult]) {
        let userId = UserDefaults.standard.string(forKey: "userId")!
        searchResult.removeAll()
        let count = friendResult.count
        if count > 0 {
            for i in 0...(count - 1) {
                if (friendResult[i]._id != userId) {
                    let _id = friendResult[i]._id
                    let pseudo = friendResult[i].userInfo.pseudo
                    let newFriend = SearchResult(_id: _id, pseudo: pseudo)
                    self.searchResult.append(newFriend)
                }
            }
        }
    }
}
