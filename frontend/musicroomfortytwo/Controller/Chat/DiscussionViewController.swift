//
//  DiscussionViewController.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 24/03/2021.
//

import Foundation
import UIKit

class DiscussionViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var userDiscussions = DiscussionsList()
    var selectedDiscussionIdx: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        NotificationCenter.default.addObserver(self, selector: #selector(self.addNewIncommingMessage(_:)), name: NSNotification.Name(rawValue: "receiveMsg"), object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        loadExistingDiscussionsData()
    }
    func loadExistingDiscussionsData() {
        userDiscussions.getUserDiscussions() { (success) in
            self.displayDiscussions()
        }
    }
    func displayDiscussions() {
        UIView.transition(with: self.tableView, duration: 0.35, options: .transitionCrossDissolve, animations: { self.tableView.reloadData() })
    }
    @objc func addNewIncommingMessage(_ notification: NSNotification) {
        let friendId = notification.userInfo?["ownerId"] as? String
        let friendPseudo = notification.userInfo?["ownerPseudo"] as? String
        let content = notification.userInfo?["content"] as? String
        if friendId == nil || friendPseudo == nil || content == nil {
            print("Error, invalid friendId or friendPseudo or contentMsg");
            return
        }
        let existingDiscussion = findExistingDiscussion(friendId!)
        if existingDiscussion == -1 {
            let recipient = RecipientObject(id: friendId!, pseudo: friendPseudo!)
            userDiscussions.discussions.insert(Discussion(DiscussionObject(recipient: recipient, messages: [])), at: 0)
            addMessageToDiscussion(discussionIdx: 0, userId: friendId!, content: content!)
        } else {
            addMessageToDiscussion(discussionIdx: existingDiscussion, userId: friendId!, content: content!)
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshDiscussion"),  object: nil)
        tableView.reloadData()
    }
    func addMessageToDiscussion(discussionIdx: Int, userId: String, content: String) {
        let nowDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let message = MessageObject(content: content, ownerId: userId, date: formatter.string(from: nowDate))
        userDiscussions.discussions[discussionIdx]!.messages.append(message)
    }
    func findExistingDiscussion(_ friendId: String) -> Int {
        var recipientId: String!
        for i in 0 ..< userDiscussions.discussions.count {
            recipientId = userDiscussions.discussions[i]!.recipient.id
            if recipientId == friendId {
                return i
            }
        }
        return -1
    }
}

extension DiscussionViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDiscussions.discussions.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DiscussionsCell") as? DiscussionsCell else {
            return UITableViewCell()
        }
        cell.friendName.text = userDiscussions.discussions[indexPath.row]!.recipient.pseudo
        cell.cellIndex = indexPath.row
        cell.delegate = self
        return cell
    }
}

extension DiscussionViewController: MyDiscussionDelegator {
    func openFriendDiscussion(indexCell: Int) {
        selectedDiscussionIdx = indexCell
        performSegue(withIdentifier: "showFriendDiscussion", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DiscussionMessagesController {
            vc.vcParent = self
            vc.discussionIdx = selectedDiscussionIdx
        } else if let vc = segue.destination as? CreateNewDiscussionController {
            vc.vcParent = self
        }
    }
}
