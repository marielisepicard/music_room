//
//  SearchTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 01/02/2021.
//

import UIKit

/*
        SEARCH ITEM
        This subclass display a list of tracks when the user
        makes a search. The search is the result of the Spotify Catalog
 
        Identifier: searchcell
        ViewController: Search
 */

protocol SearchTableViewCellDelegator {
    func callSegueFromCell(cell: UITableViewCell)
}

class SearchTableViewCell: UITableViewCell {

    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var trackCell: UIView!
    

    var playerView: PlayerView!
    
    var trackIndex = Int()
    var trackIds: [String] = []
    
    var delegate: SearchTableViewCellDelegator!

    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playTrack(sender:)))
        self.trackCell?.addGestureRecognizer(tapGesture)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @objc func playTrack(sender: UITapGestureRecognizer) {
        if self.delegate != nil {
            playerView.playTrack(trackURI: trackIds, trackIndex: trackIndex, context: "Search", position: 0)
        }
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        if(self.delegate != nil){
            self.delegate.callSegueFromCell(cell: self)
        }
    }
}
