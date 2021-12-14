//
//  ShareTrackViewController.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 15/04/2021.
//

import Foundation

class ShareTrackViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var friendSearch: UITextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var shareTitleLabel: UILabel!
    var friendsList: [FriendsList] = []
    var trackId = ""
    var trackTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendSearch.delegate = self
        self.searchView.layer.cornerRadius = 10
        self.searchView.layer.borderWidth = 2
        self.searchView.layer.borderColor = UIColor(red:28/255, green:20/255, blue:88/255, alpha: 1).cgColor
        shareTitleLabel.text = "Partager \"\(trackTitle)\" à un ami"
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
        loadFriendList()
    }
    func loadFriendList() {
        SearchFriends.shared.getUserFriends(value: friendSearch.text!) { (success, friendsList) in
            self.friendsList = friendsList!
            print("before printing tableViewResult")
            UIView.transition(with: self.tableView, duration: 0.35, options: .transitionCrossDissolve, animations: self.tableView.reloadData)
        }
    }
    @IBAction func friendSearchUpdate(_ sender: Any) {
        print("update field")
        loadFriendList()

    }
    @objc func handleTap() {
        friendSearch.resignFirstResponder()
    }
}

extension ShareTrackViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("nb of friends: \(friendsList.count)")
        return friendsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "shareTrackCell") as? ShareTrackViewCell else {
            return UITableViewCell()
        }
        cell.friendPseudo.text = friendsList[indexPath.row].pseudo
        cell.shareTrack.tag = indexPath.row
        cell.delegate = self
        return cell
    }
}

extension ShareTrackViewController: MyShareTrackCellDelegator {
    func shareTrackToFriend(friendIdx: Int) {
        print("in shareTrackToFriend")
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let userPseudo = UserDefaults.standard.string(forKey: "userPseudo")!
        print("friend index: ", friendIdx)
        let friendId = self.friendsList[friendIdx]._id
        let message = "sptTrackId:" + trackId
        SocketIOManager.shared.sendMsg(userId: userId, userPseudo: userPseudo, friendId: friendId, message: message)
    }
}

extension ShareTrackViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // dismiss keyboard
            return true
        }
}
