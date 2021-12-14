//
//  Discussion.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 24/03/2021.
//

import Foundation
import UIKit

class Discussion {
    var recipient: RecipientObject!
    var messages: [MessageObject] = []
    
    init(){}
    init(_ discussion: DiscussionObject) {
        self.recipient = discussion.recipient
        for i in 0 ..< discussion.messages.count {
            self.messages.append(MessageObject(content: discussion.messages[i].content, ownerId: discussion.messages[i].ownerId, date: discussion.messages[i].date))
        }
    }
    func update(_ discussion: DiscussionObject) {
        self.recipient = discussion.recipient
        for i in 0 ..< discussion.messages.count {
            self.messages.append(MessageObject(content: discussion.messages[i].content, ownerId: discussion.messages[i].ownerId, date: discussion.messages[i].date))
        }
    }
}

