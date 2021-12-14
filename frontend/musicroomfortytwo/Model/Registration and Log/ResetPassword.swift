//
//  ResetPassword.swift
//  musicroomfortytwo
//
//  Created by Jerome on 12/04/2021.
//

import Foundation

class ResetPassword {
    
    static let shared = ResetPassword()
    private init() {}
    private var task: URLSessionTask?
    
    func resetPassword(mail: String, callback: @escaping (Int) -> Void) {
        let route = UserDefaults.standard.string(forKey: "route")!
        let url = URL(string: route + "/auth/password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let body = "email=" + mail
        request.httpBody = body.data(using: .utf8)
        let session = URLSession(configuration: .default)
        task?.cancel()
        task = session.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                guard let data = data, error == nil else {
                    callback(0)
                    return
                }
                if (try? JSONDecoder().decode([String: String].self, from: data)) != nil {
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            callback(1)
                            return
                        } else if response.statusCode == 400 {
                            callback(2)
                            return
                        } else {
                            callback(0)
                            return
                        }
                    }
                }
            }
        }
        task?.resume()
    }
}
