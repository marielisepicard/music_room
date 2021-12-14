//
//  TabBarViewController.swift
//  musicroomfortytwo
//
//  Created by Jerome on 19/02/2021.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    var timer = Timer()
    var player = PlayerDetailsViewController()
    @IBOutlet var playerView: PlayerView!
    @IBOutlet var openPlayerButton: UIView!
    var notif = false
    
    var roomControlDelegation: RoomControlDelegation!
    
    
    override func viewDidLoad() {             // Use for the app's interface
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(displayPlayerDetails(sender:)))
        self.playerView.addGestureRecognizer(tapGesture)
        playerView.openButton = openPlayerButton
        openPlayerButton.isHidden = true
        playerView.isHidden = true
        scheduledTimerWithTimeInterval()
        
        //Control delegation
        var notifName = Notification.Name(rawValue: "controlDelegInvitation")
        NotificationCenter.default.addObserver(self, selector: #selector(invitationInRoom), name: notifName, object: nil)
        notifName = Notification.Name(rawValue: "controlDelegJoinRoom")
        NotificationCenter.default.addObserver(self, selector: #selector(joinRoom), name: notifName, object: nil)
        notifName = Notification.Name(rawValue: "controlDelegLeaveRoom")
        NotificationCenter.default.addObserver(self, selector: #selector(deleteUserInRoom), name: notifName, object: nil)
        notifName = Notification.Name(rawValue: "controlDelegInitPlayer")
        NotificationCenter.default.addObserver(self, selector: #selector(initPlayerControlDeleg), name: notifName, object: nil)
    }

    func scheduledTimerWithTimeInterval(){
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.playerConnect), userInfo: nil, repeats: true)
    }
    
    @objc func playerConnect(){
        if (playerView.appRemote.connectionParameters.accessToken != nil && !playerView.appRemote.isConnected) {
            playerView.appRemote.connect()
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        self.view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        let leftConstraint = NSLayoutConstraint(item: playerView!, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: playerView!, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: playerView!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottomMargin, multiplier: 1, constant: -49)
        let heightConstraint = NSLayoutConstraint(item: playerView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 60)
        view.addConstraints([leftConstraint, rightConstraint, bottomConstraint, heightConstraint])
        
        self.view.addSubview(openPlayerButton)
        openPlayerButton.translatesAutoresizingMaskIntoConstraints = false
        let centerXConstraintButton = NSLayoutConstraint(item: openPlayerButton!, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let bottomConstraintButton = NSLayoutConstraint(item: openPlayerButton!, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: NSLayoutConstraint.Relation.equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottomMargin, multiplier: 1, constant: -50)
        let heightConstraintButton = NSLayoutConstraint(item: openPlayerButton!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 18)
        let widthConstraintButton = NSLayoutConstraint(item: openPlayerButton!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: 40)
        view.addConstraints([centerXConstraintButton, bottomConstraintButton, heightConstraintButton, widthConstraintButton])
    }
    
    
    @objc func displayPlayerDetails(sender: UITapGestureRecognizer) {
        performSegue(withIdentifier: "ShowPlayerDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPlayerDetails" {
            let targetController = segue.destination as! PlayerDetailsViewController
            self.playerView.playerDetails = targetController as PlayerDetailsViewController
            targetController.playerView = self.playerView
        }
    }
    
    @IBAction func openPlayer(_ sender: Any) {
        playerView.isHidden = false
        openPlayerButton.isHidden = true
        UIView.transition(with: self.playerView, duration: 0.2, options: .transitionCrossDissolve, animations: nil)
    }
}


//---------------------------------//
//------- Control Delegation ------//
//---------------------------------//

extension TabBarViewController {
    
    @objc func invitationInRoom(_ notification: NSNotification) {
        let friendId = notification.userInfo!["friendId"] as! String
        let friendPseudo = notification.userInfo!["friendPseudo"] as! String
        let pseudo = notification.userInfo!["pseudo"] as! String
        let userId = notification.userInfo?["userId"] as! String
        let roomId = notification.userInfo!["roomId"] as! String
        let roomFriendsId = notification.userInfo!["roomFriendsId"] as! [String]
        let roomFriendsPseudo = notification.userInfo!["roomFriendsPseudo"] as! [String]
        let alertVC: UIAlertController
        alertVC = UIAlertController(title: title, message: "Voulez-vous rejoindre le salon de partage de " + pseudo + "?", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Oui", style: UIAlertAction.Style.default, handler: {action in
            if let data = UserDefaults.standard.value(forKey:"roomControlDelegation") as? Data {
                self.roomControlDelegation = try? PropertyListDecoder().decode(RoomControlDelegation.self, from: data)
            }
            if (self.roomControlDelegation != nil) {
                SocketIOManager.shared.controlDelegLeaveRoom(friendId: friendId, roomId: self.roomControlDelegation.roomId)
            }
            SocketIOManager.shared.controlDelegJoinRoom(roomId: roomId, friendPseudo: friendPseudo, friendId: friendId, roomFriendsId: roomFriendsId, roomFriendsPseudo: roomFriendsPseudo, userId: userId)
            self.notif = false
        }))
        alertVC.addAction(UIAlertAction(title: "Non", style: UIAlertAction.Style.default, handler: {action in
            self.notif = false
        }))
        if let topVC = UIApplication.getTopViewController() {
            if (notif == false) {
                topVC.present(alertVC, animated: true, completion: nil)
                notif = true
            }
        }
        
    }
    
    @objc func joinRoom(_ notification: NSNotification) {
        let friendId = notification.userInfo?["friendId"] as! String
        let friendPseudo = notification.userInfo?["friendPseudo"] as! String
        let userId = notification.userInfo?["userId"] as! String
        let roomId = notification.userInfo?["roomId"] as! String
        let roomFriendsId = notification.userInfo?["roomFriendsId"] as! [String]
        let roomFriendsPseudo = notification.userInfo?["roomFriendsPseudo"] as! [String]
        var alreadyInRoom = false
        var updateRoom = false
        if let data = UserDefaults.standard.value(forKey:"roomControlDelegation") as? Data {
            roomControlDelegation = try? PropertyListDecoder().decode(RoomControlDelegation.self, from: data)
        }
        if (friendId == UserDefaults.standard.value(forKey:"userId") as! String) {
            if (roomControlDelegation.roomId != roomId) {
                updateRoom = true
                roomControlDelegation.roomId = roomId
                for i in 0...roomFriendsId.count - 1 {
                    roomControlDelegation.friendsList.append(FriendsListControlDelegation.init(friendId: roomFriendsId[i], friendPseudo: roomFriendsPseudo[i]))
                }
            }
        } else {
            for i in 0...roomControlDelegation.friendsList.count - 1 {
                if friendId == roomControlDelegation.friendsList[i]!.friendId {
                    alreadyInRoom = true
                    break
                }
            }
            if (alreadyInRoom == false) {
                updateRoom = true
                roomControlDelegation.friendsList.append(FriendsListControlDelegation.init(friendId: friendId, friendPseudo: friendPseudo))
            }
            if (userId == UserDefaults.standard.value(forKey:"userId") as! String) {
                playerView.appRemote.playerAPI?.getPlayerState({ (playerState, error) in
                    if let error = error {
                        print(error as NSError)
                    } else if let playerState = playerState as? SPTAppRemotePlayerState {
                        SocketIOManager.shared.controlDelegInitPlayer(roomId: friendId, userId: userId, tracks: self.playerView.tracks, unshuffledTracks: self.playerView.unshuffledTracks, index: self.playerView.index, readingListContext: self.playerView.readingListContext, position: playerState.playbackPosition, isShuffling: self.playerView.isShuffling, isPlaying: !playerState.isPaused)
                    }
                })
            }
        }
        if (updateRoom == true) {
            self.updateUserDefaults(roomControlDelegation: roomControlDelegation)
            if let topVC = UIApplication.getTopViewController() as? ControlDelegationViewController {
                topVC.roomControlDelegation = roomControlDelegation
                UIView.transition(with: topVC.roomTableView, duration: 0.35, options: .transitionCrossDissolve, animations: topVC.roomTableView.reloadData)
            }
        }
    }
    
    @objc func deleteUserInRoom(_ notification: NSNotification) {
        let friendId = notification.userInfo?["friendId"] as! String
        if (friendId == UserDefaults.standard.string(forKey: "userId")) {
            if let data = UserDefaults.standard.value(forKey:"roomControlDelegation") as? Data {
                roomControlDelegation = try? PropertyListDecoder().decode(RoomControlDelegation.self, from: data)
            }
            SocketIOManager.shared.leaveRoom(roomId: roomControlDelegation.roomId)
            roomControlDelegation.roomId = ""
            if (roomControlDelegation.friendsList[0] != nil) {
                roomControlDelegation.friendsList = [roomControlDelegation.friendsList[0]]
            }
        } else {
            if let data = UserDefaults.standard.value(forKey:"roomControlDelegation") as? Data {
                roomControlDelegation = try? PropertyListDecoder().decode(RoomControlDelegation.self, from: data)
            }
            if (roomControlDelegation != nil && roomControlDelegation != nil && roomControlDelegation.friendsList.count > 1) {
                for i in 0...roomControlDelegation.friendsList.count - 1 {
                    if (roomControlDelegation.friendsList[i]?.friendId == friendId) {
                        roomControlDelegation.friendsList.remove(at: i)
                        break
                    }
                }
            }
        }
        if (roomControlDelegation != nil) {
            updateUserDefaults(roomControlDelegation: roomControlDelegation)
            if let topVC = UIApplication.getTopViewController() as? ControlDelegationViewController {
                topVC.roomControlDelegation = roomControlDelegation
                UIView.transition(with: topVC.roomTableView, duration: 0.35, options: .transitionCrossDissolve, animations: topVC.roomTableView.reloadData)
            }
        }
    }
    
    func updateUserDefaults(roomControlDelegation: RoomControlDelegation) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(roomControlDelegation), forKey:"roomControlDelegation")
    }
    
    
    
    // PLAYER CONTROL DELEG
    @objc func initPlayerControlDeleg(_ notification: NSNotification) {
        let userId = notification.userInfo!["userId"] as! String
        let tracks = notification.userInfo!["tracks"] as! [String]
        let unshuffledTracks = notification.userInfo!["unshuffledTracks"] as! [String]
        let index = notification.userInfo!["index"] as! Int
        let readingListContext = notification.userInfo!["readingListContext"] as! String
        let position = notification.userInfo!["position"] as! Int
        let isShuffling = notification.userInfo!["isShuffling"] as! Bool
        let isPlaying = notification.userInfo!["isPlaying"] as! Bool
        
        if (userId != UserDefaults.standard.value(forKey:"userId") as! String) {
            playerView.controlDelegPlayer(tracks: tracks, unshuffledTracks: unshuffledTracks, index: index, readingListContext: readingListContext, position: position, isShuffling: isShuffling, isPlaying: isPlaying)
        }
    }
}


// MARK: UIApplication extensions

extension UIApplication {

    class func getTopViewController(base: UIViewController? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first!.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}


