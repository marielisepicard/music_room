//
//  MREvent.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 05/03/2021.
//

import Foundation

class Event {
    var id: String?
    var place: String?
    var name: String?
    var beginDate: String?
    var endDate: String?
    var visibility: String?
    var votingPrerequisites: Bool?
    var physicalEvent: Bool?
    var tracks: [TrackInfo]?
    
    init(){}
}
