//
//  SpotifyToken.swift
//  musicroomfortytwo
//
//  Created by ML on 31/01/2021.
//

import Foundation

class SpotifyToken {
    
    struct SpotifyTokenObject: Codable {
        var access_token: String
        var token_type: String
        var expires_in: Int
        var scope: String?
    }
    
    static let shared = SpotifyToken()
    private init() {}
    
    private let url = URL(string: "https://accounts.spotify.com/api/token")!
    private var task: URLSessionDataTask?

    func getSpotifyToken() {
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let stringAccess = "39c09e90077544a7a6d71a0fbf058a25:037820b7577c4f2ca3b2f1fecd517511"
        let base64Access = stringAccess.toBase64()
        let body = "grant_type=client_credentials"
        request.httpBody = body.data(using: .utf8)
        request.setValue("Basic " + base64Access, forHTTPHeaderField: "Authorization")
        let session = URLSession(configuration: .default)
        task?.cancel()
        task = session.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                (200 ..< 300) ~= response.statusCode,
                error == nil else {
                    return
            }
            DispatchQueue.main.async {
                let decoder = JSONDecoder()
                let spotifyObject = try? decoder.decode(SpotifyTokenObject.self, from: data)
                let token = spotifyObject?.access_token ?? ""
                UserDefaults.standard.setValue(token, forKey: "spotifyToken")
            }
        }
        task?.resume()
    }
}
