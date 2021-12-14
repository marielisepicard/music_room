//
//  SearchFriends.swift
//  musicroomfortytwo
//
//  Created by Jerome on 11/03/2021.
//

import Foundation

class SearchFriends {
    
    static let shared = SearchFriends()
    private init() {}
    private var task: URLSessionTask?
    var friendsList: [FriendsList] = []
    
    func getUserFriends(value: String, callback: @escaping (Int, [FriendsList]?) -> Void) {
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/users/" + userId + "/searchFriends" + "?value=" + value)!
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
                self.friendsList.removeAll()
                guard let data = data, error == nil else {
                    return
                }
                do {
                    _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    let decoder = JSONDecoder()
                    let userFriends = try decoder.decode([FriendsList].self, from: data)
                    callback(1, userFriends)
                    return

                } catch let parsingError {
                    print("Error", parsingError)
                    callback(0, nil)
                    return
                }
             }
         }
         task?.resume()
    }
}
