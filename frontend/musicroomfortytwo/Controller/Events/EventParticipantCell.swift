//
//  File.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 12/03/2021.
//

import Foundation
import UIKit

protocol MyEventParticipantDelegator {
    func updateUserRight(cellSegment: UISegmentedControl)
}

class EventParticipantCell: UITableViewCell {
    @IBOutlet weak var userPseudo: UILabel!
    @IBOutlet weak var userRight: UISegmentedControl!
    var delegate: MyEventParticipantDelegator!
    
    @IBAction func segmentedControlTapped(_ sender: UISegmentedControl) {
        self.delegate.updateUserRight(cellSegment: sender)
    }
}
