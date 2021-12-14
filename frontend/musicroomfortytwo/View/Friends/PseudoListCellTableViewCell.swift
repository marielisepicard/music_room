//
//  PseudoListCellTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 04/02/2021.
//

import UIKit

/*
        FRIEND ITEM
        Cell subclass to display a list of users when a user
        makes a friend research.
 
        Identifier: PseudoListCellTableViewCell
        View Controller: SearchAFriend
 */

protocol PseudoSearchResultDelegator {
    func inviteFriend(friendId: String)
    func displayPseudoProfile(friendId: String)
}

class PseudoListCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var lblPseudo: UILabel!
    @IBOutlet weak var cell: UIView!
    @IBOutlet weak var cellView: UIView!
    var pseudoId = String()
    
    var delegate: PseudoSearchResultDelegator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(userTappedGesture(sender:)))
        self.cellView?.addGestureRecognizer(tapGesture)
        // Configure the view for the selected state
    }
    @objc func userTappedGesture(sender: UITapGestureRecognizer) {
        if self.delegate != nil {
            let friendId = pseudoId
            self.delegate.displayPseudoProfile(friendId: friendId)
        }
    }
    @IBAction func addFriendButtonTapped(_ sender: Any) {
        let friendId = pseudoId
        self.delegate.inviteFriend(friendId: friendId)
        addFriendButton.isEnabled = false
        addFriendButton.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    }
}
