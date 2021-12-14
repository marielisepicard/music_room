//
//  SocketIOManager.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 09/03/2021.
//

import Foundation
import SocketIO

final class SocketIOManager {
    static let shared = SocketIOManager()
    private var manager: SocketManager?
    private var socket: SocketIOClient?
    var kHost: String?
    let kConnectUser = "connectUser"
    let kUserList = "userList"
    let kExitUser = "exitUser"
    var receivedMsg: String?
    
    private init() {
        setSocketServer()
    }
    func setSocketServer() {
        print("SocketIO: Configuring socketIO...")
        kHost = UserDefaults.standard.string(forKey: "socketServer") ?? "http://62.34.5.191:45559"
        print(kHost)
        guard let url = URL(string: kHost!) else {
            return
        }
        manager = SocketManager(socketURL: url, config: [.log(false), .compress])
        guard let manager = manager else {
            return
        }
        socket = manager.defaultSocket
        handleSocketEvent(socket: socket!)
        handleSocketPlaylist(socket: socket!)
        handleSocketControlDelegation(socket: socket!)
    }
    func establishConnection() {
        guard let socket = manager?.defaultSocket else {
            return
        }
        print("SocketIO: Try to establish connection...")
        socket.connect()
    }
    func closeConnection() {
        print("SocketIO: Closing room connection")
        guard let socket = manager?.defaultSocket else {
            return
        }
        socket.disconnect()
    }
    func joinRoom(roomId: String) {
        print("SocketIO: Try to join room...")
        socket?.emitWithAck("joinRoom", roomId).timingOut(after: 1) {data in
            if let response = data[0] as? String {
                if response == "OK" {
                    print("SocketIO: Room successfully joined")
                } else {
                    print("SocketIO: Error when trying to join room")
                }
            }
        }
    }
    func leaveRoom(roomId: String) {
        print("SocketIO: Try to leave room...")
        socket?.emitWithAck("leaveRoom", roomId).timingOut(after: 1) {data in
            if let response = data[0] as? String {
                if response == "OK" {
                    print("SocketIO: Room successfully leaved")
                } else {
                    print("SocketIO: Error when trying to leave room")
                }
            }
        }
    }
    func sendMsg(userId: String, userPseudo: String, friendId: String, message: String) {
        guard let socket = manager?.defaultSocket else {
            return
        }
        socket.emit("sendMsg", ["ownerId": userId, "ownerPseudo": userPseudo, "recipientId": friendId, "content": message])
    }
    private func handleSocketEvent(socket: SocketIOClient) {
        socket.onAny() {data in
        }
        socket.on(clientEvent: .connect) {data, ack in
            var roomControlDelegation: RoomControlDelegation!
            print("SocketIO: socket connected")
            if let userId = UserDefaults.standard.string(forKey: "userId") {
                self.joinRoom(roomId: userId)
            }
            
            if let data = UserDefaults.standard.value(forKey:"roomControlDelegation") as? Data {
                roomControlDelegation = try? PropertyListDecoder().decode(RoomControlDelegation.self, from: data)
            }
            if (roomControlDelegation != nil) {
                self.joinRoom(roomId: roomControlDelegation.roomId)
            }
        }
        socket.on("refreshUserEventData") {data, ack in
            print("SocketIO: refreshUserEventData socketEvent received!")
            let name = Notification.Name(rawValue: "refreshUserEventsData")
            let notification = Notification(name: name)
            NotificationCenter.default.post(notification)
        }
        socket.on("refreshSpecificEventData") {data, ack in
            print("SocketIO: refreshSpecificEventData socketEvent received!")
            let name = Notification.Name(rawValue: "refreshSpecificEventData")
            let notification = Notification(name: name)
            NotificationCenter.default.post(notification)
        }
        socket.on("receiveMsg") {data, ack in
            print("SocketIO: receiveMsg event received!");
            guard let msgObj = data[0] as? [String: Any] else { return }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "receiveMsg"), object: nil, userInfo: msgObj)
        }
        
        socket.on("refreshSpecificPlaylist") {data, ack in
            print("SocketIO: refreshSpecificPlaylist socketPlaylist received!")
            let name = Notification.Name(rawValue: "refreshSpecificPlaylist")
            let notification = Notification(name: name)
            NotificationCenter.default.post(notification)
        }
        
    }
    
    //-------------------------------//
    //---------- Playlists ----------//
    //-------------------------------//
    
    private func handleSocketPlaylist(socket: SocketIOClient) {
        socket.on("refreshSpecificPlaylist") {data, ack in
            print("SocketIO: refreshSpecificPlaylist socketPlaylist received!")
            let name = Notification.Name(rawValue: "refreshSpecificPlaylist")
            let notification = Notification(name: name)
            NotificationCenter.default.post(notification)
        }
    }
    
    
    //-------------------------------//
    //----- CONTROL DELEGATION ------//
    //-------------------------------//
    
    
    // ROOM CONTROL DELEGATION
    
    func controlDelegInviteFriend(friendId: String, friendPseudo: String, pseudo: String, userId: String, roomId: String, roomFriendsId: [String], roomFriendsPseudo: [String]) {
        guard let socket = manager?.defaultSocket else {
            return
        }
        socket.emit("controlDelegInviteFriend", ["friendId": friendId, "friendPseudo": friendPseudo, "pseudo": pseudo, "userId": userId, "roomId": roomId, "roomFriendsId": roomFriendsId, "roomFriendsPseudo": roomFriendsPseudo])
    }
    
    func controlDelegJoinRoom(roomId: String, friendPseudo: String, friendId: String, roomFriendsId: [String], roomFriendsPseudo: [String], userId: String) {
        guard let socket = manager?.defaultSocket else {
            return
        }
        socket.emit("controlDelegJoinRoom", ["roomId": roomId, "friendPseudo": friendPseudo, "friendId": friendId, "roomFriendsId": roomFriendsId, "roomFriendsPseudo": roomFriendsPseudo, "userId": userId])
    }
    
    func controlDelegLeaveRoom(friendId: String, roomId: String) {
        guard let socket = manager?.defaultSocket else {
            return
        }
        socket.emit("controlDelegLeaveRoom", ["friendId": friendId, "roomId": roomId])
    }
    
    
    private func handleSocketControlDelegation(socket: SocketIOClient) {
        socket.on("controlDelegInviteFriend") {data, ack in
            guard let roomData = data[0] as? [String: Any] else { return }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "controlDelegInvitation"), object: nil, userInfo: roomData)
        }
        socket.on("controlDelegJoinRoom") {data, ack in
            guard let roomData = data[0] as? [String: Any] else { return }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "controlDelegJoinRoom"), object: nil, userInfo: roomData)
        }
        socket.on("controlDelegLeaveRoom") {data, ack in
            guard let roomData = data[0] as? [String: Any] else { return }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "controlDelegLeaveRoom"), object: nil, userInfo: roomData)
        }
        socket.on("controlDelegInitPlayer") {data, ack in
            guard let roomData = data[0] as? [String: Any] else { return }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "controlDelegInitPlayer"), object: nil, userInfo: roomData)
        }
    }
    
    // PLAYER CONTROL DELEGATION
    
    func controlDelegInitPlayer(roomId: String, userId: String, tracks: [String], unshuffledTracks: [String], index: Int, readingListContext: String, position: Int, isShuffling: Bool, isPlaying: Bool) {
        guard let socket = manager?.defaultSocket else {
            return
        }
        socket.emit("controlDelegInitPlayer", ["roomId": roomId, "userId": userId, "tracks": tracks, "unshuffledTracks": unshuffledTracks, "index": index, "readingListContext": readingListContext, "position": position, "isShuffling": isShuffling, "isPlaying": isPlaying])
    }
    

}
