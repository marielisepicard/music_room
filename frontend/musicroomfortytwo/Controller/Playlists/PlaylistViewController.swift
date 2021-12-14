//
//  PlaylistViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 01/02/2021.
//

import UIKit

class PlaylistViewController: UIViewController {
            
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var viewSearchBar: UIView!
    let userPlaylist = GetUserPlaylist()
    
    var mappingSection = [Int()]
    var nameSections = ["Playlists créées", "Playlists associées", "Playlists suivies"]
    var nbrSections = 0
    
    let userId = UserDefaults.standard.string(forKey: "userId")!
    
    var arrayImages = GetSeveralTracks()
    var stringTracks = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let notifName = Notification.Name(rawValue: "refreshUserPlaylistsData")
        NotificationCenter.default.addObserver(self, selector: #selector(refreshPlaylistsData), name: notifName, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        viewSearchBar.layer.cornerRadius = 10
        viewSearchBar.layer.borderWidth = 2
        viewSearchBar.layer.borderColor = UIColor(red:28/255, green:20/255, blue:88/255, alpha: 1).cgColor
        getAllUserPlaylists() // Make the request to get the user playlists
    }

    @objc func refreshPlaylistsData() {
        getAllUserPlaylists()
    }
    func getAllUserPlaylists() {
        userPlaylist.getUserPlaylist() { (success) in
            if success == 1 {
                self.createArrayImages()
                if (self.stringTracks == "") {
                    DispatchQueue.main.async {
                        self.joinAllPlaylistsRoom()
                        self.tableview.reloadData()
                        UIView.transition(with: self.tableview, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
                    }
                } else {
                    self.arrayImages.getSeveralTracks(trackslist: self.stringTracks) { (success) in
                        if (success == true) {
                            DispatchQueue.main.async {
                                self.fillImages()
                                self.joinAllPlaylistsRoom()
                                self.tableview.reloadData()
                                UIView.transition(with: self.tableview, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createArrayImages() {
        stringTracks = ""
        if userPlaylist.userPlaylists.count == 0 {
            return
        }
        for i in 0 ..< 3 {
            for j in 0 ..< userPlaylist.userPlaylists[i].count {
                if (userPlaylist.userPlaylists[i][j].track != "") {
                    if (stringTracks == "") {
                        stringTracks = userPlaylist.userPlaylists[i][j].track
                    } else {
                        stringTracks = stringTracks + "," + userPlaylist.userPlaylists[i][j].track
                    }
                }
            }
        }
    }
    
    func fillImages() {
        var k = 0
        if userPlaylist.userPlaylists.count == 0 {
            return
        }
        for i in 0 ..< 3 {
            for j in 0 ..< userPlaylist.userPlaylists[i].count {
                if (userPlaylist.userPlaylists[i][j].track != "") {
                    userPlaylist.userPlaylists[i][j].trackImage = arrayImages.displayablePlaylist[k].image
                    k += 1
                }
            }
        }
    }
    
    func joinAllPlaylistsRoom() {
        if userPlaylist.userPlaylists.count == 0 {
            return
        }
        for i in 0 ..< 3 {
            for j in 0 ..< userPlaylist.userPlaylists[i].count {
                SocketIOManager.shared.joinRoom(roomId: userPlaylist.userPlaylists[i][j].id)
            }
        }
    }
}

// So that the user can delete cells
extension PlaylistViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let playlistId = userPlaylist.userPlaylists[mappingSection[indexPath.section]][indexPath.row].id
            if (mappingSection[indexPath.section] == 0) {
                DeleteAPlaylist.shared.deleteAPlaylist(playlistId: playlistId) { (success) in
                    if success == true {
                        self.getAllUserPlaylists()
                    } else {
                        self.presentAlert()
                    }
                }
            } else  if (mappingSection[indexPath.section] == 1) {
                RemoveFriendFromPlaylist.shared.removeFriendFromPlaylist(userId: userId, playlistId: playlistId, friendId: userId) { (success) in
                    if (success == true) {
                        self.getAllUserPlaylists()
                    }
                }
            } else  if (mappingSection[indexPath.section] == 2) {
                UnFollowAPlaylist.shared.unfollowAPlaylist(playlistId: playlistId) { (success) in
                    self.getAllUserPlaylists()
                }
            }
            
        }
    }
}

extension PlaylistViewController: UITableViewDataSource {
    
    func prepareSection() {
        mappingSection.removeAll()
        if (userPlaylist.userPlaylists[0].count != 0) {
            nbrSections += 1
            mappingSection.append(0)
        }
        if (userPlaylist.userPlaylists[1].count != 0) {
            nbrSections += 1
            mappingSection.append(1)
        }
        if (userPlaylist.userPlaylists[2].count != 0) {
            nbrSections += 1
            mappingSection.append(2)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        nbrSections = 0
        if (userPlaylist.userPlaylists.count != 0) {
            prepareSection()
        }
        return nbrSections
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nameSections[mappingSection[section]]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userPlaylist.userPlaylists.count == 0 {
            return 0
        }
        return userPlaylist.userPlaylists[mappingSection[section]].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCell") as? DisplayPlaylistTableViewCell else {
            return UITableViewCell()
        }
        let playlist = userPlaylist.userPlaylists[mappingSection[indexPath.section]][indexPath.row]
        cell.playlistTitle.text = playlist.name
        cell.playlistId = playlist.id
        cell.playlistCreator.text = "Par " + playlist.creator
        if (playlist.track != "") {
            cell.playlistImage.image = playlist.trackImage
        } else {
            cell.playlistImage.image = UIImage(named: "defaultThumbnail")
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.white
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = #colorLiteral(red: 0.1272085607, green: 0.0007708931807, blue: 0.3564728498, alpha: 1)
    }
}

extension PlaylistViewController: MyPlaylistListDelegator {
    func callSegueFromPlaylistCell(cell: UITableViewCell) {
        let _ = UserDefaults.standard.string(forKey: "titleOfSelectedPlaylist")
        let _ = UserDefaults.standard.string(forKey: "idOfSelectedPlaylist")
        self.performSegue(withIdentifier: "ShowPlaylistSegue", sender: self)
    }
}

extension PlaylistViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPlaylistSegue" {
            _ = segue.destination as! ShowPlaylistViewController
        }
    }
}

// Alert Message
extension PlaylistViewController {
    
    private func presentAlert() {
        let alertVC: UIAlertController
        let title = "Erreur interne 😢"
        let message = "Nous avons un problème technique... Reviens plus tard !"
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    private func presentAlertEmptySearch() {
        let alertVC: UIAlertController
        let title = "Hep hep hep 🤓"
        let message = "Tape un mot clé si tu veux qu'on cherche une playlist à ton goût😬"
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}
