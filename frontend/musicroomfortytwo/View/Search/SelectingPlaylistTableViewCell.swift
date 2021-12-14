//
//  SelectingPlaylistTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 03/02/2021.
//

import UIKit

/*
        SEARCH ITEM
        Cell subclass to display the list of the user's playlists
        so that the user can choose one of them and add a track
        in it.
 
        Cell Identifier : PickPlaylist
        ViewController: SelectPlaylist
 */

protocol MySelectionOfPlaylistListDelegator {
    func addTrackAndComeBack(cell: UITableViewCell)
}

class SelectingPlaylistTableViewCell: UITableViewCell {
    
    @IBOutlet weak var playlistImage: UIImageView!
    @IBOutlet weak var lblPlaylist: UILabel!
    @IBOutlet weak var lblCreator: UILabel!
    var playlistId = String()
    @IBOutlet weak var cell: UIView!
    
    
    var delegate: MySelectionOfPlaylistListDelegator!

    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addToPlaylist))
        self.cell?.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    @objc func addToPlaylist() {
        if self.delegate != nil {
            UserDefaults.standard.setValue(lblPlaylist.text, forKey: "titleOfSelectedPlaylist")
            UserDefaults.standard.setValue(playlistId, forKey: "idOfSelectedPlaylist")
            self.delegate.addTrackAndComeBack(cell: self)
        }
    }
}
