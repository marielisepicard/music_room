//
//  InviteFriendToPlaylistTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 14/02/2021.
//

import UIKit

protocol InviteFriendToPlaylistDelegator {
    func inviteFriendToPlaylist(friendName: String, friendId: String, editionRight: Int)
}

class InviteFriendToPlaylistTableViewCell: UITableViewCell {

    @IBOutlet weak var editionRight: UISegmentedControl!
    @IBOutlet weak var friendName: UIButton!
    @IBOutlet weak var friendId: UILabel!
    
    var delegate: InviteFriendToPlaylistDelegator!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func friendNameTapped(_ sender: Any) {
        
        if self.delegate != nil {
            self.delegate.inviteFriendToPlaylist(friendName: self.friendName.title(for: .normal) ?? "", friendId: self.friendId.text ?? "", editionRight: self.editionRight.selectedSegmentIndex)
        }
    }
}
