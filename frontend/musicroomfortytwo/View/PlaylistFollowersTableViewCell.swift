//
//  PlaylistFollowersTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 15/02/2021.
//

import UIKit

protocol DisplayFollowersDelegator {
    func associateAFollower(friendId: String)
}


class PlaylistFollowersTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var pseudoLabel: UILabel!
    
    var delegate: DisplayFollowersDelegator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    // identifier : PlaylistFollower

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.associateAFollower(friendId: self.idLabel.text!)
        }
    }
    
}
