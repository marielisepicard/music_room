//
//  CreateEvent.swift
//  musicroomfortytwo
//
//  Created by ML on 06/02/2021.
//

import Foundation

struct CreateEventResponse: Decodable {
    let code: String
}

extension Event {
    func createEvent(name: String, visibility: String, votingPrerequisites: Bool, musicalStyle: String, physicalEvent: Bool, place: String?, beginDate: String?, endDate: String?, callback: @escaping (Int) -> Void) {
        
        var task: URLSessionTask?
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/events")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let token = UserDefaults.standard.string(forKey: "userToken") ?? ""
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue(UIDevice.modelName, forHTTPHeaderField: "deviceModel")
        request.addValue(UIDevice.current.systemVersion, forHTTPHeaderField: "deviceOSVersion")
        request.addValue(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String, forHTTPHeaderField: "musicRoomVersion")
        var body = "name=" + name + "&visibility=" + visibility
        body += "&votingPrerequisites=" + String(votingPrerequisites)
        body += "&musicalStyle=" + String(musicalStyle)
        if physicalEvent == true {
            body += "&physicalEvent=" + String(physicalEvent) + "&place=" + place!
                body += "&beginDate=" + beginDate! + "&endDate=" + endDate!
        }
        request.httpBody = body.data(using: .utf8)
        let session = URLSession(configuration: .default)
        task?.cancel()
        task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    callback(0)
                    return
                }
                if let responseJSON = try? JSONDecoder().decode(CreateEventResponse.self, from: data) {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 201 {
                            callback(1)
                            return
                        } else if response.statusCode == 400 {
                            if responseJSON.code == "0" {
                                callback(400) /* invalid name Format */
                                return
                            } else if responseJSON.code == "4" {
                                callback(401) /* Invalid place format */
                                return
                            } else if responseJSON.code == "5" {
                                callback(402) /* Cannot find place location */
                                return
                            } else if responseJSON.code == "6" {
                                callback(403) /* Invalid beginDate formatn */
                                return
                            } else if responseJSON.code == "7" {
                                callback(404) /* Invalid endDate format */
                                return
                            } else if responseJSON.code == "8" {
                                callback(405) /* EndDate must be after beginDate */
                                return
                            }
                        } else {
                            callback(0)// Server error or Unhandled error!
                            return
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
