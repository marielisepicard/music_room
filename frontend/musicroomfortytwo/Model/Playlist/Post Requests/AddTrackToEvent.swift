//
//  AddTrackToEvent.swift
//  musicroomfortytwo
//
//  Created by ML on 23/02/2021.
//

import Foundation

class AddTrackToEvent {
    
    static let shared = AddTrackToEvent()
    private init() {}
    private var task: URLSessionDataTask?
    
    func addTrackToEvent(eventId: String, trackId: String, callback: @escaping (Int) -> Void) {
        let route = UserDefaults.standard.string(forKey: "route")!
        let body = "trackDuration=" + UserDefaults.standard.string(forKey: "durationOfSelectedTrack")!
        let url = URL(string: route + "/events/" + eventId + "/tracks/" + trackId)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
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
                                callback(0)
                                return
                            } else if responseJSON["code"] == "1" {
                                callback(0)
                                return
                            } else if responseJSON["code"] == "2" {
                                callback(2)
                                return
                            } else if responseJSON["code"] == "3" {
                                callback(3)
                                return
                            }
                        }
                    }
                 }
                callback(0)
                return
             }
         }
         task?.resume()
    }
    
}

