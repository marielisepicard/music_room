//
//  DiscussionsList.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 24/03/2021.
//

import Foundation

struct UserDiscussionsResponse: Decodable {
    let code: String
    let discussions: [DiscussionObject]
}

struct DiscussionObject: Decodable {
    var recipient: RecipientObject
    var messages: [MessageObject]
}

struct RecipientObject: Decodable {
    var id: String
    var pseudo: String
}

struct MessageObject: Decodable {
    var content: String
    var ownerId: String
    var date: String
}

class DiscussionsList {
    var discussions: [Discussion?] = []

    init(){}
    func getUserDiscussions(callback: @escaping (Int) -> Void) {
        var task: URLSessionTask?
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/me/discussions")!
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
            self.discussions.removeAll()
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    return
                }
                do {
                    let responseJSON = try JSONDecoder().decode(UserDiscussionsResponse.self, from: data)
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            self.fillDiscussionsListFromRequest(responseJSON: responseJSON)
                        }
                    }
                    callback(1)
                    return
                } catch let parsingError {
                    print("Error", parsingError)
                }
             }
         }
         task?.resume()
    }
    func fillDiscussionsListFromRequest(responseJSON: UserDiscussionsResponse) {
        for i in 0 ..< responseJSON.discussions.count {
            self.discussions.append(Discussion(responseJSON.discussions[i]))
        }
    }
}
