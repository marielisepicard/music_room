//
//  RegisterFacebookUser.swift
//  musicroomfortytwo
//
//  Created by ML on 23/02/2021.
//

import Foundation

class RegisterFacebookUser {
    
    static let shared = RegisterFacebookUser()
    private init() {}
    private var task: URLSessionTask?

    func registerFacebookUser(callback: @escaping (Int) -> Void) {
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/auth/signup/facebook")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let token = UserDefaults.standard.string(forKey: "facebookToken")!
        let body = "token=" + token
        request.httpBody = body.data(using: .utf8)
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
                        if response.statusCode == 201 {
                            let userId = responseJSON["userId"] ?? ""
                            UserDefaults.standard.set(userId, forKey: "userId")
                            UserDefaults.standard.set(userId, forKey: "facebookId")
                            callback(1)
                            return
                        } else if response.statusCode == 400 {
                            if responseJSON["code"] == "0" {
                                callback(2)
                                return
                            } else if responseJSON["code"] == "1" {
                                callback(0)
                                return
                            } else if responseJSON["code"] == "2" {
                                callback(0)
                                return
                            }
                        } else {
                            callback(0)
                            return
                        }
                    }
                    print(responseJSON)
                    callback(1)
                    return
                }
            }
        }
        task?.resume()
    }
}
