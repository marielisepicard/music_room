//
//  ShowSpecificEventViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 06/02/2021.
//

import UIKit
import MapKit
import CoreLocation

class ShowSpecificEventViewController: UIViewController {
    
    @IBOutlet weak var playlistImg1: UIImageView!
    @IBOutlet weak var playlistImg2: UIImageView!
    @IBOutlet weak var playlistImg3: UIImageView!
    @IBOutlet weak var playlistImg4: UIImageView!
    @IBOutlet weak var eventName: UILabel!
    @IBOutlet weak var eventPlace: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noEventLabel: UILabel!
    @IBOutlet weak var leaveJoinButton: UIButton!
    @IBOutlet weak var inviteFriendButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var participantButton: UIButton!
    @IBOutlet weak var eventStatus: UILabel!
    
    let locationManager = CLLocationManager()
    var event: Event? = Event()
    var userEventRight: String?
    var userCanVote: Bool?
    var userLocation: CLLocationCoordinate2D?
    var userEventDistance: Double?
    var firstTimeOpen: Bool?
    var selectedTrackTitle: String?
    var selectedTrackId: String?
    
    var tabBarView: TabBarViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarView = self.tabBarController as? TabBarViewController
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        self.tableView.addGestureRecognizer(longPressGesture)
        let name = Notification.Name(rawValue: "refreshSpecificEventData")
        NotificationCenter.default.addObserver(self, selector: #selector(receivedRefreshNotif), name: name, object: nil)
    }
    override func viewDidDisappear(_ animated: Bool) {
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
        self.view.subviews.forEach { $0.isHidden = true }
        firstTimeOpen = true
        loadSpecificEventData()
    }
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: self.tableView)
        let indexPath = self.tableView.indexPathForRow(at: p)
        if indexPath == nil {
            print("Long press on tableView, not row!")
        } else if longPressGesture.state == UIGestureRecognizer.State.began {
            print("long press on row, at \(indexPath!.row)")
            self.selectedTrackId = self.event!.tracks[indexPath!.row].id
            self.selectedTrackTitle = self.event!.tracks[indexPath!.row].name
            performSegue(withIdentifier: "ShareTrackFriend", sender: self)
        }
    }
    @objc func receivedRefreshNotif() {
        loadSpecificEventData()
    }
    func loadSpecificEventData() {
        if event == nil {
            return
        }
        self.event!.getSpecifiedEvent() { (success, code) in
            if success == false {
                self.event = nil
            } else {
                if self.event!.status == "started" {
                    if self.firstTimeOpen == true {
                        self.playRadio()
                        self.firstTimeOpen = false
                    } else {
                        if self.event!.tracks.count == 0 {
                            self.firstTimeOpen = true
                        } else {
                            self.refreshPlayedTrackList()
                        }
                    }
                }
                if self.event!.physicalEvent == true {
                    self.setLocation()
                }
                self.retrieveUserRightFromEvent()
                self.checkAllVotingPrerequisites()
            }
            let notifName = Notification.Name(rawValue: "refreshParticipantEventData")
            let notification = Notification(name: notifName)
            NotificationCenter.default.post(notification)
            DispatchQueue.main.async {
                self.displayEvent()
            }
        }
        
    }
    func refreshPlayedTrackList() {
        print("In refresh track list")
        var tracksUri: [String] = []
        for i in 0 ..< self.event!.tracks.count {
            tracksUri.append(self.event!.tracks[i].id!)
        }
        tabBarView.playerView.refreshReadingList(trackURI: tracksUri)
    }
    func playRadio() {
        
        if self.event!.tracks.count > 0 {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            let timeBeginListeningDate = formatter.date(from: event!.tracks[0].timeBeginListening!)!
            print("Time begin Listening track: \(timeBeginListeningDate)")
            print("current date \(Date())")
            print("difference time: \(Date() - timeBeginListeningDate)")
            var tracksUri: [String] = []
            for i in 0 ..< self.event!.tracks.count {
                tracksUri.append(self.event!.tracks[i].id!)
            }
            let position = Int((Date() - timeBeginListeningDate) * 1000)
            DispatchQueue.main.async {
                self.tabBarView.playerView.playTrack(trackURI: tracksUri, trackIndex: 0, context: "Event", position: position)
            }
        }
    }
    func displayEvent() {
        if self.event != nil && self.event!.name != nil {
            UIView.transition(with: self.view, duration: 0.35, options: .transitionCrossDissolve, animations: displaySpecificEvent)
        } else if self.event != nil && self.event!.name == nil {
            displayEmptyEvent()
        } else {
            UIView.transition(with: self.view, duration: 0.35, options: .transitionCrossDissolve, animations: displayDeleteEvent)
        }
    }
    func displayEmptyEvent() {
        self.view.subviews.forEach { $0.isHidden = true }
        self.navigationController?.isNavigationBarHidden = false
    }
    func displayDeleteEvent() {
        self.view.subviews.forEach { $0.isHidden = true }
        self.noEventLabel.isHidden = false
        self.navigationController?.isNavigationBarHidden = false
    }
    func displaySpecificEvent() {
        self.tableView.reloadData()
        self.view.subviews.forEach { $0.isHidden = false }
        self.noEventLabel.isHidden = true
        self.displayPlaylistImg()
        self.eventName.text = self.event?.name
        self.eventStatus.text = "(\(self.event!.status!))"
        if userEventRight ==  nil {
            leaveJoinButton.setBackgroundImage(UIImage(systemName: "arrow.right.square"), for: .normal)
            leaveJoinButton.tintColor = UIColor(red:91/255, green:204/255, blue:14/255, alpha: 1)
        } else {
            leaveJoinButton.setBackgroundImage(UIImage(systemName: "arrow.left.square"), for: .normal)
            leaveJoinButton.tintColor = UIColor(red:224/255, green:53/255, blue:1/255, alpha: 1)
        }
        self.displayLocationData()
        if self.event?.public == false && self.userEventRight != "admin" {
            self.inviteFriendButton.isHidden = true
        }
        if self.userEventRight != "admin" {
            self.settingsButton.isHidden = true
            self.participantButton.isHidden = true
        }
    }
    func displayLocationData() {
        self.eventPlace.text = self.event?.place
        if self.event?.physicalEvent == true && userEventDistance != nil {
            if userEventDistance! < 1000 {
                self.eventPlace.text = "\(self.event!.place!) - \(String(Int(userEventDistance!))) mètres"
            } else {
                var distanceInKilometers = userEventDistance! / 1000
                distanceInKilometers = Double(round(1000*distanceInKilometers)/1000)
                self.eventPlace.text = "\(self.event!.place!) - \(String(distanceInKilometers)) kilomètres"
            }
        }
    }
    func checkAllVotingPrerequisites() {
        self.userCanVote = true
        if self.event!.status != "started" {
            self.userCanVote = false
        }
        if self.userEventRight == nil || (self.userEventRight == "guest" && self.event!.votingPrerequisites == true) {
            self.userCanVote = false
        }
    }
    func displayPlaylistImg() {
        if self.event!.tracks.count > 0 {
            if let imageUrl = self.event!.tracks[0].coverUrl {
                self.playlistImg1.image = UIImage(url: URL(string: imageUrl))
            } else {
                self.playlistImg1.image = UIImage(systemName: "music.note")
            }
        } else {
            self.playlistImg1.image = UIImage(systemName: "music.note")
        }
        if self.event!.tracks.count > 1 {
            if let imageUrl = self.event!.tracks[1].coverUrl {
                self.playlistImg2.image = UIImage(url: URL(string: imageUrl))
            } else {
                self.playlistImg2.image = UIImage(systemName: "music.note")
            }
        } else {
            self.playlistImg2.image = UIImage(systemName: "music.note")
        }
        if self.event!.tracks.count > 2 {
            if let imageUrl = self.event!.tracks[2].coverUrl {
                self.playlistImg3.image = UIImage(url: URL(string: imageUrl))
            } else {
                self.playlistImg3.image = UIImage(systemName: "music.note")
            }
        } else {
            self.playlistImg3.image = UIImage(systemName: "music.note")
        }
        if self.event!.tracks.count > 3 {
            if let imageUrl = self.event!.tracks[3].coverUrl {
                self.playlistImg4.image = UIImage(url: URL(string: imageUrl))
            } else {
                self.playlistImg4.image = UIImage(systemName: "music.note")
            }
        } else {
            self.playlistImg4.image = UIImage(systemName: "music.note")
        }
    }
    func retrieveUserRightFromEvent() {
        userEventRight = nil
        for i in 0 ..< event!.guestsInfo!.count {
            if (event!.guestsInfo![i].userId == UserDefaults.standard.string(forKey: "userId")) {
                userEventRight = event!.guestsInfo![i].right
            }
        }
    }
    @IBAction func joinEventButtonTapped(_ sender: Any) {
        if userEventRight == nil {
            leaveJoinButton.setBackgroundImage(UIImage(systemName: "arrow.left.square"), for: .normal)
            leaveJoinButton.tintColor = UIColor(red:224/255, green:53/255, blue:1/255, alpha: 1)
            event!.joinAnEvent() { (success, code) in
                self.presentJoinAlert(success: success, code: code)
            }
        } else {
            let alertVC: UIAlertController
            alertVC = UIAlertController(title: title, message: "Voulez-vous vraiment quitter l'évènement ?", preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "Oui", style: UIAlertAction.Style.default, handler: leaveEvent))
            alertVC.addAction(UIAlertAction(title: "Non", style: UIAlertAction.Style.default, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }
    }
    func leaveEvent(_ sender: UIAlertAction) {
        leaveJoinButton.setBackgroundImage(UIImage(systemName: "arrow.right.square"), for: .normal)
        leaveJoinButton.tintColor = UIColor(red:91/255, green:204/255, blue:14/255, alpha: 1)
        event!.leaveAnEvent() { (success, code) in
            self.presentLeaveAlert(success: success, code: code)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ShowSpecificEventParameterViewController {
            vc.vcParent = self
        } else if let vc = segue.destination as? EventParticipantViewController {
            vc.vcParent = self
        } else if let vc = segue.destination as? InviteFriendInEventViewController {
            vc.vcParent = self
        } else if let vc = segue.destination as? ShareTrackViewController {
            if self.selectedTrackId == nil || self.selectedTrackTitle == nil {
                print("No selected track")
                return
            } else {
                vc.trackId = self.selectedTrackId!
                vc.trackTitle = self.selectedTrackTitle!
            }
        }
    }
}

extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}

extension ShowSpecificEventViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (event == nil || (event!.tracks.count > 0 && event!.tracks[0].name == nil)) {
            return 0
        } else {
            return self.event!.tracks.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EventTrackCell") as? EventTrackCellTableViewCell else {
            return UITableViewCell()
        }
        cell.trackTitle.text = event!.tracks[indexPath.row].name
        cell.trackArtist.text = event!.tracks[indexPath.row].artist
        cell.votesNb.text = String(event!.tracks[indexPath.row].nbVotes!)
        cell.trackImage.image = event!.tracks[indexPath.row].coverImg
        cell.delegate = self
        if userCanVote == true {
            cell.likeButton.isHidden = false
            if event!.tracks[indexPath.row].didUserVote == true {
                cell.likeButton.setBackgroundImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            } else {
                cell.likeButton.setBackgroundImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            }
            cell.likeButton.tag = indexPath.row
        } else {
            cell.likeButton.isHidden = true
        }
        if event!.status == "started" && indexPath.row == 0 {
            cell.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            cell.likeButton.isEnabled = false
        }
        return cell
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if userEventRight != nil && userEventRight != "admin" {
                let alertVC: UIAlertController
                alertVC = UIAlertController(title: title, message: "Vous ne pouvez pas supprimer une musique d'une playlist dont vous n'êtes pas admin", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                present(alertVC, animated: true, completion: nil)
                return
            }
            tableView.beginUpdates()
            let tmpTrack = self.event!.tracks[indexPath.row].id!
            self.event!.tracks.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            self.event!.deleteTrack(trackId: tmpTrack) { (success, code) in
                if (success) {
                    print("Track successfully deleted")
                } else {
                    print("Cannot delete track")
                    self.loadSpecificEventData()
                }
            }
        }
    }
}

extension ShowSpecificEventViewController: MyEventTracksDelegator {
    func voteForTrack(cellIndex: Int) {
        if CLLocationManager.locationServicesEnabled() == false {
            setLocation()
        }
        if event!.tracks[cellIndex].didUserVote == false {
            event!.voteForATrack(trackId: event!.tracks[cellIndex].id!, userLoc: userLocation) { (success) in
                if success != 0 {
                    self.presentVoteAlert(nb: success)
                }
            }
        } else if event!.tracks[cellIndex].didUserVote == true {
            event!.unvoteForATrack(trackId: event!.tracks[cellIndex].id!, userLoc: userLocation) { (success) in
                if success != 0 {
                    self.presentVoteAlert(nb: success)
                }
            }
        }
    }
}

extension ShowSpecificEventViewController: CLLocationManagerDelegate {
    func setLocation() {
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if event == nil || event!.physicalEvent == false {
            return
        }
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let eventCoord = CLLocation(latitude: event!.geoLoc!.lat, longitude: event!.geoLoc!.long)
        let userCoord = CLLocation(latitude: locValue.latitude, longitude: locValue.longitude)
        userEventDistance = eventCoord.distance(from: userCoord)
        userLocation = locValue
        displayLocationData()
    }
}

extension ShowSpecificEventViewController {
    private func presentVoteAlert(nb: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if nb == 2 {
            title = "Localisation invalide 😢"
            message = "Vous devez vous trouver a l'évènement pour voter"
         } else {
            title = "Erreur Interne 😢"
            message = "Nous avons un problème technique... Reviens plus tard !"
        }
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            if nb == 1 {
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
    private func presentJoinAlert(success: Bool, code: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if success == false {
            title = "Erreur Interne 😢"
            message = "Nous avons un problème technique... Reviens plus tard !"
            alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alertVC, animated: true, completion: nil)
        }
    }
    private func presentLeaveAlert(success: Bool, code: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if success == true {
            title = "Évènement quitté"
            message = "Vous ne faites plus partie de cet évènement"
        } else {
            if code == 1 {
                title = "Vous ne pouvez pas quitté l'évènement 😢"
                message = "L'évènement doit compter au moins un administrateur"
             } else {
                title = "Erreur Interne 😢"
                message = "Nous avons un problème technique... Reviens plus tard !"
            }
        }
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction) in
            if success == true {
                self.navigationController?.popViewController(animated: true)
            }
        })
        present(alertVC, animated: true, completion: nil)
    }
}
