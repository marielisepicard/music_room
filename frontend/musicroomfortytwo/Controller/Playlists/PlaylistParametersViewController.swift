//
//  PlaylistParametersViewController.swift
//  musicroomfortytwo
//
//  Created by Jerome on 09/03/2021.
//

import UIKit

class PlaylistParametersViewController: UIViewController {

    @IBOutlet weak var heightTableViewStyles: NSLayoutConstraint!
    @IBOutlet weak var tableViewStyles: UITableView!
    @IBOutlet weak var tableViewFriends: UITableView!
    @IBOutlet weak var tableViewAssociated: UITableView!
    @IBOutlet weak var `public`: UISwitch!
    @IBOutlet weak var editionRight: UISwitch!
    
    @IBOutlet weak var fieldSearchFriend: UITextField!

    
    let playlistId = UserDefaults.standard.string(forKey: "idOfSelectedPlaylist")!
    let userId = UserDefaults.standard.string(forKey: "userId")!
    var vc: ShowPlaylistViewController?
     
    
    var styles = ["none", "blues", "country", "disco", "folk",
                  "funk", "jazz", "raï", "rap", "raggae", "rock",
                  "salsa", "soul", "techno"];
    var printableStyles = [String]()
    var currentStyle = String()
    var brutCurrentStyle = String()
    var stylesOpen = false
    
    var friends = [FriendsList]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnView(sender:)))
        self.view.addGestureRecognizer(tapGesture)
        fieldSearchFriend.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fieldSearchFriend.layer.borderWidth = 1
        fieldSearchFriend.layer.borderColor = #colorLiteral(red: 0.1272085607, green: 0.0007708931807, blue: 0.3564728498, alpha: 1)
        fieldSearchFriend.autocorrectionType = .no
        updateTextField(textField: fieldSearchFriend)
        friends = []
        self.tableViewStyles.separatorStyle = UITableViewCell.SeparatorStyle.none
        brutCurrentStyle = vc!.specifiedPlaylist!.musicalStyle
        if (vc!.specifiedPlaylist!.musicalStyle == "none") {
            currentStyle = "Non défini"
        } else {
            currentStyle = vc!.specifiedPlaylist!.musicalStyle.capitalized
        }
        printableStyles = styles
        stylesOpen = false
        self.tableViewStyles.reloadData()
        GetSpecifiedPlaylist.shared.getSpecifiedPlaylist(id: vc!.playlistId) { (success, playlist, user) in
            if (playlist != nil) {
                self.vc!.specifiedPlaylist = playlist!.playlist
                self.tableViewAssociated.reloadData()
                UIView.transition(with: self.tableViewAssociated, duration: 0.25, options: .transitionCrossDissolve, animations: nil)
            }
        }
        updateParameterView()
    }
    
    @objc func tapOnView(sender: UITapGestureRecognizer) {
        closeMenu()
        unfocusTextField()
    }
    
    func closeMenu() {
        if (stylesOpen == true) {
            stylesOpen = false
            self.tableViewStyles.reloadData()
        }
    }
    
    func unfocusTextField() {
        if (fieldSearchFriend.isFirstResponder == true) {
            fieldSearchFriend.resignFirstResponder()
        }
    }
    
    func updateParameterView() {
        if (vc!.specifiedPlaylist!.public == false) {
            self.`public`.setOn(false, animated:true)
        }
        if (vc!.specifiedPlaylist!.editionRight == false) {
            self.editionRight.setOn(false, animated:true)
        }
    }
    
    @IBAction func btnPublic(_ sender: Any) {
        closeMenu()
        unfocusTextField()
        if (vc!.specifiedPlaylist!.public == true) {
            MakeAPlaylistPrivate.shared.makeAPlaylistPrivate(playlistId: self.playlistId) { (success) in
                if (success != 0) {
                    DispatchQueue.main.async {
                        self.`public`.setOn(false, animated:true)
                        self.editionRight.setOn(false, animated:true)
                    }
                    self.vc!.specifiedPlaylist?.public = false
                    self.vc!.specifiedPlaylist?.editionRight = false
                }
            }
        } else {
            MakeAPlaylistPublic.shared.makeAPlaylistPublic(playlistId: playlistId) { (success) in
                if success != 0 {
                    DispatchQueue.main.async {
                        self.`public`.setOn(true, animated:true)
                    }
                    self.vc!.specifiedPlaylist!.public = true
                }
            }
        }
    }
    

    @IBAction func btnEditionRight(_ sender: Any) {
        closeMenu()
        unfocusTextField()
        if (vc!.specifiedPlaylist!.editionRight == true) {
            SwitchEditionRight.shared.switchEditionRight(playlistId: playlistId) { (success) in
                if success == 1 {
                    DispatchQueue.main.async {
                        self.editionRight.setOn(false, animated: true)
                    }
                    self.vc!.specifiedPlaylist!.editionRight = false
                }
            }
        } else {
            SwitchEditionRight.shared.switchEditionRight(playlistId: playlistId) { (success) in
                if success == 1 {
                    DispatchQueue.main.async {
                        self.editionRight.setOn(true, animated: true)
                    }
                    self.vc!.specifiedPlaylist!.editionRight = true
                } else {
                    DispatchQueue.main.async {
                        self.editionRight.setOn(false, animated: true)
                    }
                }
            }
        }
    }
    
    func popupDelete() {
        let alertVC: UIAlertController
        alertVC = UIAlertController(title: "Associé supprimé", message: "", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }

}


extension PlaylistParametersViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == tableViewStyles) {
            if (stylesOpen == true) {
                return printableStyles.count
            }
            return 1
        } else if (tableView == tableViewFriends) {
            return friends.count
        } else if (tableView == tableViewAssociated) {
            return vc!.specifiedPlaylist!.associatedUsers.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == tableViewStyles) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StyleCell") as! StylesTableViewCell
            if (stylesOpen == true) {
                heightTableViewStyles.constant = 150
                cell.brutStyle = printableStyles[indexPath.row]
                if (printableStyles[indexPath.row] == "none") {
                    cell.lblStyle.text = "Non défini"
                } else {
                    cell.lblStyle.text = printableStyles[indexPath.row].capitalized
                }
                cell.vc = self
            } else {
                cell.brutStyle = currentStyle
                heightTableViewStyles.constant = 30
                if (brutCurrentStyle == "none") {
                    cell.lblStyle.text = "Non défini"
                } else {
                    cell.lblStyle.text = brutCurrentStyle.capitalized
                }
                cell.vc = self
            }
            return cell
        } else if (tableView == tableViewFriends) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell") as! FriendTableViewCell
            if (friends.count > indexPath.row) {
                cell.friendPseudo.text = friends[indexPath.row].pseudo
                cell.friendId = friends[indexPath.row]._id
                cell.vc = self
            }
            return cell
        } else if (tableView == tableViewAssociated) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AssociatedCell") as! AssociatedTableViewCell
            cell.associatedPseudo.text = vc!.specifiedPlaylist!.associatedUsers[indexPath.row].userPseudo
            cell.friendId = vc!.specifiedPlaylist!.associatedUsers[indexPath.row].userId
            cell.friendIndex = indexPath.row
            cell.switchRights.setOn(vc!.specifiedPlaylist!.associatedUsers[indexPath.row].editionRight, animated: true)
            cell.vc = self
            return cell
        }
        return UITableViewCell()
    }
    
}




class StylesTableViewCell: UITableViewCell {
    @IBOutlet weak var lblStyle: UILabel!
    
    @IBOutlet weak var styleCell: UIView!
    var brutStyle = String()
    var vc: PlaylistParametersViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openStyleMenu(sender:)))
        self.styleCell?.addGestureRecognizer(tapGesture)
    }

    @objc func openStyleMenu(sender: UITapGestureRecognizer) {
        if (vc!.stylesOpen == true) {
            vc!.tableViewStyles.separatorStyle = UITableViewCell.SeparatorStyle.none
            vc!.stylesOpen = false
            EditAPlaylistMusicalStyle.shared.editAPlaylistMusicalStyle(newMusicalStyle: self.brutStyle, playlistId: vc!.playlistId) { (success) in
                DispatchQueue.main.async {
                    if success == 1 {
                        self.vc!.currentStyle = self.lblStyle.text!
                        self.vc!.brutCurrentStyle = self.brutStyle
                        self.vc!.vc!.specifiedPlaylist!.musicalStyle = self.brutStyle
                        self.vc!.vc!.lblStyleName.text! = "Style : " + self.lblStyle.text!
                        self.vc!.tableViewStyles.reloadData()
                    }
                }
            }
        } else {
            vc!.unfocusTextField()
            vc!.tableViewStyles.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
            vc!.printableStyles = vc!.styles
            if let removeIndex = vc!.printableStyles.firstIndex(of: vc!.brutCurrentStyle) {
                vc!.printableStyles.remove(at:removeIndex)
                vc!.printableStyles.insert(vc!.brutCurrentStyle, at: 0)
            }
            vc!.stylesOpen = true
            vc!.tableViewStyles.reloadData()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

class FriendTableViewCell: UITableViewCell {
    @IBOutlet weak var btnSendInvit: UIButton!
    @IBOutlet weak var friendCell: UIView!
    @IBOutlet weak var friendPseudo: UILabel!
    @IBOutlet weak var switchRights: UISwitch!
    var editionRight = Int()
    var friendId = String()
    
    var vc: PlaylistParametersViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        editionRight = 1
        switchRights.transform = CGAffineTransform(scaleX: 0.60, y: 0.60);
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func sendInvitation(_ sender: Any) {
        InviteFriendToPlaylist.shared.inviteFriendToPlaylist(userId: vc!.userId, playlistId: vc!.playlistId, friendId: friendId, editionRight: editionRight) { (success) in
            self.btnSendInvit.isEnabled = false
            self.btnSendInvit.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            self.vc!.presentAlertInviteFriends(nb: success)
        }
    }
    
    @IBAction func changeEditionRight(_ sender: Any) {
        if (switchRights.isOn == true) {
            editionRight = 1
        } else {
            editionRight = 0
        }
    }
}

class AssociatedTableViewCell: UITableViewCell {
    @IBOutlet weak var associatedCell: UIView!
    @IBOutlet weak var associatedPseudo: UILabel!
    @IBOutlet weak var switchRights: UISwitch!
    var friendId = String()
    var friendIndex = Int()
    
    var vc: PlaylistParametersViewController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        switchRights.transform = CGAffineTransform(scaleX: 0.60, y: 0.60);
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func deleteAssociated(_ sender: Any) {
        RemoveFriendFromPlaylist.shared.removeFriendFromPlaylist(userId: vc!.userId, playlistId: vc!.playlistId, friendId: friendId) { (success) in
            if (success) {
                self.vc!.popupDelete()
            }
            GetSpecifiedPlaylist.shared.getSpecifiedPlaylist(id: self.vc!.playlistId) { (success, playlist, user) in
                if (playlist != nil) {
                    self.vc!.vc!.specifiedPlaylist = playlist!.playlist
                    self.vc!.tableViewAssociated.reloadData()
                }
            }
        }
    }
    @IBAction func changeEditionRight(_ sender: Any) {
        SwitchUserRight.shared.switchUserRight(playlistId: vc!.playlistId, friendId: friendId) { (success, editionRight) in
            if (editionRight != nil) {
                self.vc!.vc!.specifiedPlaylist!.associatedUsers[self.friendIndex].editionRight = editionRight!
            }
        }
    }
    
}

extension PlaylistParametersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if (textField == fieldSearchFriend) {
            updateTextField(textField: textField)
        }
        textField.resignFirstResponder()
        return true
    }
    
    func updateTextField(textField: UITextField) {
        SearchFriends.shared.getUserFriends(value: textField.text!) { (success, userFriends) in
            if (userFriends != nil) {
                self.friends = userFriends!
                self.tableViewFriends.reloadData()
                UIView.transition(with: self.tableViewFriends, duration: 0.25, options: .transitionCrossDissolve, animations: nil)
            }
        }
    }
}


extension PlaylistParametersViewController {
    
    func presentAlertInviteFriends(nb: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if nb == 1 {
            title = "Ok"
            message = "Tu as bien invité ton ami, manque plus qu'il accepte ton invitation"
        } else if nb == 2 {
            title = "Désolé"
            message = " Tu n'as pas les droits pour faire cette opération"
        } else if nb == 3 {
            title = "Oups"
            message = "Cet ami est déjà associé à la playlist :)"
        } else if nb == 0 {
            title = "Erreur Interne 😢"
            message = "Désolé... reviens plus tard"
        } else if nb == 4  {
            title = "En attente"
            message = "Tu as déjà invité cet ami... manque plus qu'il réponde!"
        }
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }

}
