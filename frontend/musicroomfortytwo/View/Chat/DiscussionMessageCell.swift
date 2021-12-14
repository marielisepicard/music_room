//
//  DiscussionMessageCell.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 24/03/2021.
//

import Foundation
import UIKit

protocol MyDiscussionMessageDelegator {
    func playTrack(cell: DiscussionMessageCell)
}

class DiscussionMessageCell: UITableViewCell {
    let messageLabel = UILabel()
    var coverImage = UIImageView(frame: CGRect(x: 0, y: 0, width: 125, height: 125))
    var imageObject = UIImage()
    var titleCoverLabel = UILabel()
    var artistCoverLabel = UILabel()
    let bubbleBackgroundView = UIView()
    var objtContraints: [NSLayoutConstraint]!
    var msgContraints: [NSLayoutConstraint]!
    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    var delegate: MyDiscussionMessageDelegator!
    var trackObject: ObjectMessage! {
        didSet {
            if trackObject != nil {
                NSLayoutConstraint.deactivate(msgContraints)
                NSLayoutConstraint.activate(objtContraints)
                coverImage.image = trackObject.image
                titleCoverLabel.text = trackObject.name
                artistCoverLabel.text = trackObject.artist
                titleCoverLabel.font = UIFont.boldSystemFont(ofSize: 18)
                artistCoverLabel.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
            } else {
                coverImage.image = nil
                titleCoverLabel.text = nil
                artistCoverLabel.text = nil
                NSLayoutConstraint.deactivate(objtContraints)
                NSLayoutConstraint.activate(msgContraints)

            }
            self.layoutIfNeeded()
        }
    }
    var isIncoming: Bool! {
        didSet {
            if trackObject != nil {
                bubbleBackgroundView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                bubbleBackgroundView.layer.borderWidth = 2
                bubbleBackgroundView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                messageLabel.textColor = .black
            }  else {
                bubbleBackgroundView.backgroundColor = isIncoming ? #colorLiteral(red: 0.1347074367, green: 0.7643887012, blue: 0.001176435789, alpha: 1) : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                bubbleBackgroundView.layer.borderWidth = 0
                messageLabel.textColor = isIncoming ? .white : .black
            }
            if isIncoming {
                leadingConstraint.isActive = false
                trailingConstraint.isActive = true
            } else {
                leadingConstraint.isActive = true
                trailingConstraint.isActive = false
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(discussionCellTapped))
        self.addGestureRecognizer(tapGesture)
        addSubview(bubbleBackgroundView)
        backgroundColor = .clear
        bubbleBackgroundView.layer.cornerRadius = 12
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        defineMsgConstraints()
        defineCoverContraints()
        leadingConstraint = bubbleBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
        trailingConstraint = bubbleBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
    }
    func defineMsgConstraints() {
        addSubview(messageLabel)
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        msgContraints = [messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
                           messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
                           messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
                           bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -10),
                           bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -10),
                           bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
                           bubbleBackgroundView.widthAnchor.constraint(equalTo: messageLabel.widthAnchor, constant: 18)]
    }
    func defineCoverContraints() {
        addSubview(coverImage)
        addSubview(titleCoverLabel)
        addSubview(artistCoverLabel)
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        titleCoverLabel.translatesAutoresizingMaskIntoConstraints = false
        artistCoverLabel.translatesAutoresizingMaskIntoConstraints = false
        titleCoverLabel.adjustsFontSizeToFitWidth = true
        titleCoverLabel.minimumScaleFactor = 0.2
        titleCoverLabel.numberOfLines = 0
        objtContraints = [coverImage.topAnchor.constraint(equalTo: topAnchor, constant: 16),
                           coverImage.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),
                           coverImage.widthAnchor.constraint(equalToConstant: 80),
                           coverImage.heightAnchor.constraint(equalToConstant: 80),
                           titleCoverLabel.topAnchor.constraint(equalTo: coverImage.topAnchor),
                           titleCoverLabel.leadingAnchor.constraint(equalTo: coverImage.trailingAnchor, constant: 10),
                           titleCoverLabel.trailingAnchor.constraint(equalTo: bubbleBackgroundView.trailingAnchor, constant: -5),
                           artistCoverLabel.topAnchor.constraint(equalTo: titleCoverLabel.bottomAnchor, constant: 8),
                           artistCoverLabel.leadingAnchor.constraint(equalTo: coverImage.trailingAnchor, constant: 10),
                           artistCoverLabel.trailingAnchor.constraint(equalTo: bubbleBackgroundView.trailingAnchor, constant: -5),
                           bubbleBackgroundView.topAnchor.constraint(equalTo: coverImage.topAnchor, constant: -10),
                           bubbleBackgroundView.leadingAnchor.constraint(equalTo: coverImage.leadingAnchor, constant: -10),
                           bubbleBackgroundView.bottomAnchor.constraint(equalTo: coverImage.bottomAnchor, constant: 10),
                           bubbleBackgroundView.widthAnchor.constraint(equalToConstant: 250)]
    }
    @objc func discussionCellTapped() {
        if self.delegate != nil {
            self.delegate.playTrack(cell: self)
        }
    }
}
