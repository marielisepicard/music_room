//
//  FriendsViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 04/02/2021.
//

import UIKit

class FriendsViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchFriend: UITextField!
    @IBOutlet weak var searchView: UIView!
    
    var friendsList: [FriendsList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.searchView.layer.cornerRadius = 10
        self.searchView.layer.borderWidth = 2
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
        self.searchView.layer.borderColor = UIColor(red:28/255, green:20/255, blue:88/255, alpha: 1).cgColor
        loadFriendList()
    }
    
    func loadFriendList() {
        SearchFriends.shared.getUserFriends(value: searchFriend.text!) { (success, friendsList) in
            self.friendsList = friendsList!
            UIView.transition(with: self.tableview, duration: 0.35, options: .transitionCrossDissolve, animations: self.tableview.reloadData)
        }
    }
    
    @IBAction func friendSearchUpdate(_ sender: Any) {
        loadFriendList()
    }
    
    @objc func handleTap() {
        searchFriend.resignFirstResponder()
    }
    
    func popupDeleteFriend() {
        let alertVC: UIAlertController
        alertVC = UIAlertController(title: "Ami supprimé", message: "", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}

extension FriendsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsListCell") as? FriendsListTableViewCell else {
            return UITableViewCell()
        }
        let friend = friendsList[indexPath.row]
        cell.friendId = friend._id
        cell.pseudoLabel.text = friend.pseudo
        cell.delegate = self
        cell.vc = self
        return cell
    }
}

extension FriendsViewController: FriendsListDelegator {
    
    func displayFriendProfile(friendId: String) {
        UserDefaults.standard.setValue(friendId, forKey: "friendId")
        performSegue(withIdentifier: "DisplayFriendProfile", sender: self)
    }
}
    
 extension FriendsViewController {
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
         if segue.identifier == "PseudosSearchResult" {
             _ = segue.destination as! SearchAFriendViewController
         } else if segue.identifier == "DisplayFriendProfile" {
            _ = segue.destination as! DisplayFriendProfileViewController
        }
     }
}

extension FriendsViewController {
    
    private func presentAlert(number: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if number == 1 {
            title = "Hep Hep Hep"
            message = "Tu ne peux pas faire une recherche vide 😁"
        } else if number == 2 {
            title = "Souci Interne"
            message = "Désolé, on a des soucis en interne, reviens plus tard"
        }
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}
