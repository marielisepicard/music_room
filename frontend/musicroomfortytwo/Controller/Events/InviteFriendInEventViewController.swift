//
//  SelectFriendViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 08/02/2021.
//

import UIKit

class InviteFriendInEventViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var friendSearch: UITextField!
    @IBOutlet weak var searchView: UIView!
    var vcParent: ShowSpecificEventViewController?
    var friendsList: [FriendsList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendSearch.delegate = self
        self.searchView.layer.cornerRadius = 10
        self.searchView.layer.borderWidth = 2
        self.searchView.layer.borderColor = UIColor(red:28/255, green:20/255, blue:88/255, alpha: 1).cgColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
        loadFriendList()
    }
    func loadFriendList() {
        SearchFriends.shared.getUserFriends(value: friendSearch.text!) { (success, friendsList) in
            self.friendsList = friendsList!
            UIView.transition(with: self.tableView, duration: 0.35, options: .transitionCrossDissolve, animations: self.tableView.reloadData)
        }
    }
    @IBAction func friendSearchUpdate(_ sender: Any) {
        loadFriendList()
    }
    @objc func handleTap() {
        friendSearch.resignFirstResponder()
    }
    func isFriendInEvent(friendId: String) -> Bool {
        for i in 0 ..< (vcParent?.event?.guestsInfo?.count)! {
            if friendId == vcParent?.event?.guestsInfo![i].userId {
                return true
            }
        }
        return false
    }
}

extension InviteFriendInEventViewController: MyInviteFriendInEventDelegator {
    func inviteFriendToAnEvent(indexCell: Int) {
        if isFriendInEvent(friendId: friendsList[indexCell]._id) == false {
            vcParent?.event?.inviteFriendToAnEvent(friendId: friendsList[indexCell]._id) { (success, code) in
                self.presentAlert(success: success, code: code)
            }
        }
    }
}

extension InviteFriendInEventViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("nb of friends: \(friendsList.count)")
        return friendsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InviteFriendCell") as? InviteFriendInEventTableViewCell else {
            return UITableViewCell()
        }
        cell.friendPseudo.text = friendsList[indexPath.row].pseudo
        cell.addFriend.tag = indexPath.row
        if isFriendInEvent(friendId: friendsList[indexPath.row]._id) {
            cell.addFriend.tintColor = UIColor.gray
        }
        cell.delegate = self
        return cell
    }
}

extension InviteFriendInEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // dismiss keyboard
            return true
        }
}

extension InviteFriendInEventViewController {
    private func presentAlert(success: Bool, code: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if success ==  true {
            title = "Invitation envoyée"
            message = "Votre ami a reçu une demande d'invitation à cet évènement"
        } else {
            if code == 5 {
                title = "Impossible d'envoyer la demande d'invitation à l'évènement 😢"
                message = "Votre ami a déjà une demande d'invitation pour cet évènement"
            }
        }
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in }
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
}
