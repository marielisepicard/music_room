//
//  SelectFriendTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 08/02/2021.
//

import UIKit

/*
        EVENTS ITEM
        This subclass displays a list of user's friend
        so that the user can choose who he wants to invite
        to an event
 
        Identifier: SelectFriendCell
        Controller: SelectFriendViewController
 */

protocol MyInviteFriendInEventDelegator {
    func inviteFriendToAnEvent(indexCell: Int)
}

class InviteFriendInEventTableViewCell: UITableViewCell {
    @IBOutlet weak var friendPseudo: UILabel!
    @IBOutlet weak var addFriend: UIButton!
    
    var delegate: MyInviteFriendInEventDelegator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func inviteFriendToEvent(_ sender: UIButton) {
        self.delegate.inviteFriendToAnEvent(indexCell: sender.tag)
    }
    
}
