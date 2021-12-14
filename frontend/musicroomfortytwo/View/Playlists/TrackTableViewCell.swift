//
//  TrackTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 02/02/2021.
//

import UIKit

/*
        PLAYLIST ITEM
        This subclass display every tracks of a selected playlist
        So that the user can see everything that is contained on a playlist
 
        Cell identifier : TrackCell
        View Controller : Show Playlist
 */

class TrackTableViewCell: UITableViewCell {

    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackArtist: UILabel!
    @IBOutlet weak var trackCell: UIView!
    var trackIndex = Int()
    var trackIds: [String] = []
    var playerView: PlayerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playTrack(sender:)))
        self.trackCell?.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @objc func playTrack(sender: UITapGestureRecognizer) {
        playerView?.playTrack(trackURI: trackIds, trackIndex: trackIndex, context: "Playlist", position: 0)
    }
}
