//
//  FoundEventsCellTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 08/02/2021.
//

import UIKit

/*
        EVENTS ITEM
        This subclass display the result of an event search (when
        the user wants to find a public event, he can make a search).
 
        Identifier: FoundEventsSearch
        Controller: JoinAnEvent
 */

protocol MyPublicEventDelegator {
    func openPublicEvent(indexCell: Int)
}

class PublicEventTableViewCell: UITableViewCell {
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventCreator: UILabel!
    @IBOutlet weak var eventCellView: UIView!
    var cellIndex: Int!
    var delegate: MyPublicEventDelegator!

    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(publicEventTappedGesture))
        self.eventCellView.addGestureRecognizer(tapGesture)
    }
    @objc func publicEventTappedGesture() {
        if self.delegate != nil {
            self.delegate.openPublicEvent(indexCell: self.cellIndex)
        }
    }
}
