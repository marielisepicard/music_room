//
//  PendingFriendInvitsTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 05/02/2021.
//

import UIKit

/*
        FRIEND ITEM
        Cell subclass to display a list of pending invitations for
        the connected user.
        The user can accept or reject the invitation
 
        Identifier: PendingFriendInvitsCell
        ViewController: PendingInvitation
 */

protocol PendingInvitsDelegator {
    func acceptInvit(friendId: String)
}

class PendingFriendInvitsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var pseudoLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
    
    var delegate: PendingInvitsDelegator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    @IBAction func yesButtonTapped(_ sender: Any) {
        self.delegate.acceptInvit(friendId: idLabel.text!)
    }
    
    @IBAction func noButtonTapped(_ sender: Any) {
    }
}
