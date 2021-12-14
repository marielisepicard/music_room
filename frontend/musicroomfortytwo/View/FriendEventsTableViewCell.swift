//
//  FriendEventsTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 13/02/2021.
//

import UIKit

protocol FriendsEventDelegator {
    func displayFriendEvent(eventId: String, eventTitle: String)
}

class FriendEventsTableViewCell: UITableViewCell {
    @IBOutlet weak var eventId: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var eventTitle: UILabel!
    var delegate: FriendsEventDelegator!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(eventTappedGesture(sender:)))
        self.cellView?.addGestureRecognizer(tapGesture)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @objc func eventTappedGesture(sender: UITapGestureRecognizer) {
        if self.delegate != nil {
            self.delegate.displayFriendEvent(eventId: self.eventId.text!, eventTitle: self.eventTitle.text!)
        }
    }
}
