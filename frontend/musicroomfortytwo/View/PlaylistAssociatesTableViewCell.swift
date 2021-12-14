//
//  PlaylistAssociatesTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 17/02/2021.
//

import UIKit

protocol ChangeDelegator {
    func changeUserRight(friendId: String)
}

class PlaylistAssociatesTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var friendId: UILabel!
    @IBOutlet weak var friendPseudo: UILabel!
    
    var delegate: ChangeDelegator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        if delegate != nil {
            self.delegate.changeUserRight(friendId: self.friendId.text!)
        }
    }
}
