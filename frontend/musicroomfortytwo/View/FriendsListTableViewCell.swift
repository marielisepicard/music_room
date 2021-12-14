//
//  FriendsListTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 11/02/2021.
//

import UIKit

/*
        FRIEND ITEM
        Cell subclass to display the list of users friends.
        The user can click on a friend pseudo to display his friend's profile
 
        Identifier: FriendsListCell
        View Controller: FriendsViewController
 */

protocol FriendsListDelegator {
    func displayFriendProfile(friendId: String)
}

class FriendsListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pseudoLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    var friendId = String()
    
    var vc: FriendsViewController?
    var delegate: FriendsListDelegator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(friendTappedGesture))
        self.cellView.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func deleteFriend(_ sender: Any) {
        DeleteAFriend.shared.deleteAFriend(friendId: friendId) {(sucess) in
            if (sucess == true) {
                self.vc?.loadFriendList()
                self.vc!.popupDeleteFriend()
            }
        }
    }
    
    @objc func friendTappedGesture() {
        if self.delegate != nil {
            self.delegate.displayFriendProfile(friendId: self.friendId)
        }
    }

}
