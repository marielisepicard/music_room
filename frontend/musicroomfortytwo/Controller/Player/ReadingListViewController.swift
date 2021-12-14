//
//  ReadingListViewController.swift
//  musicroomfortytwo
//
//  Created by Jerome on 09/04/2021.
//

import UIKit

class ReadingListViewController: UIViewController {

    
    @IBOutlet weak var imgTrackCover: UIImageView!
    @IBOutlet weak var lblTrackTitle: UILabel!
    @IBOutlet weak var lblTrackArtist: UILabel!
    @IBOutlet weak var currentTrackView: UIView!
    @IBOutlet weak var tableview: UITableView!
    
    var playerView: PlayerView!
    var readingList: [DisplayablePlaylist?] = []
    var nextTracks: [DisplayablePlaylist?] = []
    
    var vc: PlayerDetailsViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (playerView.readingListContext == "Event") {
            tableview.isEditing = false
        } else {
            tableview.isEditing = true
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (playerView.index <= playerView.tracks.count - 1) {
            hideItems()
            let arrayTrackList = Array(playerView.tracks[playerView.index...playerView.tracks.count - 1])
            let trackList = arrayTrackList.joined(separator: ",")
            GetSeveralTracks.shared.getSeveralTracks(trackslist: trackList) { (success) in
                self.readingList = Array(GetSeveralTracks.shared.displayablePlaylist)
                DispatchQueue.main.async {
                    self.updateCurrentTrack()
                    if (self.readingList.count - 1 > 0) {
                        self.nextTracks = Array(self.readingList[1...self.readingList.count - 1])
                    } else {
                        self.nextTracks = []
                    }
                    self.tableview.reloadData()
                    UIView.transition(with: self.tableview, duration: 0.35, options: .transitionCrossDissolve, animations: self.appearItems)
                }
            }
        }
    }
    
    func dismissWhenPlayerIsOff() {
        self.vc = self.presentingViewController as? PlayerDetailsViewController
        self.dismiss(animated: true, completion: nil)
        self.vc.dismiss(animated: true, completion: nil)
    }
    
    func controlDelegUpdate() {
        let arrayTrackList = Array(playerView.tracks[playerView.index...playerView.tracks.count - 1])
        let trackList = arrayTrackList.joined(separator: ",")
        GetSeveralTracks.shared.getSeveralTracks(trackslist: trackList) { (success) in
            self.readingList = Array(GetSeveralTracks.shared.displayablePlaylist)
            DispatchQueue.main.async {
                self.updateCurrentTrack()
                if (self.readingList.count - 1 > 0) {
                    self.nextTracks = Array(self.readingList[1...self.readingList.count - 1])
                } else {
                    self.nextTracks = []
                }
                UIView.transition(with: self.tableview, duration: 0.35, options: .transitionCrossDissolve, animations: self.tableview.reloadData)
            }
        }
    }
    
    func hideItems() {
        self.view.subviews.forEach { $0.isHidden = true }
    }
    
    func appearItems() {
        self.view.subviews.forEach { $0.isHidden = false }
    }
    
    
    func updateCurrentTrack() {
        imgTrackCover.image = readingList[0]?.image
        lblTrackTitle.text = readingList[0]?.name
        lblTrackArtist.text = readingList[0]?.artists
    }

}

extension ReadingListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (nextTracks.count > 0) {
            return nextTracks.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReadingListTableViewCell") as? ReadingListTableViewCell else {
            return UITableViewCell()
        }
        cell.imgTrackCover.image = nextTracks[indexPath.row]?.image
        cell.lblTrackTitle.text = nextTracks[indexPath.row]?.name
        cell.lblTrackArtist.text = nextTracks[indexPath.row]?.artists
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let element = self.playerView.tracks.remove(at: self.playerView.index + sourceIndexPath.row + 1)
        self.playerView.tracks.insert(element, at: self.playerView.index + destinationIndexPath.row + 1)
        self.playerView.controlDelegSendInformationToRoom()
        let element2 = nextTracks.remove(at: sourceIndexPath.row)
        nextTracks.insert(element2, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.playerView.tracks.remove(at: self.playerView.index + indexPath.row + 1)
            playerView.controlDelegSendInformationToRoom()
            nextTracks.remove(at: indexPath.row)
            self.tableview.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if (playerView.readingListContext != "Event") {
            return .delete
        }
        return .none;
    }
}


class ReadingListTableViewCell: UITableViewCell {

    @IBOutlet weak var imgTrackCover: UIImageView!
    @IBOutlet weak var lblTrackTitle: UILabel!
    @IBOutlet weak var lblTrackArtist: UILabel!
    @IBOutlet weak var cell: UIView!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
}
