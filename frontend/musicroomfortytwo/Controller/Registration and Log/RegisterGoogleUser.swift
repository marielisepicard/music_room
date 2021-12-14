//
//  RegisterGoogleUser.swift
//  musicroomfortytwo
//
//  Created by ML on 22/02/2021.
//

import Foundation

class RegisterGoogleUser {
    
    static let shared = RegisterGoogleUser()
    private init() {}
    private var task: URLSessionTask?
    
    func registerGoogleUser(idToken: String, callback: @escaping (Int) -> Void) {
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/auth/signup/google")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let clientId = UserDefaults.standard.string(forKey: "googleClientId")!
        let body = "token=" + idToken + "&MusicRoom_ID=" + clientId
        request.httpBody = body.data(using: .utf8)
        let session = URLSession(configuration: .default)
        task?.cancel()
        task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    print("erreur ")
                    callback(0) /* An Error occured */
                    return
                }
                if let responseJSON = try? JSONDecoder().decode([String: String].self, from: data) {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 400 {
                            if responseJSON["code"] == "0" {
                                callback(3) /* An Account already exists with this Mail Adress */
                                return
                            } else {
                                callback(0) /* Intern Error */
                                return
                            }
                        } else if response.statusCode == 201 {
                            if responseJSON["code"] == "0" {
                                callback(2) // User Created + Mail Sent
                                return
                            } else if responseJSON["code"] == "1" {
                                let userId = responseJSON["GoogleUserId"] ?? ""
                                UserDefaults.standard.set(userId, forKey: "googleId")
                                UserDefaults.standard.setValue(userId, forKey: "userId")
                                callback(1) // User Created Without Mail
                                return
                            }
                        } else if response.statusCode == 500 {
                            // Internal Error
                            callback(0)
                            return
                        }
                    }
                    callback(0)
                    return
                }
            }
        }
        task?.resume()
    }
}
