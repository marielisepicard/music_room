//
//  SelectPlaylistViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 03/02/2021.
//

import UIKit

class SelectPlaylistViewController: UIViewController, MySelectionOfPlaylistListDelegator {
    let userPlaylist = GetUserPlaylist()
    
    var mappingSection = [Int()]
    var nameSections = ["Playlists créées", "Playlists associées", "Playlists suivies"]
    var nbrSections = 0
    
    var arrayImages = GetSeveralTracks()
    var stringTracks = String()
    
    func addTrackAndComeBack(cell: UITableViewCell) {
        AddTrackToPlaylist.shared.addTrackToPlaylist() { (success) in
            self.presentAlert(nb: success)            
        }
    }
    

    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        getAllUserPlaylists() // Make the request to get the user playlists
    }
    
    func getAllUserPlaylists() {
        userPlaylist.getUserPlaylist() { (success) in
            if success == 1 {
                self.createArrayImages()
                if (self.stringTracks == "") {
                    DispatchQueue.main.async {
                        self.tableview.reloadData()
                        UIView.transition(with: self.tableview, duration: 0.35, options: .transitionCrossDissolve, animations: nil)
                    }
                } else {
                    self.arrayImages.getSeveralTracks(trackslist: self.stringTracks) { (success) in
                        if (success == true) {
                            DispatchQueue.main.async {
                                self.fillImages()
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
}

extension SelectPlaylistViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PickPlaylist") as? SelectingPlaylistTableViewCell else {
            return UITableViewCell()
        }
        let playlist = userPlaylist.userPlaylists[mappingSection[indexPath.section]][indexPath.row]
        cell.lblPlaylist.text = playlist.name
        cell.lblCreator.text = "par " + playlist.creator
        cell.playlistId = playlist.id
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

extension SelectPlaylistViewController {
    
    private func presentAlert(nb: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if nb == 1 {
            title = "Morceau ajouté à la playlist"
//            message = "🤫 Ça reste entre toi et moi, mais c'est une de mes chansons préférées !"
        } else if nb == 0 {
            title = "Erreur Interne 😢"
            message = "Nous avons un problème technique... Reviens plus tard !"
        } else if nb == 3 {
            title = "Le morceau est déjà dans la playlist"
        }
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}
