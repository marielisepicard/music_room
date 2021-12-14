//
//  PendingEventPlaylistInvitationsViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 15/02/2021.
//

import UIKit

class NotificationsViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    var mappingSection = [Int()]
    var nameSections = ["Invitations d'amis",
                        "Invitations à des playlists",
                        "Invitations à des évènements"]
    var nbrSections = 0
    
    var loadedSections = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNotifications()
    }
    
    func loadNotifications() {
        loadedSections = 0
        loadFriendsInvitations()
        loadPlaylistsInvitations()
        loadEventsInvitations()
    }
    
    func loadFriendsInvitations() {
        GetUserPendingInvitations.shared.getUserPendingInvitations() { (success) in
            self.loadedSections+=1
            if (self.loadedSections == 3) {
                UIView.transition(with: self.tableview, duration: 0.35, options: .transitionCrossDissolve, animations: { self.tableview.reloadData() })
            }
        }
    }
    
    func loadPlaylistsInvitations() {
        GetPlaylistInvitations.shared.getPlaylistInvitations() { (success) in
            self.loadedSections+=1
            if (self.loadedSections == 3) {
                UIView.transition(with: self.tableview, duration: 0.35, options: .transitionCrossDissolve, animations: { self.tableview.reloadData() })
            }
        }
    }
    
    func loadEventsInvitations() {
        GetEventInvitations.shared.getEventInvitations() { (success) in
            self.loadedSections+=1
            if (self.loadedSections == 3) {
                UIView.transition(with: self.tableview, duration: 0.35, options: .transitionCrossDissolve, animations: { self.tableview.reloadData() })
            }
        }
    }
    
    func popupAcceptInvitation() {
        let alertVC: UIAlertController
        alertVC = UIAlertController(title: "Invitation acceptée", message: "", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    func popupRefuseInvitation() {
        let alertVC: UIAlertController
        alertVC = UIAlertController(title: "Invitation refusée", message: "", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}


extension NotificationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func prepareSection() {
        nbrSections = 0
        mappingSection.removeAll()
        if (GetUserPendingInvitations.shared.pendingInvitationsResult.count > 0) {
            nbrSections += 1
            mappingSection.append(0)
        }
        if (GetPlaylistInvitations.shared.playlistInvitationsResult.count > 0) {
            nbrSections += 1
            mappingSection.append(1)
        }
        if (GetEventInvitations.shared.eventInvitationsResult.count > 0) {
            nbrSections += 1
            mappingSection.append(2)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        prepareSection()
        return nbrSections
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nameSections[mappingSection[section]]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.white
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = #colorLiteral(red: 0.1272085607, green: 0.0007708931807, blue: 0.3564728498, alpha: 1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (mappingSection[section] == 0) {
            return GetUserPendingInvitations.shared.pendingInvitationsResult.count
        } else if (mappingSection[section] == 1) {
            return GetPlaylistInvitations.shared.playlistInvitationsResult.count
        } else if (mappingSection[section] == 2) {
            return GetEventInvitations.shared.eventInvitationsResult.count
        }
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (mappingSection[indexPath.section] == 0) {
            return friendSection(tableView, cellForRowAt: indexPath)
        } else if (mappingSection[indexPath.section] == 1) {
            return playlistSection(tableView, cellForRowAt: indexPath)
        } else if (mappingSection[indexPath.section] == 2) {
            return eventSection(tableView, cellForRowAt: indexPath)
        }
        return UITableViewCell()
    }
    
    func friendSection(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendNotifCellTableViewCell") as? NotifFriendsTableViewCell else {
            return UITableViewCell()
        }
        let friend = GetUserPendingInvitations.shared.pendingInvitationsResult[indexPath.row]
        cell.vc = self
        cell.lblPseudo.text = friend.pseudo
        cell.friendId = friend.userId
        return cell
    }
    
    func playlistSection(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistNotifCellTableViewCell") as? NotifPlaylistsTableViewCell else {
            return UITableViewCell()
        }
        let playlist = GetPlaylistInvitations.shared.playlistInvitationsResult[indexPath.row]
        cell.vc = self
        cell.lblPlaylist.text = playlist.playlistName
        cell.lblFriend.text = "Invitation de " + playlist.friendPseudo
        cell.playlistId = playlist.playlistId
        return cell
    }
    
    func eventSection(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventNotifCellTableViewCell") as? NotifEventsTableViewCell else {
            return UITableViewCell()
        }
        let event = GetEventInvitations.shared.eventInvitationsResult[indexPath.row]
        cell.vc = self
        cell.lblEvent.text = event.eventName
        cell.lblFriend.text = "Invitation de " + event.friendPseudo
        cell.friendId = event.friendId
        cell.eventId = event.eventId
        return cell
    }
}


extension NotificationsViewController {
    func acceptFriendInvitation(friendId: String) {
        AcceptFriendRequest.shared.acceptFriendRequest(friendId: friendId) { (success) in
            if (success == 1) {
                self.popupAcceptInvitation()
                self.loadNotifications()
            }
        }
    }
    
    func refuseFriendInvitation(friendId: String) {
        RefuseFriendRequest.shared.refuseFriendRequest(friendId: friendId) { (success) in
            if (success == 1) {
                self.popupRefuseInvitation()
                self.loadNotifications()
            }
        }
    }
    
    func acceptPlaylistInvitation(playlistId: String) {
        AcceptPlaylistRequest.shared.acceptPlaylistRequest(playlistId: playlistId) { (success) in
            if (success == 1) {
                self.popupAcceptInvitation()
                self.loadNotifications()
            }
        }
    }
    
    func refusePlaylistInvitation(playlistId: String) {
        RefusePlaylistRequest.shared.refusePlaylistRequest(playlistId: playlistId) { (success) in
            if (success == 1) {
                self.popupRefuseInvitation()
                self.loadNotifications()
            }
        }
    }
    
    func acceptEventInvitation(eventId: String, friendId: String) {
        AcceptEventRequest.shared.acceptEventRequest(eventId: eventId, friendId: friendId) { (success) in
            if (success == 1) {
                self.popupAcceptInvitation()
                self.loadNotifications()
            }
        }
    }
    
    func refuseEventInvitation(eventId: String, friendId: String) {
        RefuseEventRequest.shared.refuseEventRequest(eventId: eventId, friendId: friendId) { (success) in
            if (success == 1) {
                self.popupRefuseInvitation()
                self.loadNotifications()
            }
        }
    }
}



class NotifFriendsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblPseudo: UILabel!
    @IBOutlet weak var cell: UIView!
    
    var friendId = String()
    var vc: NotificationsViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func acceptInvitation(_ sender: Any) {
        vc?.acceptFriendInvitation(friendId: friendId)
    }
    @IBAction func refuseInvitation(_ sender: Any) {
        vc?.refuseFriendInvitation(friendId: friendId)
    }
    
}

class NotifPlaylistsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblPlaylist: UILabel!
    @IBOutlet weak var lblFriend: UILabel!
    @IBOutlet weak var cell: UIView!
    
    
    var playlistId = String()
    var vc: NotificationsViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func acceptInvitation(_ sender: Any) {
        vc?.acceptPlaylistInvitation(playlistId: playlistId)
    }
    
    @IBAction func refuseInvitation(_ sender: Any) {
        vc?.refusePlaylistInvitation(playlistId: playlistId)
    }
    
    
}

class NotifEventsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblEvent: UILabel!
    @IBOutlet weak var lblFriend: UILabel!
    @IBOutlet weak var cell: UIView!
    
    var eventId = String()
    var friendId = String()
    var vc: NotificationsViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func acceptInvitation(_ sender: Any) {
        vc?.acceptEventInvitation(eventId: eventId, friendId: friendId)
    }
    
    @IBAction func refuseInvitation(_ sender: Any) {
        vc?.refuseEventInvitation(eventId: eventId, friendId: friendId)
    }
    
}


