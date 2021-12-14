//
//  FriendPlaylistsTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 13/02/2021.
//

import UIKit

protocol FriendsPlaylistDelegator {
    func displayFriendPlaylist(playlistId: String, playlistTitle: String)
}

class FriendPlaylistsTableViewCell: UITableViewCell {

    @IBOutlet weak var playlistId: UILabel!
    @IBOutlet weak var playlistTitle: UILabel!
    @IBOutlet weak var cellView: UIView!
    var delegate: FriendsPlaylistDelegator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playlistTappedGesture(sender:)))
        self.cellView?.addGestureRecognizer(tapGesture)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @objc func playlistTappedGesture(sender: UITapGestureRecognizer) {
        if self.delegate != nil {
            self.delegate.displayFriendPlaylist(playlistId: self.playlistId.text!, playlistTitle: self.playlistTitle.text!)
        }
    }
}
