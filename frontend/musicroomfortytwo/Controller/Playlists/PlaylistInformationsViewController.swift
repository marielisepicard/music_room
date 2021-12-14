//
//  PlaylistInformationsViewController.swift
//  musicroomfortytwo
//
//  Created by Jerome on 16/03/2021.
//

import UIKit

class PlaylistInformationsViewController: UIViewController {

    @IBOutlet weak var lblPublic: UILabel!
    @IBOutlet weak var tableViewCreator: UITableView!
    @IBOutlet weak var tableViewAssociated: UITableView!
    @IBOutlet weak var tableViewFollowers: UITableView!
    
    var vc: ShowPlaylistViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (vc!.specifiedPlaylist?.public == true) {
            lblPublic.text = "Cette playlist est publique"
        } else {
            lblPublic.text = "Cette playlist est privée"
        }
        GetSpecifiedPlaylist.shared.getSpecifiedPlaylist(id: vc!.playlistId) { (success, playlist, user) in
            if (playlist != nil) {
                self.vc!.specifiedPlaylist = playlist!.playlist
                self.tableViewAssociated.reloadData()
                self.tableViewFollowers.reloadData()
                UIView.transition(with: self.tableViewAssociated, duration: 0.25, options: .transitionCrossDissolve, animations: nil)
                UIView.transition(with: self.tableViewFollowers, duration: 0.25, options: .transitionCrossDissolve, animations: nil)
            }
        }
        tableViewCreator.reloadData()
    }
    
}

extension PlaylistInformationsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == tableViewCreator) {
            return 1
        } else if (tableView == tableViewAssociated) {
            return (vc!.specifiedPlaylist?.associatedUsers.count)!
        } else if (tableView == tableViewFollowers) {
            return (vc!.specifiedPlaylist?.followers.count)!
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == tableViewCreator) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistCreatorCell") as! PlaylistCreatorViewCell
            cell.lblCreator.text = vc!.specifiedPlaylist?.creator.userPseudo
            cell.creatorId = (vc!.specifiedPlaylist?.creator.userId)!
            cell.vc = self
            return cell
        } else if (tableView == tableViewAssociated) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistAssociatedCell") as! PlaylistAssociatedViewCell
            cell.lblAssociated.text = vc!.specifiedPlaylist?.associatedUsers[indexPath.row].userPseudo
            cell.associatedId = (vc!.specifiedPlaylist?.associatedUsers[indexPath.row].userId)!
            cell.vc = self
            return cell
        } else if (tableView == tableViewFollowers) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistFollowerCell") as! PlaylistFollowersViewCell
            cell.lblFollower.text = vc!.specifiedPlaylist?.followers[indexPath.row].userPseudo
            cell.followerId = (vc!.specifiedPlaylist?.followers[indexPath.row].userId)!
            cell.vc = self
            return cell
        }
        return UITableViewCell()
    }
    
}

extension PlaylistInformationsViewController {
    
    func inviteFriend(friendId: String) {
        InviteAFriend.shared.inviteAFriend(friendId: friendId) { (success) in
            if success == 1 {
                self.presentAlert(nb: success)
            } else if success == 2 {
                self.presentAlert(nb: success)
            } else if success == 3 {
                self.presentAlert(nb: success)
            } else if success == 4 {
                self.presentAlert(nb: success)
            } else if success == 5 {
                self.presentAlert(nb: success)
            }
        }
    }
    
    private func presentAlert(nb: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if nb == 1 {
            title = "Invitation envoyée"
//            message = "Reste à savoir si ta demande sera acceptée"
        } else if nb == 2 {
            title = "Erreur Interne 😢"
            message = "Désolé... reviens plus tard"
        } else if nb == 3 {
            title = "Hep Hep Hep"
            message = "Désolé, tu ne peux pas être ton propre ami"
        } else if nb == 4 {
            title = "Oups"
            message = "Tu es déjà ami avec cette personne"
        } else if nb == 5 {
            title = "Demande en attente"
            message = "Sois patient, ton ami n'a pas encore accepté ton invitation"
        }
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}






class PlaylistCreatorViewCell: UITableViewCell {
    
    @IBOutlet weak var btnSendInvitation: UIButton!
    @IBOutlet weak var lblCreator: UILabel!
    var creatorId = String()
    var vc: PlaylistInformationsViewController?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func addFriend(_ sender: Any) {
        vc?.inviteFriend(friendId: creatorId)
        btnSendInvitation.isEnabled = false
        btnSendInvitation.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    }
}

class PlaylistAssociatedViewCell: UITableViewCell {
    
    @IBOutlet weak var btnSendInvitation: UIButton!
    @IBOutlet weak var lblAssociated: UILabel!
    var associatedId = String()
    var vc: PlaylistInformationsViewController?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func addFriend(_ sender: Any) {
        vc?.inviteFriend(friendId: associatedId)
        btnSendInvitation.isEnabled = false
        btnSendInvitation.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    }
}

class PlaylistFollowersViewCell: UITableViewCell {
    
    @IBOutlet weak var btnSendInvitation: UIButton!
    @IBOutlet weak var lblFollower: UILabel!
    var followerId = String()
    var vc: PlaylistInformationsViewController?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func addFriend(_ sender: Any) {
        vc?.inviteFriend(friendId: followerId)
        btnSendInvitation.isEnabled = false
        btnSendInvitation.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    }
}

