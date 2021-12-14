//
//  DiscussionfriendsCell.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 24/03/2021.
//

import Foundation
import UIKit

protocol MyDiscussionFriendDelegator {
    func openFriendDiscussion(indexCell: Int)
}

class DiscussionfriendCell: UITableViewCell {
    @IBOutlet weak var friendPseudo: UILabel!
    @IBOutlet weak var cellView: UIView!
    var cellIndex: Int!
    var delegate: MyDiscussionFriendDelegator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(friendTappedGesture))
        self.cellView.addGestureRecognizer(tapGesture)
    }
    @objc func friendTappedGesture() {
        if self.delegate != nil {
            self.delegate.openFriendDiscussion(indexCell: self.cellIndex)
        }
    }
}
