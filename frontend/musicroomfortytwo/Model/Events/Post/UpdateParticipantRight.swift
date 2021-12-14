//
//  UpdateParticipantRight.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 12/03/2021.
//

import Foundation

extension Event {
    func updateParticipantRight(participantId: String, participantRight: String, callback: @escaping (Int) -> Void) {
        var task: URLSessionTask?
        let route = UserDefaults.standard.string(forKey: "route")!
        var rootUrl = route + "/users/" + UserDefaults.standard.string(forKey: "userId")!
        rootUrl += "/events/" + self.id!
        rootUrl += "/updateParticipantRight"
        rootUrl += "/participants/" + participantId
        print(rootUrl)
        var request = URLRequest(url: URL(string: rootUrl)!)
        let body = "participantRight=" + participantRight
        request.httpBody = body.data(using: .utf8)
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
                    callback(1)
                    return
                }
                if let responseJSON = try? JSONDecoder().decode([String: String].self, from: data) {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            callback(0)
                            return
                        } else if response.statusCode == 400 {
                            if responseJSON["code"] == "3" { //Cannot change own right
                                callback(2)
                                return
                            } else {
                                callback(1)
                                return
                            }
                        } else {
                            callback(1)
                            return
                        }
                    }
                }
                callback(1)
                return
             }
         }
         task?.resume()
    }
}
