//
//  GetPublicEvents.swift
//  musicroomfortytwo
//
//  Created by ML on 06/02/2021.
//

import Foundation

struct PublicEventResult {
    let _id: String
    let name: String
    let tracksInfo: [TrackInfos]
}

class GetPublicEvents {
    
    static let shared = GetPublicEvents()
    private init() {}
    private var task: URLSessionTask?
    
    var publicEvents: [PublicEventResult] = []
    
    func getPublicEvents(callback: @escaping (Int) -> Void) {
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/events")!
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
            self.publicEvents.removeAll()
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    callback(0)
                    return
                }
                do {
                    _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    let decoder = JSONDecoder()
                    let userEvents = try decoder.decode(UserEventsResponse.self, from: data)
                    let count = userEvents.events.count
                    if count > 0 {
                        self.recordInfo(events: userEvents.events)
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

    func recordInfo(events: [EventObject]) {
        let count = events.count
        
        // create a fake playlist ! 
        if count > 0 {
            for i in 0...(count - 1) {
                let newElem = PublicEventResult(_id: events[i]._id, name: events[i].name, /*geoLoc: events[i].geoLoc, place: events[i].place,*/ tracksInfo: [])
                self.publicEvents.append(newElem)
            }
        }
    }
}
