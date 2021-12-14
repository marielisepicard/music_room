//
//  DiscussionMessagesController.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 24/03/2021.
//

import Foundation
import UIKit

struct LocalMessageObject {
    var content: String
    var ownerId: String
    var date: String
    var object: ObjectMessage?
}

struct ObjectMessage {
    var image: UIImage
    var name: String
    var artist: String
}

class DiscussionMessagesController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var writeMessageView: UIView!
    var discussionIdx: Int!
    var vcParent: DiscussionViewController!
    var tabBarView: TabBarViewController!
    var friendId: String!
    var friendPseudo: String!
    var chatMessages = [[LocalMessageObject]]()
    var tracksList: String?
    var tracksNb: Int?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.subviews.forEach { $0.isHidden = true }
        groupingMessagesFromDate()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshTableView), name: NSNotification.Name(rawValue: "refreshDiscussion"), object: nil)
        if vcParent.userDiscussions.discussions.count <= discussionIdx {
            print("Invalid discussison index!")
            self.dismiss(animated: true, completion: nil)
            return
        }
        navigationItem.title = vcParent.userDiscussions.discussions[discussionIdx]!.recipient.pseudo
        navigationController?.navigationBar.prefersLargeTitles = true
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        messageField.delegate = self
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = writeMessageView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        writeMessageView.addSubview(blurEffectView)
        writeMessageView.sendSubviewToBack(blurEffectView)
        self.writeMessageView.backgroundColor = UIColor(white: 0.95, alpha: 0.6)
        self.messageField.backgroundColor = UIColor(white: 0.95, alpha: 0.6)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarView = self.tabBarController as? TabBarViewController
        tabBarView?.playerView.transitionPlayer(visible: false)
    }
    override func viewDidDisappear(_ animated: Bool) {
        if (tabBarView?.playerView.appRemote.isConnected != nil && tabBarView.playerView.appRemote.isConnected == true) {
            tabBarView?.playerView.transitionPlayer(visible: true)
        }
    }
    
    fileprivate func groupingMessagesFromDate() {
        chatMessages.removeAll()
        if vcParent.userDiscussions.discussions.count <= discussionIdx {
            print("Invalid discussison index!")
            self.dismiss(animated: true, completion: nil)
            return
        }
        let groupedMessages = Dictionary(grouping: vcParent.userDiscussions.discussions[discussionIdx]!.messages) { (element) -> Date in
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateFormatter.string(from: formatter.date(from: element.date)!)
            return dateFormatter.date(from: dateString) ?? Date()
        }
        let sortedKeys = groupedMessages.keys.sorted()
        self.tracksList = ""
        self.tracksNb = 0
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            let localMessagesObject = fillLocalMessagesObject(groupedMessages: values)
            chatMessages.append(localMessagesObject)
        }
        addObjectMessage()
    }
    func addObjectMessage() {
        var trackCounter = 0
        if self.tracksNb == 0 || self.tracksList == nil {
            self.view.subviews.forEach { $0.isHidden = false }
            printHistoricMessages()
            return
        }
        GetSeveralTracks.shared.getSeveralTracks(trackslist: tracksList!) { (success) in
            if success != true {
                print("error when calling spotify api")
                return
            }
            for i in 0 ..< self.chatMessages.count {
                for j in 0 ..< self.chatMessages[i].count {
                    if self.chatMessages[i][j].content.contains("sptTrackId") {
                        var trackObject = ObjectMessage(image: UIImage(), name: "", artist: "")
                        trackObject.image = GetSeveralTracks.shared.displayablePlaylist[trackCounter].image
                        trackObject.name = GetSeveralTracks.shared.displayablePlaylist[trackCounter].name
                        trackObject.artist = GetSeveralTracks.shared.displayablePlaylist[trackCounter].artists
                        self.chatMessages[i][j].object = trackObject
                        trackCounter += 1
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.view.subviews.forEach { $0.isHidden = false }
                let lastRow: Int = self.tableView.numberOfRows(inSection: self.tableView.numberOfSections - 1) - 1
                let lastSection: Int = self.tableView.numberOfSections - 1
                let indexPath = IndexPath(row: lastRow, section: lastSection);
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }
        }
    }
    func fillLocalMessagesObject(groupedMessages: [MessageObject]?) -> [LocalMessageObject] {
        var localMessagesObject: [LocalMessageObject] = []
        if groupedMessages == nil {
            return []
        }
        var newLocalMessage = LocalMessageObject(content: "", ownerId: "", date: "", object: nil)
        for i in 0 ..< groupedMessages!.count {
            if groupedMessages![i].content.contains("sptTrackId") {
                if tracksNb == 0 {
                    self.tracksList! = groupedMessages![i].content.components(separatedBy: ":")[1]
                } else {
                    self.tracksList! += "," + groupedMessages![i].content.components(separatedBy: ":")[1]
                }
                self.tracksNb? += 1
            }
            newLocalMessage.content = groupedMessages![i].content
            newLocalMessage.ownerId = groupedMessages![i].ownerId
            newLocalMessage.date = groupedMessages![i].date
            localMessagesObject.append(newLocalMessage)
        }
        return localMessagesObject
    }
    
    
    func printHistoricMessages() {
        if vcParent.userDiscussions.discussions.count <= discussionIdx {
            print("Invalid discussison index!")
            self.dismiss(animated: true, completion: nil)
            return
        }
        if vcParent.userDiscussions.discussions[discussionIdx]!.messages.count == 0 {
            return
        }
        tableView.reloadData()
        let lastRow: Int = self.tableView.numberOfRows(inSection: self.tableView.numberOfSections - 1) - 1
        let lastSection: Int = self.tableView.numberOfSections - 1
        let indexPath = IndexPath(row: lastRow, section: lastSection);
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    @objc func refreshTableView() {
        groupingMessagesFromDate()
    }
    @IBAction func sendMessage(_ sender: Any) {
        sendSocketMessage()
    }
}

extension DiscussionMessagesController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return chatMessages.count
    }
    
    class DateHeaderLabel: UILabel {
        override var intrinsicContentSize: CGSize {
            let originalContentSize = super.intrinsicContentSize
            let height = originalContentSize.height + 12
            layer.cornerRadius = height / 2
            layer.masksToBounds = true
            return CGSize(width: originalContentSize.width + 20, height: height)
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let firstMessageInSection = chatMessages[section].first {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let dateString = dateFormatter.string(from: formatter.date(from: firstMessageInSection.date)!)
            let label = DateHeaderLabel()
            label.backgroundColor = #colorLiteral(red: 0.3781698024, green: 1, blue: 0.4678101245, alpha: 1)
            label.textColor = .black
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.boldSystemFont(ofSize: 14)
            label.text = dateString
            
            let containerView = UIView()
            containerView.addSubview(label)
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            return containerView
        }
        return nil
    }
     
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DiscussionMessagesCell") as? DiscussionMessageCell else {
            return UITableViewCell()
        }
        if chatMessages[indexPath.section][indexPath.row].object != nil {
            cell.trackObject = chatMessages[indexPath.section][indexPath.row].object
            cell.messageLabel.text = ""
        } else {
            cell.trackObject = nil
            cell.messageLabel.text = chatMessages[indexPath.section][indexPath.row].content
        }
        if chatMessages[indexPath.section][indexPath.row].ownerId == UserDefaults.standard.string(forKey: "userId")! {
            cell.isIncoming = true
        } else {
            cell.isIncoming = false
        }
        cell.delegate = self
        return cell
    }
    func sendSocketMessage() {
        if messageField.text == "" {
            return
        }
        let userId = UserDefaults.standard.string(forKey: "userId")!
        let userPseudo = UserDefaults.standard.string(forKey: "userPseudo")!
        if vcParent.userDiscussions.discussions.count <= discussionIdx {
            print("Invalid discussison index!")
            self.dismiss(animated: true, completion: nil)
        }
        let friendId = vcParent.userDiscussions.discussions[discussionIdx]!.recipient.id
        SocketIOManager.shared.sendMsg(userId: userId, userPseudo: userPseudo, friendId: friendId, message: messageField.text!)
        addMessageToDiscussion(userId: userId, content: messageField.text!)
        groupingMessagesFromDate()
        messageField.text = ""
    }
    func addMessageToDiscussion(userId: String, content: String) {
        let nowDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let message = MessageObject(content: content, ownerId: userId, date: formatter.string(from: nowDate))
        if vcParent.userDiscussions.discussions.count <= discussionIdx {
            print("Invalid discussison index!")
            self.dismiss(animated: true, completion: nil)
        }
        vcParent.userDiscussions.discussions[discussionIdx]!.messages.append(message)
    }
}

extension DiscussionMessagesController: MyDiscussionMessageDelegator {
    func playTrack(cell: DiscussionMessageCell) {
        guard let indexPath = self.tableView.indexPath(for: cell) else {
            print("error when retrieving the cell!")
            return
        }
        if chatMessages[indexPath.section][indexPath.row].object == nil {
            print("nothing to play...")
            return
        }
        let trackId = chatMessages[indexPath.section][indexPath.row].content.components(separatedBy: ":")[1]
        var trackUriArr: [String] = []
        trackUriArr.append(trackId)
        DispatchQueue.main.async {
            self.tabBarView?.playerView.playTrack(trackURI: trackUriArr, trackIndex: 0, context: "chat", position: 0)
            self.tabBarView?.playerView.transitionPlayer(visible: false)
        }
    }
}

extension DiscussionMessagesController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendSocketMessage()
        return true
    }
    @objc func handleTap() {
        messageField.resignFirstResponder()
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
