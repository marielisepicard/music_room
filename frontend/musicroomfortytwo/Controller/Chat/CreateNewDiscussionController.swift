//
//  CreateNewDiscussionController.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 24/03/2021.
//

import Foundation
import UIKit

class CreateNewDiscussionController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var friendSearch: UITextField!
    @IBOutlet weak var searchView: UIView!
    var friendsList: [FriendsList] = []
    var selectedFriendIdx: Int!
    var vcParent: DiscussionViewController!
    
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
    @IBAction func friendSearchDiscussionUpdate(_ sender: Any) {
        loadFriendList()
    }
    @objc func handleTap() {
        friendSearch.resignFirstResponder()
    }
}

extension CreateNewDiscussionController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendsList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DiscussionFriendCell") as? DiscussionfriendCell else {
            return UITableViewCell()
        }
        cell.friendPseudo.text = friendsList[indexPath.row].pseudo
        cell.cellIndex = indexPath.row
        cell.delegate = self
        return cell
    }
}

extension CreateNewDiscussionController: MyDiscussionFriendDelegator {
    func openFriendDiscussion(indexCell: Int) {
        selectedFriendIdx = indexCell
        performSegue(withIdentifier: "showDiscussionPreview", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DiscussionMessagesController {
            let friendId = friendsList[selectedFriendIdx]._id
            let friendPseudo = friendsList[selectedFriendIdx].pseudo
            let existingDiscussion = findExistingDiscussion(friendId)
            if existingDiscussion != -1 {
                vc.discussionIdx = existingDiscussion
            } else {
                let recipient = RecipientObject(id: friendId, pseudo: friendPseudo)
                vcParent.userDiscussions.discussions.insert(Discussion(DiscussionObject(recipient: recipient, messages: [])), at: 0)
                vcParent.tableView.reloadData()
                vc.discussionIdx = 0
            }
            vc.vcParent = vcParent
        }
    }
    func findExistingDiscussion(_ friendId: String) -> Int {
        var recipientId: String!
        for i in 0 ..< vcParent.userDiscussions.discussions.count {
            recipientId = vcParent.userDiscussions.discussions[i]!.recipient.id
            if recipientId == friendId {
                return i
            }
        }
        return -1
    }
}

extension CreateNewDiscussionController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // dismiss keyboard
            return true
        }
}
