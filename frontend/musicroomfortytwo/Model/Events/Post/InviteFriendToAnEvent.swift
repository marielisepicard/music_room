//
//  InviteFriendToAnEvent.swift
//  musicroomfortytwo
//
//  Created by ML on 08/02/2021.
//

import Foundation

struct InviteFriendResponse: Decodable {
    let code: String
    let message: String
}

extension Event {
    func inviteFriendToAnEvent(friendId: String, callback: @escaping (Bool, Int) -> Void) {
        var task: URLSessionTask?
        let userId = UserDefaults.standard.string(forKey: "userId")
        let route = UserDefaults.standard.string(forKey: "route")!
        var urlStr = route + "/users/" + userId! + "/events/" + self.id!
        urlStr += "/invite/friends/" + friendId
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
                    callback(false, 0)
                    return
                }
                if let responseJSON = try? JSONDecoder().decode(InviteFriendResponse.self, from: data) {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            callback(true, 0)
                        } else if response.statusCode == 400 {
                            callback(false, Int(responseJSON.code)!)
                        } else {
                            callback(false, 0)
                        }
                        return
                    } else {
                        callback(false, 0)
                    }
                }
                callback(false, 0)
                return
             }
         }
         task?.resume()
    }
}
