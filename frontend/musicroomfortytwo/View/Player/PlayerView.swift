//
//  PlayerView.swift
//  musicroomfortytwo
//
//  Created by Jerome on 19/02/2021.
//

import UIKit

class PlayerView: UIView, SPTSessionManagerDelegate, SPTAppRemoteDelegate, SPTAppRemotePlayerStateDelegate {

    @IBOutlet weak var imgTrackCover: UIImageView!
    @IBOutlet weak var lblTrackTitle: UILabel!
    @IBOutlet weak var lblTrackArtist: UILabel!
    @IBOutlet weak var btnPlayPause: UIButton!
    
    var playerDetails: PlayerDetailsViewController?
    var index = 0
    var tracks: [String] = []
    var unshuffledTracks : [String] = []
    var isShuffling = false
    
    var readingListContext = String()
    var startPosition = 0
    
    var openButton: UIView!
    
    var hide = false
    
    var roomControlDelegation: RoomControlDelegation!
    
    var sendInfo = false
    var isPlaying = true
    var startingTimer = Date()
    
    
    var goNextTrack = false
    
    //Spotify Player
    
    private let SpotifyClientID = "6b7e5095f2824006b9c487f48b9d779a"
    private let SpotifyRedirectURI = URL(string: "musicroom://login")!
    
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: SpotifyClientID, redirectURL: SpotifyRedirectURI)
        configuration.playURI = ""
        let route = UserDefaults.standard.string(forKey: "socketServer")!
        configuration.tokenSwapURL = URL(string: route + "/spotify/authorization_code/access_token")
        configuration.tokenRefreshURL = URL(string: route + "/spotify/authorization_code/refresh_token")
        return configuration
    }()
    
    lazy var sessionManager: SPTSessionManager = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.delegate = self
        return appRemote
    }()

    var lastPlayerState: SPTAppRemotePlayerState?
    
    // MARK: - SPTSessionManagerDelegate

    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("didFailWithSession")
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("didRenewSession")
    }

    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("didInitiateSession")
        let group = DispatchGroup()
        group.enter()
        appRemote.connectionParameters.accessToken = session.accessToken
        
        group.leave()
        group.notify(queue: .main) {
            self.appRemote.delegate = self
            self.appRemote.connect()
        }
    }

    // MARK: - SPTAppRemoteDelegate

    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        print("appRemoteDidEstablishConnection")
        if (hide == true) {
            hide = false
        } else {
            if let _ = UIApplication.getTopViewController() as? DiscussionMessagesController {
                self.transitionPlayer(visible: false)
            } else {
                self.transitionPlayer(visible: true)
            }
        }
        self.appRemote.playerAPI?.delegate = self
        self.appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print(error as NSError)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.updatePlayer(playerState: playerState)
            }
        })
        self.appRemote.playerAPI?.subscribe(toPlayerState: { (success, error) in
            if let error = error {
                print("Error subscribing to player state:" + error.localizedDescription)
            } else {
                self.updatePlayerPosition()
                if (self.startPosition != 0) {
                    let timer = Int(Date().timeIntervalSince(self.startingTimer) * 1000)
                    self.appRemote.playerAPI?.seek(toPosition: self.startPosition + timer, callback: nil)
                    self.startPosition = 0
                }
            }
        })
    }
    

    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("disconnectWithError")
        self.transitionPlayer(visible: false)
        if let topVC = UIApplication.getTopViewController() as? ReadingListViewController {
            topVC.dismissWhenPlayerIsOff()
        }
        if let topVC = UIApplication.getTopViewController() as? ControlDelegationViewController {
            topVC.dismissWhenPlayerIsOff()
        }
        if let topVC = UIApplication.getTopViewController() as? PlayerDetailsViewController {
            topVC.dismiss(animated: true, completion: nil)
        }
        if let data = UserDefaults.standard.value(forKey:"roomControlDelegation") as? Data {
            self.roomControlDelegation = try? PropertyListDecoder().decode(RoomControlDelegation.self, from: data)
        }
        SocketIOManager.shared.controlDelegLeaveRoom(friendId: UserDefaults.standard.value(forKey:"userId") as! String, roomId: roomControlDelegation.roomId)
        lastPlayerState = nil
    }

    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("didFailConnection")
        self.transitionPlayer(visible: false)
        lastPlayerState = nil
        appRemote.connectionParameters.accessToken = nil
    }
    
    // MARK: - SPTAppRemotePlayerAPIDelegate

    func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        lastPlayerState = playerState
    }
    
    func updatePlayPausePlayer(playerState: SPTAppRemotePlayerState) {
        if (readingListContext == "Event") {
            btnPlayPause.setBackgroundImage(UIImage(named: "icons8-delete-40"), for: UIControl.State.normal)
        } else {
            if playerState.isPaused {
                btnPlayPause.setBackgroundImage(UIImage(systemName: "play.fill"), for: UIControl.State.normal)
            } else {
                btnPlayPause.setBackgroundImage(UIImage(systemName: "pause.fill"), for: UIControl.State.normal)
            }
        }
    }
    
    func updateTrackCoverImgPlayer(track: SPTAppRemoteTrack) {
        appRemote.imageAPI?.fetchImage(forItem: track, with: CGSize.zero, callback: { [weak self] (image, error) in
            if let error = error {
                print("Error fetching track image: " + error.localizedDescription)
            } else if let image = image as? UIImage {
                self?.imgTrackCover.image = image
            }
        })
    }
    
    func updateTitlePlayer(track: SPTAppRemoteTrack) {
        lblTrackTitle.text = track.name
        lblTrackArtist.text = track.artist.name
    }
    
    func updatePlayer(playerState: SPTAppRemotePlayerState) {
        let track = playerState.track
        if (track.name != "--") {
            updatePlayPausePlayer(playerState: playerState)
            updateTrackCoverImgPlayer(track: track)
            updateTitlePlayer(track: track)
        }
    }
    
    
    // MY FUNCTIONS
    
    // Get the track URI based on the reading list index
    func getTrackURI(index: Int) -> String {
        return "spotify:track:" + tracks[index]
    }
    
    // Play pause
    @IBAction func playPause(_ sender: Any) {
        if (readingListContext == "Event") {
            if let lastPlayerState = lastPlayerState, !lastPlayerState.isPaused {
                appRemote.playerAPI?.pause(disconnectPlayer)
            }
        } else {
            if let lastPlayerState = lastPlayerState, lastPlayerState.isPaused {
                appRemote.playerAPI?.resume(self.updatePlayPauseCallback)
            } else {
                appRemote.playerAPI?.pause(self.updatePlayPauseCallback)
            }
        }
    }
    
    func shuffleTracks() {
        if (isShuffling == true) {
            if (tracks.count != 0) {
                let tmpTrack = tracks[index]
                tracks.remove(at: index)
                index = 0
                tracks.shuffle()
                tracks.insert(tmpTrack, at: 0)
            }
        } else {
            if (tracks.count != 0) {
                let newIndex = unshuffledTracks.firstIndex(of: tracks[index])
                tracks = unshuffledTracks
                index = newIndex!
            }
        }
    }
    
    func playTrack(trackURI: [String], trackIndex: Int, context: String, position: Int) {
        startingTimer = Date()
        tracks = trackURI
        unshuffledTracks = trackURI
        index = trackIndex
        readingListContext = context
        startPosition = position
        shuffleTracks()
        if (context == "Event") {
            btnPlayPause.setBackgroundImage(UIImage(named: "icons8-delete-40"), for: UIControl.State.normal)
        } else {
            btnPlayPause.setBackgroundImage(UIImage(systemName: "pause.fill"), for: UIControl.State.normal)
        }
        if (self.appRemote.connectionParameters.accessToken == nil) {
            self.configuration.playURI = getTrackURI(index: index)
            let scope: SPTScope = [.appRemoteControl]
            sessionManager.initiateSession(with: scope, options: .clientOnly)
        } else {
            transitionPlayer(visible: true)
            appRemote.playerAPI?.play(getTrackURI(index: index), callback: self.updateCallback)
        }
    }
    
    
    func transitionPlayer(visible: Bool) {
        openButton.isHidden = true
        self.isHidden = !visible
        UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve, animations: nil)
    }
    
    
    
    var updateCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    print(error as NSError)
                } else {
                    if (self!.startPosition != 0) {
                        self?.appRemote.playerAPI?.seek(toPosition: self!.startPosition, callback: nil)
                        self!.startPosition = 0
                    }
                    self?.appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
                        if let error = error {
                            print(error as NSError)
                        } else if let playerState = playerState as? SPTAppRemotePlayerState {
                            self?.controlDelegSendInformationToRoom()
                            self?.updatePlayer(playerState: playerState)
                            self?.playerDetails?.updatePlayerDetails(playerState: playerState)
                            self?.updatePlayerDetailsControlDeleg()
                            if (self?.goNextTrack == true) {
                                print("updateCallback")
                                self?.updatePlayerPosition()
                                self?.goNextTrack = false
                                self?.playerDetails?.barDuration.setValue(Float(0), animated: false)
                            }
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
                    print(error as NSError)
                } else {
                    self?.appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
                        if let error = error {
                            print(error as NSError)
                        } else if let playerState = playerState as? SPTAppRemotePlayerState {
                            if (playerState.isPaused) {
                                self?.isPlaying = false
                            } else {
                                self?.isPlaying = true
                            }
                            self?.controlDelegSendInformationToRoom()
                            self?.updatePlayPausePlayer(playerState: playerState)
                            self?.updatePlayerDetailsControlDeleg()
                        }
                    })
                }
            }
        }
    }
    
    var controlDelegUpdateCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    print(error as NSError)
                } else {
                    if (self!.startPosition != 0) {
                        self?.appRemote.playerAPI?.seek(toPosition: self!.startPosition, callback: nil)
                        self!.startPosition = 0
                    }
                    self?.appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
                        if let error = error {
                            print(error as NSError)
                        } else if let playerState = playerState as? SPTAppRemotePlayerState {
                            self?.updatePlayer(playerState: playerState)
                            self?.updatePlayerDetailsControlDeleg()
                        }
                    })
                }
            }
        }
    }
    
    func controlDelegUpdate() {
        self.appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print(error as NSError)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.updatePlayer(playerState: playerState)
                self?.updatePlayerDetailsControlDeleg()
                if (self?.isPlaying == true && playerState.isPaused) {
                    self?.appRemote.playerAPI?.resume(self?.controlDelegUpdatePlayPauseCallback)
                } else if (self?.isPlaying == false && !playerState.isPaused) {
                    self?.appRemote.playerAPI?.pause(self?.controlDelegUpdatePlayPauseCallback)
                }
                self?.updateReadingListControlDeleg()
            }
        })
    }
    
    var controlDelegUpdatePlayPauseCallback: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    print(error as NSError)
                } else {
                    self?.appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
                        if let error = error {
                            print(error as NSError)
                        } else if let playerState = playerState as? SPTAppRemotePlayerState {
                            self?.updatePlayPausePlayer(playerState: playerState)
                            self?.updatePlayerDetailsControlDeleg()
                        }
                    })
                }
            }
        }
    }
    
    var disconnectPlayer: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    print(error as NSError)
                } else {
                    self!.hide = true
                    self!.appRemote.disconnect()
                }
            }
        }
    }
    
    func refreshReadingList(trackURI: [String]) {
        tracks = trackURI
        index = 0
    }
    
    @IBAction func hidePlayer(_ sender: Any) {
        self.isHidden = true
        openButton.isHidden = false
        UIView.transition(with: self, duration: 0.2, options: .transitionCrossDissolve, animations: nil)
    }
}
    
    
//-------------------------------//
//----- CONTROL DELEGATION ------//
//-------------------------------//

    
extension PlayerView {
    
    
    func controlDelegPlayTrack() {
        if (readingListContext == "Event") {
            btnPlayPause.setBackgroundImage(UIImage(named: "icons8-delete-40"), for: UIControl.State.normal)
        } else {
            btnPlayPause.setBackgroundImage(UIImage(systemName: "pause.fill"), for: UIControl.State.normal)
        }
        if (self.appRemote.connectionParameters.accessToken == nil) {
            self.configuration.playURI = getTrackURI(index: index)
            let scope: SPTScope = [.appRemoteControl]
            sessionManager.initiateSession(with: scope, options: .clientOnly)
        } else {
            transitionPlayer(visible: true)
            appRemote.playerAPI?.play(getTrackURI(index: index), callback: self.controlDelegUpdateCallback)
        }
    }
    
    func controlDelegPlayer(tracks: [String], unshuffledTracks: [String], index: Int, readingListContext: String, position: Int, isShuffling: Bool, isPlaying: Bool) {
        var trackId = String()
        if (self.tracks.count > 0) {
            trackId = self.tracks[self.index]
        }
        self.tracks = tracks
        self.unshuffledTracks = unshuffledTracks
        self.index = index
        self.readingListContext = readingListContext
        self.isShuffling = isShuffling
        self.isPlaying = isPlaying
        self.startingTimer = Date()
        
        if (!appRemote.isConnected) {
            self.startPosition = position
            controlDelegPlayTrack()
        } else {
            if (trackId != tracks[index]) {
                self.startPosition = position
                controlDelegPlayTrack()
            } else {
                appRemote.playerAPI?.getPlayerState({ (playerState, error) in
                    if let error = error {
                        print(error as NSError)
                    } else if let playerState = playerState as? SPTAppRemotePlayerState {
                        if (playerState.playbackPosition > position + 2000 || playerState.playbackPosition < position - 2000) {
                            self.appRemote.playerAPI?.seek(toPosition: position, callback: self.controlDelegUpdateCallback)
                        } else {
                            self.controlDelegUpdate()
                        }
                    }
                })
            }
        }
    }
    
    func controlDelegSendInformationToRoom() {
        appRemote.playerAPI?.getPlayerState({ (playerState, error) in
            if let error = error {
                print(error as NSError)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                if let data = UserDefaults.standard.value(forKey:"roomControlDelegation") as? Data {
                    self.roomControlDelegation = try? PropertyListDecoder().decode(RoomControlDelegation.self, from: data)
                }
                if (self.roomControlDelegation != nil && self.roomControlDelegation.friendsList.count > 1) {
                    SocketIOManager.shared.controlDelegInitPlayer(roomId: self.roomControlDelegation.roomId, userId: UserDefaults.standard.value(forKey:"userId") as! String, tracks: self.tracks, unshuffledTracks: self.unshuffledTracks, index: self.index, readingListContext: self.readingListContext, position: playerState.playbackPosition, isShuffling: self.isShuffling, isPlaying: !playerState.isPaused)
                }
            }
        })
    }
    
    func updatePlayerDetailsControlDeleg() {
        if let topVC = UIApplication.getTopViewController() as? PlayerDetailsViewController {
            topVC.updatePlayerDetailsControlDeleg()
        }
    }
    
    func updateReadingListControlDeleg() {
        if let topVC = UIApplication.getTopViewController() as? ReadingListViewController {
            topVC.controlDelegUpdate()
        }
    }

}



extension PlayerView {
    
    @objc func updatePlayerPosition() {
        appRemote.playerAPI?.getPlayerState({ [weak self] (playerState, error) in
            if let error = error {
                print(error as NSError)
            } else if let playerState = playerState as? SPTAppRemotePlayerState {
                self?.updateBarPositionScheduled(playerState: playerState)
            }
        })
    }
    
    func updateBarPositionScheduled(playerState: SPTAppRemotePlayerState) {
        var checkNext = 0
        let duration = Float(playerState.track.duration)
        if (tracks.count != 0) {
            if (playerDetails?.barPos != -1 && playerDetails?.barPos != playerDetails?.barDuration.value) {
                if ((playerDetails?.barDuration.value)! > 0.96) {
                    print("nextTrackBecause duration bar moved")
                    self.nextTrack()
                    playerDetails?.barPos = Float(-1)
                    checkNext = 1
                } else {
                    let newPosition = duration * (playerDetails?.barDuration.value)!
                    appRemote.playerAPI?.seek(toPosition: Int(newPosition), callback: controlDelegSendInfo)
                }
            } else {
                let progress = Float(playerState.playbackPosition) / duration
                playerDetails?.barDuration.setValue(Float(progress), animated: false)
            }
            if (playerState.playbackPosition < 2000) {
                playerDetails?.updatePlayerDetails(playerState: playerState)
                updatePlayer(playerState: playerState)
            }
            playerDetails?.lblProgress.text = Double(playerState.playbackPosition / 1000).durationText
            playerDetails?.intDuration = Int(playerState.playbackPosition / 1000)
            if (duration - Float(playerState.playbackPosition) < 2000) {
                print("nextTrackBecause - 2 sec")
                self.nextTrack()
            } else if (checkNext == 0){
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    self.updatePlayerPosition()
                })
            }
            playerDetails?.barPos = (playerDetails?.barDuration.value)!
        }
    }
    
    func nextTrack() {
        print("nextTrack")
        goNextTrack = true
        if (index < (tracks.count) - 1) {
            index+=1
            appRemote.playerAPI?.play((getTrackURI(index: index)), callback: updateCallback)
        } else {
            if (readingListContext == "Event") {
                if let lastPlayerState = lastPlayerState, !lastPlayerState.isPaused {
                    appRemote.playerAPI?.pause(disconnectPlayer)
                }
            } else {
                index = 0
                appRemote.playerAPI?.play((getTrackURI(index: index)), callback: updateCallback)
            }
        }
    }
    
    
    var controlDelegSendInfo: SPTAppRemoteCallback {
        get {
            return {[weak self] _, error in
                if let error = error {
                    print(error as NSError)
                } else {
                    self?.controlDelegSendInformationToRoom()
                }
            }
        }
    }
}
