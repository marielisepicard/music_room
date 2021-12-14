//
//  DeleteUserEvent.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 17/03/2021.
//

import Foundation

extension Event {
    func deleteSpecifiedEvent(callback: @escaping (Bool, Int) -> Void) {
        var task: URLSessionTask?
        let route = UserDefaults.standard.string(forKey: "route")!
        let urlStr = route + "/events/" + self.id!
        let url = URL(string: urlStr)!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
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
                    callback(false, 0)
                    return
                }
                do {
                    let responseJSON = try JSONDecoder().decode([String: String].self, from: data)
                    if let response = response as? HTTPURLResponse {
                        if response.statusCode == 200 {
                            callback(true, 0)
                        } else {
                            callback(false, Int(responseJSON["code"]!)!)
                        }
                    } else {
                        callback(false, 0)
                        return
                    }
                } catch let parsingError {
                    print("Error", parsingError)
                    callback(false, 0)
                }
             }
         }
         task?.resume()
    }
}

