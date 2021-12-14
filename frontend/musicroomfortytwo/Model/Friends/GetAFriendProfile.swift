//
//  GetAFriendProfile.swift
//  musicroomfortytwo
//
//  Created by ML on 11/02/2021.
//

import Foundation

struct FriendProfileResult: Decodable {
    let targetUser: TargetUser
}

struct TargetUser: Decodable {
    let _id: String?
    let userInfo: FriendUserInfo
    let userData: FriendUserData
}

struct FriendUserInfo: Decodable {
    let firstName: String?
    let lastName: String?
    let pseudo: String
    let musicalPreferences: [String]
}

struct FriendUserData: Decodable {
    let friendsId: [FriendFriendsIds]?
    let playlists: [FriendPlaylistObject]
    let events: [FriendEvents]
}

struct FriendFriendsIds: Decodable {
    let _id: String
    let userInfo: FriendUserInfo2
}

struct FriendUserInfo2: Decodable {
    let pseudo: String
}

struct FriendPlaylistObject: Decodable {
    let playlist: FriendPlaylist
}

struct FriendPlaylist: Decodable {
    let `public`: Bool
    let _id: String
    let name: String
}

struct FriendEvents: Decodable {
    let eventsId: EventsId
}

struct EventsId: Decodable {
    let publicFlag: Bool
    let _id: String
    let name: String
}

struct FriendProfileObject {
    var pseudo: String?
    var userId: String?
    var firstName: String?
    var lastName: String?
    var musicalPreferences: [String]?
    var friends: [String]?
    var playlist: [PlaylistsOfTheUser]?
    var events: [EventsOfTheUser]?
}

struct PlaylistsOfTheUser {
    let id: String
    let name: String
}


struct EventsOfTheUser {
    let id: String
    let name: String
}


class GetAFriendProfile {
    
    static let shared = GetAFriendProfile()
    private init() {}
    private var task: URLSessionTask?
    var friendProfileObject = FriendProfileObject()

    
    func getAFriendProfile(friendId: String, callback: @escaping (Int) -> Void) {
        let route = UserDefaults.standard.string(forKey: "route")!
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let url = URL(string: route + "/users/" + userId + "/targetUser/" + friendId)!
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
                    return
                }
                let _ = (response as? HTTPURLResponse)?.statusCode
                do {
                    _ = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    let decoder = JSONDecoder()
                    let userFriends = try decoder.decode(FriendProfileResult.self, from: data)
                    self.buildFriendObject(friendResult: userFriends, friendId: friendId)
                    callback(1)
                    return

                } catch let parsingError {
                    print("Error", parsingError)
                    callback(0)
                    return
                }
             }
         }
         task?.resume()
    }
    
    func buildFriendObject(friendResult: FriendProfileResult, friendId: String) {
        var friend = FriendProfileObject(musicalPreferences: [])
        
        friend.firstName = friendResult.targetUser.userInfo.firstName
        friend.lastName = friendResult.targetUser.userInfo.lastName
        friend.pseudo = friendResult.targetUser.userInfo.pseudo
        friend.musicalPreferences = friendResult.targetUser.userInfo.musicalPreferences
        friend.userId = friendId
        
        // playlist
        var playlist: [PlaylistsOfTheUser] = []
        let playlistNumber = friendResult.targetUser.userData.playlists.count
        if playlistNumber > 0 {
            for i in 0...(playlistNumber - 1) {
                let newElem = PlaylistsOfTheUser(id: friendResult.targetUser.userData.playlists[i].playlist._id, name: friendResult.targetUser.userData.playlists[i].playlist.name)
                playlist.append(newElem)
            }
        }
        friend.playlist = playlist
                
        // events
        var events: [EventsOfTheUser] = []
        let eventNumber = friendResult.targetUser.userData.events.count
        if eventNumber > 0 {
            for i in 0...(eventNumber - 1) {
                let newElem = EventsOfTheUser(id: friendResult.targetUser.userData.events[i].eventsId._id, name: friendResult.targetUser.userData.events[i].eventsId.name)
                events.append(newElem)
            }
        }
        friend.events = events
        
        self.friendProfileObject = friend
    }
    
    func printFriendObject(/*friend: FriendProfileObject*/) {
        let friend = self.friendProfileObject
        print("On print un ami")
        print("prénom : ", friend.firstName!, " nom : ", friend.lastName!, " pseudo: ", friend.pseudo!)
        print("préférences musicales : ", friend.musicalPreferences!)
        
        // print playlist
        let count = friend.playlist?.count
        if count! > 0 {
            for i in 0...(count! - 1) {
                print("playlist ", String(i + 1), " ", friend.playlist![i].name)
            }
        }
        
        // print event
        let eventCount = friend.events?.count
        if eventCount! > 0 {
            for i in 0...(eventCount! - 1) {
                print("event ", String(i + 1), " ", friend.events![i].name)
            }
        }
    }
}
