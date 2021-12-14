//
//  PublicEventsTableViewCell.swift
//  musicroomfortytwo
//
//  Created by ML on 06/02/2021.
//

import UIKit

/*
        EVENTS ITEM
        This subclass display a list of every public events
        so that the user can see them and join those which
        interest him !
 
        Identifier: PublicEvents
        View Controller: PublicEvents
 */

protocol PublicEventsDelegator {
    func eventSelected(cell: PublicEventsTableViewCell)
}

class PublicEventsTableViewCell: UITableViewCell {

    @IBOutlet weak var eventId: UILabel!
    @IBOutlet weak var button: UIButton!
    var delegate: PublicEventsDelegator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        if self.delegate != nil {
            self.delegate.eventSelected(cell: self)
        }
    }
}
