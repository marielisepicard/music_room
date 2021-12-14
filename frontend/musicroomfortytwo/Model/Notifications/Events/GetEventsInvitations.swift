//
//  GetEventInvitations.swift
//  musicroomfortytwo
//
//  Created by ML on 15/02/2021.
//

import Foundation

struct PendingEventInvit: Decodable {
    let code: String
    let eventsInvitations: [EventsInvitations]
}

struct EventsInvitations: Decodable {
    let friendPseudo: String
    let friendId: String
    let eventId: String
    let eventName: String
}

class GetEventInvitations {
    
    static let shared = GetEventInvitations()
    private init() {}
    private var task: URLSessionDataTask?
    
    var eventInvitationsResult: [EventsInvitations] = []
    
    func getEventInvitations(callback: @escaping (Int) -> Void) {
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/users/" + userId + "/eventsInvitations")!
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
                guard let data = data, error == nil else {
                    callback(0)
                    return
                }
                do {
                    _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(PendingEventInvit.self, from: data)
                    self.recordData(invitations: result.eventsInvitations)
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
    
    func recordData(invitations: [EventsInvitations]) {
        self.eventInvitationsResult.removeAll()
        let count = invitations.count
        if count > 0 {
            for i in 0...(count - 1) {
                let newElem = EventsInvitations(friendPseudo: invitations[i].friendPseudo, friendId: invitations[i].friendId, eventId: invitations[i].eventId, eventName: invitations[i].eventName)
                self.eventInvitationsResult.append(newElem)
            }
        }
    }
    
    func printResult() {
        let count = self.eventInvitationsResult.count
        if count > 0 {
            for i in 0...(count - 1) {
                print("Invitation ", String(i + 1), " ID Event : ", self.eventInvitationsResult[i].eventId, " nom : ", self.eventInvitationsResult[i].eventName, " de la part : ", self.eventInvitationsResult[i].friendPseudo)
            }
        }
    }
}
