//
//  DisplayFriendProfileViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 11/02/2021.
//

import UIKit

class DisplayFriendProfileViewController: UIViewController {
    
    @IBOutlet weak var playlistButton: UIButton!
    
    @IBOutlet weak var eventButton: UIButton!
    @IBOutlet weak var friendPseudo: UILabel!
    @IBOutlet weak var friendFirstName: UILabel!
    @IBOutlet weak var friendLastName: UILabel!
    @IBOutlet weak var musicalPreferencesTableview: UITableView!
    @IBOutlet weak var privateView: UIView!
    
    var friend = FriendProfileObject()
    
    var musicalPreference: [String] = []
    var playlistsNumber = 0
    var eventsNumber = 0
    
    var userId: String = ""
    var friendId: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userId = UserDefaults.standard.string(forKey: "userId")!
        friendId = UserDefaults.standard.string(forKey: "friendId")!
        self.view.subviews.forEach { $0.isHidden = true }
        GetAFriendProfile.shared.getAFriendProfile(friendId: friendId) { (success) in
            if success == 1 {
                UIView.transition(with: self.view, duration: 0.35, options: .transitionCrossDissolve, animations: self.displayProfile)
            } else {
            }
        }
    }
    func displayProfile() {
        self.view.subviews.forEach { $0.isHidden = false }
        self.friend = GetAFriendProfile.shared.friendProfileObject
        self.fillFriendProfile()
        self.musicalPreference = GetAFriendProfile.shared.friendProfileObject.musicalPreferences!
        self.musicalPreferencesTableview.reloadData()
        self.playlistsNumber = GetAFriendProfile.shared.friendProfileObject.playlist!.count
        self.playlistButton.setTitle(String(self.playlistsNumber) + " Playlists", for: .normal)
        self.eventsNumber = GetAFriendProfile.shared.friendProfileObject.events!.count
        self.eventButton.setTitle(String(self.eventsNumber) + " Evenements", for: .normal)
    }
    func fillFriendProfile() {
        self.friendPseudo.text = friend.pseudo
        if friend.firstName == nil || friend.lastName == nil {
            privateView.removeFromSuperview()
        } else {
            self.friendFirstName.text = friend.firstName
            self.friendLastName.text = friend.lastName
        }
    }
}

extension DisplayFriendProfileViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.musicalPreference.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = musicalPreferencesTableview.dequeueReusableCell(withIdentifier: "FriendMusicalPreferences", for: indexPath)
        cell.textLabel?.text = self.musicalPreference[indexPath.row]
        return cell
    }
}
