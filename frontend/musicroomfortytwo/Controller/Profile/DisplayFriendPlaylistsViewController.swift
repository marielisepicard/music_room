//
//  DisplayFriendPlaylistsViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 13/02/2021.
//

import UIKit

class DisplayFriendPlaylistsViewController: UIViewController, UITableViewDataSource, FriendsPlaylistDelegator {

    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DisplayFriendPlaylist" {
         _ = segue.destination as! ShowPlaylistViewController
        }
    }
   
    func displayFriendPlaylist(playlistId: String, playlistTitle: String) {
        UserDefaults.standard.setValue(playlistId, forKey: "idOfSelectedPlaylist")
        UserDefaults.standard.setValue(playlistTitle, forKey: "titleOfSelectedPlaylist")
        performSegue(withIdentifier: "DisplayFriendPlaylist", sender: self)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GetAFriendProfile.shared.friendProfileObject.playlist?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendPlaylists") as? FriendPlaylistsTableViewCell else {
            return UITableViewCell()
        }
        cell.playlistTitle.text = GetAFriendProfile.shared.friendProfileObject.playlist?[indexPath.row].name
        cell.playlistId.text = GetAFriendProfile.shared.friendProfileObject.playlist?[indexPath.row].id
        cell.delegate = self
        return cell
    }
}
