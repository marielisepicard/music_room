//
//  UserEvents.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 06/03/2021.
//

import Foundation

struct UserEventsResponse: Decodable {
    let code: String
    let events: [EventObject]
}

struct EventObject: Decodable {
    let _id: String
    let name: String
    let creator: String
    let publicFlag: Bool
    let status: String
    let votingPrerequisites: Bool
    let musicalStyle: String?
    let guestsNumber: Int
    let guestsInfo: [GuestInfos]
    let tracksInfo: [TrackInfos]
    let physicalEvent: Bool
    let place: String?
    let geoLoc: Geoloc?
    let beginDate: String?
    let endDate: String?
}

struct Geoloc: Decodable {
    let lat: Double
    let long: Double
}

struct GuestInfos: Decodable {
    let userId: String
    let pseudo: String
    let right: String
}

struct TrackInfos: Decodable {
    let trackId: String
    let votesNumber: Int
    let userVote: Bool
    let timeBeginListening: String?
}

class EventsList {
    var events: [[Event]?] = []
    var coverListIds: String?
    
    init(){}
    func getUserEvents(callback: @escaping (Int) -> Void) {
        var task: URLSessionTask?
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/me/events")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue(UIDevice.modelName, forHTTPHeaderField: "deviceModel")
        request.addValue(UIDevice.current.systemVersion, forHTTPHeaderField: "deviceOSVersion")
        request.addValue(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String, forHTTPHeaderField: "musicRoomVersion")
        let session = URLSession(configuration: .default)
        print(request)
        task?.cancel()
        task = session.dataTask(with: request) { (data, response, error) in
            self.events.removeAll()
            self.events.append([])
            self.events.append([])
            self.events.append([])
            self.coverListIds = ""
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let responseJSON = try JSONDecoder().decode(UserEventsResponse.self, from: data)
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            self.fillEventsListFromRequest(responseJSON: responseJSON) { (success) in
                                if success == false {
                                    callback(0)
                                    return
                                } else {
                                    callback(1)
                                    return
                                }
                            }
                        }
                    }
                    return
                } catch let parsingError {
                    print("Error", parsingError)
                }
             }
         }
         task?.resume()
    }
    func fillEventsListFromRequest(responseJSON: UserEventsResponse, callback: @escaping (Bool) -> Void) {
        if responseJSON.events.count == 0 {
            return
        }
        for i in 0 ..< responseJSON.events.count {
            if responseJSON.events[i].status == "started" {
                self.events[0]!.append(Event(event: responseJSON.events[i]))
            } else if responseJSON.events[i].status == "notStarted" {
                self.events[1]!.append(Event(event: responseJSON.events[i]))
            }  else if responseJSON.events[i].status == "terminated" {
                self.events[2]!.append(Event(event: responseJSON.events[i]))
            }
        }
        for i in 0 ..< events.count {
            for j in 0 ..< events[i]!.count {
                if events[i]![j].tracks.count > 0 {
                    if self.coverListIds == "" {
                        self.coverListIds = events[i]![j].tracks[0].id
                    } else {
                        self.coverListIds! += "," + events[i]![j].tracks[0].id!
                    }
                }
            }
        }
        if self.coverListIds != "" {
            GetSeveralTracks.shared.getSeveralTracks(trackslist: self.coverListIds!) { (success) in
                if success == false {
                    print("error when converting tracks id from spotify")
                    callback(false)
                    return
                }
                self.addCoverImageToEvents()
                callback(true)
                return
            }
        } else {
            callback(true)
            return
        }
    }
    func addCoverImageToEvents() {
        var trackCounter = 0
        for i in 0 ..< events.count {
            for j in 0 ..< events[i]!.count {
                if events[i]![j].tracks.count > 0 {
                    events[i]![j].coverEvent = UIImage(url: URL(string: GetSeveralTracks.shared.displayablePlaylist[trackCounter].imageHdUrl))
                    trackCounter += 1
                }
            }
        }
    }
}
