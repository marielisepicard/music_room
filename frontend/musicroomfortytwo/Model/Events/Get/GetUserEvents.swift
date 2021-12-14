//
//  GetUserEvents.swift
//  musicroomfortytwo
//
//  Created by ML on 06/02/2021.
//

import Foundation
//
//struct UserEventsResponse: Decodable {
//    let code: String
//    let events: [EventObject]
//}
//
//struct EventObject: Decodable {
////    let geoLoc: Geoloc
//    let publicFlag: Bool
//    let guestsNumber: Int
//    let _id: String
//    let name: String
////    let place: String
////    let beginDate: String
////    let endDate: String
//    let guestsInfo: [GuestInfos]
//    let tracksInfo: [TrackInfos]
//}
//
//struct Geoloc: Decodable {
//    let lat: Float
//    let long: Float
//}
//
//struct GuestInfos: Decodable {
//    let userId: String
//    let right: String
//}
//
//struct TrackInfos: Decodable {
//    let trackId: String
//    let votesNumber: Int//String
//}
//
//struct EventResults {
//    let name: String
//    let eventId: String
//}
//
//class UserEvents {
//    var events: [Event]
//
//    init(){}
//    private var task: URLSessionTask?
//    func getUserEvents(callback: @escaping (Int) -> Void) {
//        let route = UserDefaults.standard.string(forKey: "route")!
//        let url = URL(string: route + "/me/events")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
//        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//        let session = URLSession(configuration: .default)
//        task?.cancel()
//        task = session.dataTask(with: request) { (data, response, error) in
//            self.events.removeAll()
//            DispatchQueue.main.async {
//                guard let data = data, error == nil else {
//                    callback(0)
//                    return
//                }
//                do {
//                    let responseJSON = try JSONDecoder().decode(UserEvents.self, from: data)
//                    if let response = response as? HTTPURLResponse {
//                        if response.statusCode == 200 {
//                            if responseJSON.events.count == 0 {
//                                callback(0)
//                                return
//                            }
//                            for i in 0...(responseJSON.events.count - 1) {
//                                print(responseJSON.events[i]._id)
//                                let eventId = responseJSON.events[i]._id
//                                let name = responseJSON.events[i].name
//                                let newElem = EventResults(name: name, eventId: eventId)
//                                self.events.append(newElem)
//                            }
//                        }
//                    }
//                    callback(1)
//                    return
//                } catch let parsingError {
//                    print("Error", parsingError)
//                    callback(0)
//                }
//             }
//         }
//         task?.resume()
//    }
//    
//    func printResult() {
//        let count = self.events.count
//        if count > 0 {
//            for i in 0...(count - 1) {
//                print("event : ", self.events[i].name)
//            }
//        }
//    }
//}
