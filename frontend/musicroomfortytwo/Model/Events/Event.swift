//
//  Event.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 05/03/2021.
//

import Foundation
import UIKit

struct TrackInfo {
    var id: String?
    var name: String?
    var artist: String?
    var nbVotes: Int?
    var didUserVote: Bool?
    var timeBeginListening: String?
    var uri: String?
    var duration_ms: Int?
    var coverUrl: String?
    var coverImg: UIImage?
}

class Event {
    var id: String?
    var name: String?
    var creator: String?
    var `public`: Bool?
    var status: String?
    var votingPrerequisites: Bool?
    var musicalStyle: String?
    var guestsNumber: Int?
    var guestsInfo: [GuestInfos]?
    var tracks: [TrackInfo] = []
    var physicalEvent: Bool?
    var place: String?
    var geoLoc: Geoloc?
    var beginDate: String?
    var endDate: String?
    var coverEvent: UIImage?
    
    init(){}
    init(event: EventObject) {
        self.id = event._id
        self.name = event.name
        self.creator = event.creator
        self.public = event.publicFlag
        self.status = event.status
        self.votingPrerequisites = event.votingPrerequisites
        self.musicalStyle = event.musicalStyle
        self.guestsNumber = event.guestsNumber
        self.guestsInfo = event.guestsInfo
        self.physicalEvent = event.physicalEvent
        self.place = event.place
        self.geoLoc = event.geoLoc
        self.beginDate = event.beginDate
        self.endDate = event.endDate
        for i in 0..<event.tracksInfo.count {
            self.tracks.append(TrackInfo(id: event.tracksInfo[i].trackId, nbVotes: event.tracksInfo[i].votesNumber, didUserVote: event.tracksInfo[i].userVote, timeBeginListening: event.tracksInfo[i].timeBeginListening))
        }
    }
    func update(event: EventObject) {
        self.id = event._id
        self.name = event.name
        self.creator = event.creator
        self.public = event.publicFlag
        self.status = event.status
        self.votingPrerequisites = event.votingPrerequisites
        self.musicalStyle = event.musicalStyle
        self.guestsNumber = event.guestsNumber
        self.guestsInfo = event.guestsInfo
        self.physicalEvent = event.physicalEvent
        self.place = event.place
        self.geoLoc = event.geoLoc
        self.beginDate = event.beginDate
        self.endDate = event.endDate
        self.tracks.removeAll()
        for i in 0..<event.tracksInfo.count {
            self.tracks.append(TrackInfo(id: event.tracksInfo[i].trackId, nbVotes: event.tracksInfo[i].votesNumber, didUserVote: event.tracksInfo[i].userVote, timeBeginListening: event.tracksInfo[i].timeBeginListening))
        }
    }
}
