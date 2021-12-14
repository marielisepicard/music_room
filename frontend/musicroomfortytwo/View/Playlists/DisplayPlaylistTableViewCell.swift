//
//  DisplayPlaylistTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 02/02/2021.
//

import UIKit

/*
        PLAYLIST ITEM
        This subclass display every playlist that :
        - has been created by the user
        - has been followed by the user
        - is associated to the user (admins)
        As a result, the user can consult all of "his" playlists
        
        Cell identifier : Playlist Cell
        View Controller : Playlist
 */

protocol MyPlaylistListDelegator {
    func callSegueFromPlaylistCell(cell: UITableViewCell)
}

class DisplayPlaylistTableViewCell: UITableViewCell {

    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var playlistTitle: UILabel!
    @IBOutlet weak var playlistCreator: UILabel!
    var playlistId = String()

    @IBOutlet weak var playlistCell: UIView!
    
    
    var delegate: MyPlaylistListDelegator!

    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(displayPlaylistDetail(sender:)))
        self.playlistCell?.addGestureRecognizer(tapGesture)
    }

    @objc func displayPlaylistDetail(sender: UITapGestureRecognizer) {
        if self.delegate != nil {
            UserDefaults.standard.setValue(self.playlistTitle.text!, forKey: "titleOfSelectedPlaylist")
            UserDefaults.standard.setValue(self.playlistId, forKey: "idOfSelectedPlaylist")
            self.delegate.callSegueFromPlaylistCell(cell: self)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
