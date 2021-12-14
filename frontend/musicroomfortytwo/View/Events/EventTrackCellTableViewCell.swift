//
//  EventTrackCellTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 08/02/2021.
//

import UIKit

/*
        EVENTS ITEM
        This subclass display all tracks of an event.
        As a result, the user can see the tracks and
        vote for his favorites !
 
        Identifier: EventTrackCell
        View Controller: ShowSpecificEvent
 */

protocol MyEventTracksDelegator {
    func voteForTrack(cellIndex: Int)
}
 
class EventTrackCellTableViewCell: UITableViewCell {

    @IBOutlet weak var trackImage: UIImageView!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackArtist: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var votesNb: UILabel!
    @IBOutlet weak var trackCell: UIView!
    var delegate: MyEventTracksDelegator!
    
    @IBAction func likeButtonTapped(_ sender: Any) {
        if self.delegate != nil {
            if let myButton = sender as? UIButton {
                if myButton.currentBackgroundImage == UIImage(systemName: "hand.thumbsup") {
                    myButton.setBackgroundImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
//                    votesNb.text = String(Int(votesNb.text) + 1)
                } else {
                    myButton.setBackgroundImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
//                    votesNb.text = String(Int(votesNb.text) - 1)
                }
                self.delegate.voteForTrack(cellIndex: myButton.tag)
            }
        }
    }
}
