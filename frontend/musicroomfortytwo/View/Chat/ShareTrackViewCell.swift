//
//  ShareTrackViewCell.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 15/04/2021.
//

import Foundation

protocol MyShareTrackCellDelegator {
    func shareTrackToFriend(friendIdx: Int)
}

class ShareTrackViewCell: UITableViewCell {
    @IBOutlet weak var friendPseudo: UILabel!
    @IBOutlet weak var shareTrack: UIButton!
    var delegate: MyShareTrackCellDelegator!
    
    @IBAction func shareTrackButtonTapped(_ sender: UIButton) {
        if self.delegate != nil {
            self.shareTrack.tintColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            self.delegate.shareTrackToFriend(friendIdx: sender.tag)
        }
    }
}
