//
//  ShowPlaylistViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 02/02/2021.
//

import UIKit

class ShowPlaylistViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var lblUserStatus: UILabel!
    @IBOutlet weak var lblUserRight: UILabel!
    @IBOutlet weak var lblPlaylistName: UILabel!
    @IBOutlet weak var lblStyleName: UILabel!
    @IBOutlet weak var lblCreator: UILabel!
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var imgCoverPlaylist: UIImageView!
    @IBOutlet weak var btnManageTracks: UIButton!
    @IBOutlet weak var btnShowDetails: UIButton!
    @IBOutlet weak var btnParameters: UIButton!
    @IBOutlet weak var tableview: UITableView!
    
    var allTracks: [String] = []
    var allTracksString: String = ""
    let playlistId = UserDefaults.standard.string(forKey: "idOfSelectedPlaylist")!
    let userId = UserDefaults.standard.string(forKey: "userId")!
    var specifiedPlaylist: SpecifiedPlaylist?
    var userStatus = Int()
    var userRight = Bool()
    var playlistTracks: [DisplayablePlaylist?] = []
    var selectedTrackTitle: String?
    var selectedTrackId: String?
    
    var loadCtrl = 0
    
    var tabBarView: TabBarViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        self.tableview.addGestureRecognizer(longPressGesture)
        tabBarView = self.tabBarController as? TabBarViewController
        tableview.delegate = self
        tableview.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        hideItems()
        updatePlaylistView()
        getTracksOfPlaylist()
        let notifName = Notification.Name(rawValue: "refreshSpecificPlaylist")
        NotificationCenter.default.addObserver(self, selector: #selector(refreshSpecificPlaylist), name: notifName, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        playlistTracks.removeAll()
    }
    
    @objc func refreshSpecificPlaylist() {
        self.getTracksOfPlaylist()
    }
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: self.tableview)
        let indexPath = self.tableview.indexPathForRow(at: p)
        if indexPath == nil {
            print("Long press on tableView, not row!")
        } else if longPressGesture.state == UIGestureRecognizer.State.began {
            print("long press on row, at \(indexPath!.row)")
            if (indexPath!.row >= playlistTracks.count) {
                print("Invalid index!")
                return
            }
            self.selectedTrackId = playlistTracks[indexPath!.row]?.id
            self.selectedTrackTitle = playlistTracks[indexPath!.row]?.name
            performSegue(withIdentifier: "ShareTrackFriend", sender: self)
        }
    }
    
    func hideItems() {
        self.lblUserStatus.isHidden = true
        self.lblUserRight.isHidden = true
        self.lblPlaylistName.isHidden = true
        self.lblStyleName.isHidden = true
        self.lblCreator.isHidden = true
        self.imgCoverPlaylist.isHidden = true
        self.btnShowDetails.isHidden = true
        self.btnParameters.isHidden = true
        self.tableview.isHidden = true
        self.btnAction.isHidden = true
        self.btnManageTracks.isHidden = true
    }
    
    func revealItems(creator: Bool) {
        self.lblUserStatus.isHidden = false
        self.lblUserRight.isHidden = false
        self.lblPlaylistName.isHidden = false
        self.lblStyleName.isHidden = false
        self.lblCreator.isHidden = false
        self.imgCoverPlaylist.isHidden = false
        self.btnShowDetails.isHidden = false
        if (creator == true) {
            self.btnParameters.isHidden = false
        }
        if (self.userRight == true && playlistTracks.count > 0) {
            self.btnManageTracks.isHidden = false
        }
        self.tableview.isHidden = false
        self.btnAction.isHidden = false
    }
    
    
    func updatePlaylistView() {
        GetSpecifiedPlaylist.shared.getSpecifiedPlaylist(id: playlistId) { (success, playlist, user) in
            if (playlist != nil) {
                self.specifiedPlaylist = playlist!.playlist
                self.userStatus = user!.userStatus!
                self.userRight = user!.userRight!
                self.updateUserStatus(status: self.userStatus)
                self.updateUserRight(right: self.userRight)
                self.lblPlaylistName.text = playlist?.playlist.name
                self.lblCreator.text = "Créée par \(String(describing: playlist!.playlist.creator.userPseudo))"
                self.lblStyleName.text = "Style : "
                if (playlist!.playlist.musicalStyle == "none") {
                    self.lblStyleName.text! += "Non défini"
                } else {
                    self.lblStyleName.text! += playlist!.playlist.musicalStyle.capitalized
                }
                if (self.loadCtrl == 1) {
                    self.revealItems(creator: user?.userStatus == 0)
                    UIView.transition(with: self.view, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
                }
                self.loadCtrl = 1
            }
        }
    }
    
    func getTracksOfPlaylist() {
        GetPlaylistTracks.shared.getTheTracksOfAPlaylist(playlistId: self.playlistId) { (success) in
            self.allTracks = GetPlaylistTracks.shared.allTracks
            AdjustStringFormat.shared.prepareStringFormat(self.allTracks)
            self.allTracksString = UserDefaults.standard.string(forKey: "testString")!
            GetSeveralTracks.shared.getSeveralTracks(trackslist: self.allTracksString) { (success) in
                self.playlistTracks = Array(GetSeveralTracks.shared.displayablePlaylist)
                DispatchQueue.main.async {
                    if (self.playlistTracks.count != 0) {
                        let imageUrl = self.playlistTracks[0]!.imageHdUrl
                        self.imgCoverPlaylist.image = UIImage(url: URL(string: imageUrl))
                        if (self.userRight == true && self.loadCtrl == 1){
                            self.btnManageTracks.isHidden = false
                        }
                    } else {
                        self.imgCoverPlaylist.image = UIImage(systemName: "music.note")
                        if (self.userRight == true && self.loadCtrl == 1){
                            self.btnManageTracks.isHidden = true
                        }
                    }
                    self.tableview.reloadData()
                    if (self.loadCtrl == 1) {
                        self.revealItems(creator: self.userStatus == 0)
                        UIView.transition(with: self.view, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
                    }
                    self.loadCtrl = 1
                }
            }
        }
    }
    
    
    func updateUserStatus(status: Int) {
        switch status {
        case 0:
            self.lblUserStatus.text! = "Vous êtes le créateur de cette playlist"
            self.btnAction.setTitle(" Delete ", for: .normal)
            self.btnAction.backgroundColor = #colorLiteral(red: 0.5153919458, green: 0.07428186387, blue: 0.03882482648, alpha: 1)
        case 1:
            self.lblUserStatus.text! = "Vous êtes associé à cette playlist"
            self.btnAction.setTitle(" Leave ", for: .normal)
            self.btnAction.backgroundColor = #colorLiteral(red: 0.5153919458, green: 0.07428186387, blue: 0.03882482648, alpha: 1)
        case 2:
            self.lblUserStatus.text! = "Vous suivez cette playlist"
            self.btnAction.setTitle(" Unfollow ", for: .normal)
            self.btnAction.backgroundColor = #colorLiteral(red: 0.5153919458, green: 0.07428186387, blue: 0.03882482648, alpha: 1)
        case 3:
            self.lblUserStatus.text! = "Vous n'avez aucune appartenance à cette playlist"
            self.btnAction.setTitle(" Follow ", for: .normal)
            self.btnAction.backgroundColor = #colorLiteral(red: 0, green: 0.5899253488, blue: 0, alpha: 1)
        default :
            break
        }
    }
    
    func updateUserRight(right: Bool) {
        switch right {
        case false:
            self.lblUserRight.text! = "Vous n'avez pas le droit de modifier cette playlist"
        case true:
            self.lblUserRight.text! = "Vous avez le droit de modifier cette playlist"
        }
    }
    
    func goToPrevious(alert: UIAlertAction!) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    func deletePlaylist(alert: UIAlertAction!) {
        self.btnAction.isEnabled = false
        DeleteAPlaylist.shared.deleteAPlaylist(playlistId: playlistId) { (success) in
            if (success == true) {
                let alertVC: UIAlertController
                alertVC = UIAlertController(title: self.title, message: "Playlist supprimée", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: self.goToPrevious))
                self.present(alertVC, animated: true, completion: nil)
                let name = Notification.Name(rawValue: "refreshUserPlaylistsData")
                let notification = Notification(name: name)
                NotificationCenter.default.post(notification)
            }
            self.btnAction.isEnabled = true
        }
    }
    
    func leavePlaylist(alert: UIAlertAction!) {
        self.btnAction.isEnabled = false
        RemoveFriendFromPlaylist.shared.removeFriendFromPlaylist(userId: userId, playlistId: playlistId, friendId: userId) { (success) in
            if (success == true) {
                if (self.specifiedPlaylist!.public == false) {
                    _ = self.navigationController?.popViewController(animated: true)
                }
                self.lblUserStatus.text! = "Vous n'avez aucune appartenance à cette playlist"
                self.btnAction.setTitle(" Follow ", for: .normal)
                self.btnAction.backgroundColor = #colorLiteral(red: 0, green: 0.5899253488, blue: 0, alpha: 1)
                let name = Notification.Name(rawValue: "refreshUserPlaylistsData")
                let notification = Notification(name: name)
                NotificationCenter.default.post(notification)
            }
            self.btnAction.isEnabled = true
        }
    }
    
    func followPlaylist() {
        self.btnAction.isEnabled = false
        FollowAPlaylist.shared.followAPlaylist(playlistId: playlistId) { (success) in
            if (success == true) {
                self.lblUserStatus.text! = "Vous suivez cette playlist"
                self.btnAction.setTitle(" Unfollow ", for: .normal)
                self.btnAction.backgroundColor = #colorLiteral(red: 0.5153919458, green: 0.07428186387, blue: 0.03882482648, alpha: 1)
                if (self.userRight == true && self.playlistTracks.count > 0) {
                    self.btnManageTracks.isHidden = false
                }
                let name = Notification.Name(rawValue: "refreshUserPlaylistsData")
                let notification = Notification(name: name)
                NotificationCenter.default.post(notification)
            }
            self.btnAction.isEnabled = true
        }
    }
    
    func unfollowPlaylist() {
        self.btnAction.isEnabled = false
        UnFollowAPlaylist.shared.unfollowAPlaylist(playlistId: playlistId) { (success) in
            if (success == true) {
                self.lblUserStatus.text! = "Vous n'avez aucune appartenance à cette playlist"
                self.btnAction.setTitle(" Follow ", for: .normal)
                self.btnAction.backgroundColor = #colorLiteral(red: 0, green: 0.5899253488, blue: 0, alpha: 1)
                self.btnManageTracks.isHidden = true
                let name = Notification.Name(rawValue: "refreshUserPlaylistsData")
                let notification = Notification(name: name)
                NotificationCenter.default.post(notification)
            }
            self.btnAction.isEnabled = true
        }
    }
    
    @IBAction func btnActionOnClick(_ sender: Any) {
        if (btnAction.currentTitle! == " Delete ") {
            let alertVC: UIAlertController
            alertVC = UIAlertController(title: title, message: "Voulez-vous vraiment supprimer la playlist ?", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Oui", style: UIAlertAction.Style.default, handler: deletePlaylist))
            alertVC.addAction(UIAlertAction(title: "Non", style: UIAlertAction.Style.default, handler: nil))
            present(alertVC, animated: true, completion: nil)
        } else if (btnAction.currentTitle! == " Leave ") {
            let alertVC: UIAlertController
            alertVC = UIAlertController(title: title, message: "Voulez-vous vraiment quitter la playlist ?", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Oui", style: UIAlertAction.Style.default, handler: leavePlaylist))
            alertVC.addAction(UIAlertAction(title: "Non", style: UIAlertAction.Style.default, handler: nil))
            present(alertVC, animated: true, completion: nil)
        } else if (btnAction.currentTitle! == " Follow ") {
            followPlaylist()
        } else if (btnAction.currentTitle! == " Unfollow ") {
            unfollowPlaylist()
        }
    }
    

    @IBAction func btnInfomations(_ sender: Any) {
        performSegue(withIdentifier: "PlaylistInformations", sender: self)
    }
    
    @IBAction func btnParameters(_ sender: Any) {
        performSegue(withIdentifier: "PlaylistParameters", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlaylistParameters" {
            let navController = segue.destination as! UINavigationController
            let targetController = navController.topViewController as! PlaylistParametersViewController
            targetController.vc = self
        }
        if segue.identifier == "PlaylistInformations" {
            let navController = segue.destination as! UINavigationController
            let targetController = navController.topViewController as! PlaylistInformationsViewController
            targetController.vc = self
        }
        if let vc = segue.destination as? ShareTrackViewController {
            if self.selectedTrackId == nil || self.selectedTrackTitle == nil {
                print("No selected track")
                return
            } else {
                vc.trackId = self.selectedTrackId!
                vc.trackTitle = self.selectedTrackTitle!
            }
        }
    }
    @IBAction func sortTracks(_ sender: Any) {
        if (tableview.isEditing) {
            tableview.isEditing = false
        } else {
            tableview.isEditing = true
        }
    }
}


extension ShowPlaylistViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlistTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell") as? TrackTableViewCell else {
            return UITableViewCell()
        }
        if (playlistTracks.count <= indexPath.row) {
            print(playlistTracks)
            return UITableViewCell()
        }
        cell.trackTitle.text = playlistTracks[indexPath.row]?.name
        cell.trackArtist.text = playlistTracks[indexPath.row]?.artists
        cell.trackImage.image = playlistTracks[indexPath.row]?.image
        cell.trackIndex = indexPath.row
        cell.trackIds.removeAll()
        for i in 0...playlistTracks.count - 1 {
            cell.trackIds.append(playlistTracks[i]!.id)
        }
        cell.playerView = tabBarView?.playerView
        return cell
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if (self.userRight == true){
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        ChangeOrderTracks.shared.changeOrderTracks(oldIndex: sourceIndexPath.row, newIndex: destinationIndexPath.row) { (success) in
            if (success == 0) {
                self.tableview.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if (self.userRight == true){
            return .delete
        }
        return .none;
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            DeleteATrack.shared.deleteATrack(playlistId: playlistId, index: indexPath.row) { (success) in
                if (success == true) {
                    self.getTracksOfPlaylist()
                }
            }
        }
    }

}
