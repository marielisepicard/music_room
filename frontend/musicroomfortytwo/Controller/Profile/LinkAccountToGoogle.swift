//
//  LinkAccountToGoogle.swift
//  musicroomfortytwo
//
//  Created by ML on 23/02/2021.
//

import Foundation

struct attachGoogleAccountObject: Decodable {
    let code: String
}

class LinkAccountToGoogle {
    
    static let shared = LinkAccountToGoogle()
    private init() {}
    private var task: URLSessionTask?
    
    func linkAccountToGoogle(callback: @escaping (Int) -> Void) {
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let route = UserDefaults.standard.string(forKey: "route")!
        let googleUrl = URL(string: route + "/users/" + userId + "/attachGoogleAccount")!
        var token: String = UserDefaults.standard.value(forKey: "googleToken") as! String
        let clientId = UserDefaults.standard.string(forKey: "googleClientId")!
        var request = URLRequest(url: googleUrl)
        request.httpMethod = "POST"
        let body = "token=" + token + "&MusicRoom_ID=" + clientId
        request.httpBody = body.data(using: .utf8)
        token = UserDefaults.standard.string(forKey: "userToken") ?? ""
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
                    let responseJSON = try JSONDecoder().decode(attachGoogleAccountObject.self, from: data)
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            callback(1)
                            return
                        } else {
                            callback(0)
                            return
                        }
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
