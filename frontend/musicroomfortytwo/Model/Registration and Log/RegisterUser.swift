//
//  RegisterUser.swift
//  musicroomfortytwo
//
//  Created by ML on 31/01/2021.
//

import Foundation

class RegisterUser {
    
    static let shared = RegisterUser()
    private init() {}
    private var task: URLSessionTask?
    
    func registerNewUser(user: User, callback: @escaping (Int) -> Void) {
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/auth/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "email=" + user.mail + "&password=" + user.password + "&firstName=" + user.firstname + "&lastName=" + user.lastname + "&pseudo=" + user.pseudo
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
                            callback(1) // Success - User created - Validation email has been sent!
                            return
                        } else if response.statusCode == 400 {
                            if responseJSON["code"] == "0" {
                                callback(2) // Pseudo already assign to a Music Room account!
                                return
                            } else if responseJSON["code"] == "1" {
                                callback(3) // Email already assign to a Music Room account!
                                return
                            } else if responseJSON["code"] == "2" {
                                callback(6)
                                return
                            } else {
                                callback(0)// Server error or Unhandled error!
                                return
                            }
                        } else {
                            callback(0)// Server error or Unhandled error!
                            return
                        }
                    }
                }
            }
        }
        task?.resume()
    }
}
