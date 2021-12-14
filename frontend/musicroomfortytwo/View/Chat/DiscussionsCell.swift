//
//  DiscussionsCell.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 24/03/2021.
//

import Foundation
import UIKit

protocol MyDiscussionDelegator {
    func openFriendDiscussion(indexCell: Int)
}

class DiscussionsCell: UITableViewCell {
    @IBOutlet weak var friendAvatar: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var lastMsg: UILabel!
    @IBOutlet weak var cellView: UIView!
    var cellIndex: Int!
    var delegate: MyDiscussionDelegator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(discussionTappedGesture))
        self.cellView.addGestureRecognizer(tapGesture)
    }
    @objc func discussionTappedGesture() {
        if self.delegate != nil {
            self.delegate.openFriendDiscussion(indexCell: self.cellIndex)
        }
    }
    
}
