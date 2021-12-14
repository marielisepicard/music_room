//
//  SearchAFriendViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 04/02/2021.
//

import UIKit

class SearchAFriendViewController: UIViewController {

    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchPseudo: UITextField!
    @IBOutlet weak var searchView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        self.searchView.layer.cornerRadius = 10
        self.searchView.layer.borderWidth = 2
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
        self.searchView.layer.borderColor = UIColor(red:28/255, green:20/255, blue:88/255, alpha: 1).cgColor
        loadPseudoList()
    }
    
    func loadPseudoList() {
        FriendSearch.shared.friendSearch(keyWord: searchPseudo.text!) { (success) in
            DispatchQueue.main.async {
                UIView.transition(with: self.tableview, duration: 0.35, options: .transitionCrossDissolve, animations: self.tableview.reloadData)
            }
        }
    }
    
    @IBAction func updateSearch(_ sender: Any) {
        loadPseudoList()
    }
    @objc func handleTap() {
        searchPseudo.resignFirstResponder()
    }
}

extension SearchAFriendViewController: PseudoSearchResultDelegator {
    
    
    func displayPseudoProfile(friendId: String) {
        UserDefaults.standard.setValue(friendId, forKey: "friendId")
        performSegue(withIdentifier: "DisplayPseudoProfile", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DisplayPseudoProfile" {
         _ = segue.destination as! DisplayFriendProfileViewController
        }
    }
    
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
}

extension SearchAFriendViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FriendSearch.shared.searchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PseudoListCellTableViewCell") as? PseudoListCellTableViewCell else {
            return UITableViewCell()
        }
        if (indexPath.row >= FriendSearch.shared.searchResult.count) {
            return UITableViewCell()
        }
        let pseudoList = FriendSearch.shared.searchResult[indexPath.row]
        cell.lblPseudo.text = pseudoList.pseudo
        cell.pseudoId = pseudoList._id
        cell.delegate = self
        return cell
    }
}

extension SearchAFriendViewController {
    
    private func presentAlert(nb: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if nb == 1 {
            title = "Invitation envoyée"
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
