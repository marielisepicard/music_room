//
//  UsersEventsTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 06/02/2021.
//

import UIKit

protocol UsersEventDelegator {
    func eventSelected(indexPath: IndexPath)
}

class UsersEventsTableViewCell: UITableViewCell {

    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var creator: UILabel!
    @IBOutlet weak var eventCell: UIView!
    @IBOutlet weak var coverImage: UIImageView!
    var delegate: UsersEventDelegator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playlistTappedGesture(sender:)))
        self.eventCell?.addGestureRecognizer(tapGesture)
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    @objc func playlistTappedGesture(sender: UITapGestureRecognizer) {
        if self.delegate != nil {
            let indexPath = getIndexPath()
            if indexPath !=  nil {
                self.delegate.eventSelected(indexPath: indexPath!)
            }
        }
    }
    func getIndexPath() -> IndexPath? {
        guard let superView = self.superview as? UITableView else {
            print("superview is not a UITableView - getIndexPath")
            return nil
        }
        let indexPath = superView.indexPath(for: self)
        return indexPath
    }
}
