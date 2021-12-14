//
//  ControlDelegationViewController.swift
//  musicroomfortytwo
//
//  Created by Jerome on 15/04/2021.
//

import UIKit

struct RoomControlDelegation: Codable {
    var roomId: String
    var friendsList: [FriendsListControlDelegation?]
}

struct FriendsListControlDelegation: Codable {
    var friendId: String
    var friendPseudo: String
}

class ControlDelegationViewController: UIViewController {

    @IBOutlet weak var roomTableView: UITableView!
    @IBOutlet weak var friendsTableView: UITableView!
    @IBOutlet weak var friendsSearchView: UIView!
    @IBOutlet weak var friendsSearchField: UITextField!
    
    var friendsList: [FriendsList] = []
    var roomControlDelegation: RoomControlDelegation!
    var vc: PlayerDetailsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.friendsSearchView.layer.cornerRadius = 10
        self.friendsSearchView.layer.borderWidth = 2
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
        self.friendsSearchView.layer.borderColor = UIColor(red:28/255, green:20/255, blue:88/255, alpha: 1).cgColor
        loadFriendList()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let data = UserDefaults.standard.value(forKey:"roomControlDelegation") as? Data {
            roomControlDelegation = try? PropertyListDecoder().decode(RoomControlDelegation.self, from: data)
        }
    }

    
    func loadFriendList() {
        SearchFriends.shared.getUserFriends(value: friendsSearchField.text!) { (success, friendsList) in
            self.friendsList = friendsList!
            UIView.transition(with: self.friendsTableView, duration: 0.35, options: .transitionCrossDissolve, animations: self.friendsTableView.reloadData)
        }
    }
    
    func dismissWhenPlayerIsOff() {
        self.vc = self.presentingViewController as? PlayerDetailsViewController
        self.dismiss(animated: true, completion: nil)
        self.vc.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func updateFriendsList(_ sender: Any) {
        loadFriendList()
    }
    
    @objc func handleTap() {
        friendsSearchField.resignFirstResponder()
    }

    func updateUserDefaults(roomControlDelegation: RoomControlDelegation) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(roomControlDelegation), forKey:"roomControlDelegation")
    }
}


extension ControlDelegationViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == friendsTableView) {
            return friendsList.count
        } else if (tableView == roomTableView) {
            return roomControlDelegation.friendsList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == friendsTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "controlDelegationFriendsTableViewCell") as! controlDelegationFriendsTableViewCell
            let friend = friendsList[indexPath.row]
            cell.friendId = friend._id
            cell.friendPseudo = friend.pseudo
            cell.lblPseudo.text = friend.pseudo
            cell.vc = self
            return cell
        } else if (tableView == roomTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "controlDelegationRoomTableViewCell") as! controlDelegationRoomTableViewCell
            let friend = roomControlDelegation.friendsList[indexPath.row]
            cell.friendId = friend!.friendId
            if (friend!.friendId == UserDefaults.standard.string(forKey: "userId")) {
                cell.lblPseudo.text = friend!.friendPseudo + " (vous)"
            } else {
                cell.lblPseudo.text = friend!.friendPseudo
            }
            cell.index = indexPath.row
            cell.vc = self
            return cell
        }
        return UITableViewCell()
    }
}



class controlDelegationRoomTableViewCell: UITableViewCell {
   
    
    @IBOutlet weak var lblPseudo: UILabel!
    
    var friendId = String()
    var index = Int()
    var vc: ControlDelegationViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func btnLeaveRoom(_ sender: Any) {
        SocketIOManager.shared.controlDelegLeaveRoom(friendId: friendId, roomId: vc!.roomControlDelegation.roomId)
    }
}


class controlDelegationFriendsTableViewCell: UITableViewCell {
   
    
    @IBOutlet weak var lblPseudo: UILabel!
    @IBOutlet weak var btnAddFriend: UIButton!
    
    var friendId = String()
    var friendPseudo = String()
    var vc: ControlDelegationViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
 
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func addFriendToRoom(_ sender: Any) {
        btnAddFriend.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        var alreadyInRoom = false
        var roomFriendsId = [String]()
        var roomFriendsPseudo = [String]()
        for i in 0...vc!.roomControlDelegation.friendsList.count - 1 {
            roomFriendsId.append(vc!.roomControlDelegation.friendsList[i]!.friendId)
            roomFriendsPseudo.append(vc!.roomControlDelegation.friendsList[i]!.friendPseudo)
            if friendId == vc!.roomControlDelegation.friendsList[i]!.friendId {
                alreadyInRoom = true
                break
            }
        }
        
        if (vc!.roomControlDelegation.roomId == "") {
            vc!.roomControlDelegation.roomId = randomString(length: 12)
            vc!.updateUserDefaults(roomControlDelegation: vc!.roomControlDelegation)
            SocketIOManager.shared.joinRoom(roomId: vc!.roomControlDelegation.roomId)
        }
        
        if (alreadyInRoom == false) {
            SocketIOManager.shared.controlDelegInviteFriend(friendId: friendId, friendPseudo: friendPseudo, pseudo: UserDefaults.standard.value(forKey:"userPseudo") as! String, userId: UserDefaults.standard.value(forKey:"userId") as! String, roomId: vc!.roomControlDelegation.roomId, roomFriendsId: roomFriendsId, roomFriendsPseudo: roomFriendsPseudo)
        }
    }
    
    func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
}
