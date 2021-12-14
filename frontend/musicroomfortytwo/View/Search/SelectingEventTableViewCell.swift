//
//  SelectingEventTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 23/02/2021.
//

import UIKit

/*
        SEARCH ITEM
        Cell subclass to display the list of the user's events
        so that the user can choose one of them and add a track
        in it.
 
        Cell Identifier : PickEvent
        ViewController: SelectEvent
 */

protocol MySelectionOfEventDelegator {
    func addTrackToEvent(_ indexPath: IndexPath)
}

class SelectingEventTableViewCell: UITableViewCell {
    var delegate: MySelectionOfEventDelegator!
    @IBOutlet weak var eventTitle: UILabel!
    @IBOutlet weak var creator: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var coverImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(eventTitleTapped(sender:)))
        self.cellView.addGestureRecognizer(tapGesture)
        // Initialization code
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    @objc func eventTitleTapped(sender: Any) {
        let indexPath = getIndexPath()
        if indexPath != nil && self.delegate != nil {
            self.delegate.addTrackToEvent(indexPath!)
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


