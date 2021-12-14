//
//  PlayerDetailsViewController.swift
//  musicroomfortytwo
//
//  Created by Jerome on 19/02/2021.
//

import UIKit

class PlayerDetailsViewController: UIViewController {

    var playerView: PlayerView?
    var playerPosition = Timer()
    
    @IBOutlet weak var btnPlayPause: UIButton!
    @IBOutlet weak var btnPrevious: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var imgTrackCover: UIImageView!
    @IBOutlet weak var lblTrackTitle: UILabel!
    @IBOutlet weak var lblTrackArtist: UILabel!
    @IBOutlet weak var barDuration: UISlider!
    @IBOutlet weak var lblProgress: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var btnShuffle: UIButton!
    
    var barPos = Float()
    var active = 0
    var intDuration = 0
    
    override func viewDidLoad() {
        barPos = Float(-1)
        playerView?.appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                self?.displayError(error as NSError)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.updateDurationBar(playerState: playerState)
                self?.updatePlayerDetails(playerState: playerState)
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (playerView?.readingListContext == "Event") {
            btnPlayPause.isHidden = true
            btnPrevious.isHidden = true
            btnNext.isHidden = true
            btnShuffle.isHidden = true
            barDuration.isUserInteractionEnabled = false
        }
        active = 1
        updateShuffleBtn()
        playerView?.appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                self?.displayError(error as NSError)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.updateDurationBar(playerState: playerState)
                self?.updatePlayerDetails(playerState: playerState)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        active = 0
    }
    
    var defaultCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    self?.displayError(error as NSError)
                }
            }
        }
    }
    
    func updatePlayPauseBtn(playerState: SPTAppRemotePlayerState) {
        if playerState.isPaused {
            btnPlayPause.setBackgroundImage(UIImage(systemName: "play.circle.fill"), for: UIControl.State.normal)
        } else {
            btnPlayPause.setBackgroundImage(UIImage(systemName: "pause.circle.fill"), for: UIControl.State.normal)
        }
    }
    
    func updateTrackCoverImg(track: SPTAppRemoteTrack) {
        playerView?.appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { [weak self] (image, error) in
            if let error = error {
                print("Error fetching track image: " + error.localizedDescription)
            } else if let image = image as? UIImage {
                self?.imgTrackCover.image = image
            }
        })
    }
    
    func updateTitle(track: SPTAppRemoteTrack) {
        lblTrackTitle.text = track.name
        lblTrackArtist.text = track.artist.name
    }
    
    func updateDurationBar(playerState: SPTAppRemotePlayerState) {
        lblProgress.text = Double(playerState.playbackPosition / 1000).durationText
        lblDuration.text = Double(playerState.track.duration / 1000).durationText
    }
    
    func updateShuffleBtn() {
        if (playerView!.isShuffling == true) {
            btnShuffle.tintColor = #colorLiteral(red: 0.1272085607, green: 0.0007708931807, blue: 0.3564728498, alpha: 1)
        } else {
            btnShuffle.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        }
    }
    
    func updatePlayerDetails(playerState: SPTAppRemotePlayerState) {
        if (active == 1) {
            if (playerView?.tracks.count == 0) {
                lblProgress.text = "0:00"
                lblDuration.text = "0:00"
                barDuration.setValue(Float(0), animated: false)
            } else {
                let track = playerState.track
                updatePlayPauseBtn(playerState: playerState)
                lblDuration.text = Double(playerState.track.duration / 1000).durationText
                updateTrackCoverImg(track: track)
                updateTitle(track: track)
            }
        }
    }
    
    // Play or Pause button
    @IBAction func playPause(_ sender: Any) {
        if let lastPlayerState = playerView!.lastPlayerState, lastPlayerState.isPaused {
            playerView?.appRemote.playerAPI?.resume(updatePlayPauseCallback)
        } else {
            playerView?.appRemote.playerAPI?.pause(updatePlayPauseCallback)
        }
    }
    
    // Start the previous track in the reading list
    @IBAction func previousTrack(_ sender: Any) {
        if (playerView!.index > 0) {
            if intDuration < 3 {
                playerView?.index-=1
            }
        }
        playerView?.appRemote.playerAPI?.play((playerView?.getTrackURI(index: playerView!.index))!, callback: updateCallback)
    }
    
    func nextTrack() {
        print("nextTrack")
        if (playerView!.index < (playerView?.tracks.count)! - 1) {
            playerView?.index+=1
            playerView?.appRemote.playerAPI?.play((playerView?.getTrackURI(index: playerView!.index))!, callback: updateCallback)
        } else {
            if (playerView?.readingListContext == "Event") {
                if let lastPlayerState = playerView?.lastPlayerState, !lastPlayerState.isPaused {
                    playerView?.appRemote.playerAPI?.pause(playerView?.disconnectPlayer)
                }
            } else {
                playerView?.index = 0
                playerView?.appRemote.playerAPI?.play((playerView?.getTrackURI(index: playerView!.index))!, callback: updateCallback)
            }
        }
    }
    
    // Start the next track in the reading list
    @IBAction func btnNextTrack(_ sender: Any) {
        nextTrack()
    }
    
    var updateCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    self?.displayError(error as NSError)
                } else {
                    self?.playerView?.appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
                        if let error = error {
                            self?.displayError(error as NSError)
                        } else if let playerState = playerState as? SPTAppRemotePlayerState {
                            self!.playerView?.controlDelegSendInformationToRoom()
                            self!.updatePlayerDetails(playerState: playerState)
                            self!.playerView?.updatePlayer(playerState: playerState)
                        }
                    })
                }
            }
        }
    }
    
    var updatePlayPauseCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    self?.displayError(error as NSError)
                } else {
                    self?.playerView?.appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
                        if let error = error {
                            self?.displayError(error as NSError)
                        } else if let playerState = playerState as? SPTAppRemotePlayerState {
                            self!.playerView?.controlDelegSendInformationToRoom()
                            self!.updatePlayPauseBtn(playerState: playerState)
                            self!.playerView?.updatePlayPausePlayer(playerState: playerState)
                        }
                    })
                }
            }
        }
    }
    
    var controlDelegSendInfo: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    self?.displayError(error as NSError)
                } else {
                    self?.playerView?.controlDelegSendInformationToRoom()
                }
            }
        }
    }
    
    
    @IBAction func shuffleButtonFunction(_ sender: Any) {
        if (playerView!.isShuffling == false) {
            playerView!.isShuffling = true
            btnShuffle.tintColor = #colorLiteral(red: 0.1272085607, green: 0.0007708931807, blue: 0.3564728498, alpha: 1)
            if (playerView!.tracks.count != 0) {
                let tmpTrack = playerView!.tracks[playerView!.index]
                playerView!.tracks.remove(at: playerView!.index)
                playerView!.index = 0
                playerView!.tracks.shuffle()
                playerView!.tracks.insert(tmpTrack, at: 0)
            }
        } else {
            playerView!.isShuffling = false
            btnShuffle.tintColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            if (playerView!.tracks.count != 0) {
                let newIndex = playerView!.unshuffledTracks.firstIndex(of: playerView!.tracks[playerView!.index])
                playerView!.tracks = playerView!.unshuffledTracks
                playerView!.index = newIndex!
            }
        }
        playerView!.controlDelegSendInformationToRoom()
    }
    
    @IBAction func showReadingList(_ sender: Any) {
        performSegue(withIdentifier: "ShowReadingList", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowReadingList" {
            let targetController = segue.destination as! ReadingListViewController
            targetController.playerView = self.playerView
        }
    }
    
    //--------------------------//
    //------ HANDLE ERROR ------//
    //--------------------------//
    
    func displayError(_ error: NSError?) {
        if let error = error {
            presentAlert(title: "Error", message: error.description)
        }
    }

    private func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


extension Double {
    var durationText:String {
        let totalSeconds = Int(self)
        let hours:Int = Int(totalSeconds / 3600)
        let minutes:Int = Int(totalSeconds % 3600 / 60)
        let seconds:Int = Int((totalSeconds % 3600) % 60)

        if hours > 0 {
            return String(format: "%i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%i:%02i", minutes, seconds)
        }
    }
}


//-------------------------------//
//----- CONTROL DELEGATION ------//
//-------------------------------//

    
extension PlayerDetailsViewController {
    
    func updatePlayerDetailsControlDeleg() {
        playerView?.appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                self?.displayError(error as NSError)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.updateDurationBar(playerState: playerState)
                self?.updatePlayerDetails(playerState: playerState)
                self?.updateShuffleBtn()
            }
        })
    }
}
