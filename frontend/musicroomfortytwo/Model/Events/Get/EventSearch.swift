//
//  EventSearch.swift
//  musicroomfortytwo
//
//  Created by ML on 07/02/2021.
//

import Foundation

struct EventFound: Decodable {
    let _id: String
    let name: String
    let creator: String
}

class EventSearch {
    
    static let shared = EventSearch()
    private init() {}
    private var task: URLSessionTask?
    
    var eventResults: [EventFound] = []
    
    func eventSearch(keyWord: String, musicalStyle: String, callback: @escaping (Int) -> Void) {
        let route = UserDefaults.standard.string(forKey: "route")!
        self.eventResults.removeAll()
        let parameters = ["value": keyWord, "musicalStyle": musicalStyle, "type": "events"]
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
                callback(0)
                return
            }
            do {
                _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) //json
                let decoder = JSONDecoder()
                self.eventResults.removeAll()
                let eventfound = try decoder.decode([EventFound].self, from: data)
                let count = eventfound.count
                if count > 0 {
                    for i in 0...(count - 1) {
                        self.eventResults.append(eventfound[i])
                    }
                }
                callback(1)
                return
            } catch let parsingError {
                print("Error", parsingError)
            }
            callback(0)
            return
        }
        task.resume()
    }
    
    func printResult() {
        let count = self.eventResults.count
        if count > 0 {
            for i in 0...(count - 1) {
                print("event : ", self.eventResults[i].name, " ", self.eventResults[i]._id)
            }
        }
    }
}
