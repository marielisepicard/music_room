//
//  PlaylistInvitesTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 15/02/2021.
//

import UIKit

protocol AcceptPlaylistInvitDelegator {
    func acceptInvit(playlistId: String)
}

class PlaylistInvitesTableViewCell: UITableViewCell {

    var delegate: AcceptPlaylistInvitDelegator!

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var hostPseudo: UILabel!
    @IBOutlet weak var playlistId: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.acceptInvit(playlistId: self.playlistId.text ?? "")
        }
    }
}
