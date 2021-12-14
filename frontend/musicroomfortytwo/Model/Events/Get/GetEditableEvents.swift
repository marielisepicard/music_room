//
//  GetEditableEvents.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 31/03/2021.
//

import Foundation

extension EventsList {
    func getEditableEvents(callback: @escaping (Int) -> Void) {
        var task: URLSessionTask?
        let route = UserDefaults.standard.string(forKey: "route")!
        var urlStr = route + "/users/" + UserDefaults.standard.string(forKey: "userId")!
        urlStr += "/events/editableEvents"
        print(urlStr)
        let url = URL(string: urlStr)!
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
            self.events.removeAll()
            self.events.append([])
            self.events.append([])
            self.events.append([])
            self.coverListIds = ""
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    callback(0)
                    return
                }
                do {
                    let responseJSON = try JSONDecoder().decode(UserEventsResponse.self, from: data)
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            self.fillEventsListFromRequest(responseJSON: responseJSON) { (success) in
                                callback(1)
                            }
                        } else {
                            callback(0)
                        }
                    } else {
                        callback(0)
                        return
                    }
                } catch let parsingError {
                    print("Error", parsingError)
                    callback(0)
                }
             }
         }
         task?.resume()
    }
}
