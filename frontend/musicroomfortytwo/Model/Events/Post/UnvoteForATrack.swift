//
//  UnvoteForATrack.swift
//  musicroomfortytwo
//
//  Created by ML on 25/02/2021.
//

import Foundation
import CoreLocation

extension Event {
    func unvoteForATrack(trackId: String, userLoc: CLLocationCoordinate2D?, callback: @escaping (Int) -> Void) {
        var task: URLSessionTask?
        let route = UserDefaults.standard.string(forKey: "route")!
        var rootUrl = route + "/events/" + self.id!
        rootUrl += "/tracks/" + trackId + "/unvote"
        var request = URLRequest(url: URL(string: rootUrl)!)
        if userLoc != nil {
            var body = "lat=" + String(userLoc!.latitude)
            body += "&long=" + String(userLoc!.longitude)
            request.httpBody = body.data(using: .utf8)
        }
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
                            if responseJSON["code"] == "2" { // user is not located
                                callback(2)
                                return
                            } else if responseJSON["code"] == "5" {
                                callback(2) // user is not located
                                return
                            } else {
                                callback(1) //Internal error!
                                return
                            }
                        } else {
                            callback(1)
                            return
                        }
                    }
                    callback(1)
                    return
                } else {
                    callback(1)
                    return
                }
            }
         }
         task?.resume()
    }
}
