//
//  DisplayTrackViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 01/02/2021.
//

import UIKit

class DisplayTrackViewController: UIViewController {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var trackTitle: UILabel!
    @IBOutlet weak var trackArtist: UILabel!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        let row = UserDefaults.standard.integer(forKey: "rowTrack")
        trackTitle.text = TrackSearch.shared.foundedTracks[row].title
        trackArtist.text = TrackSearch.shared.foundedTracks[row].artist
        UserDefaults.standard.setValue(TrackSearch.shared.foundedTracks[row].id, forKey: "idOfSelectedTrack")
        UserDefaults.standard.setValue(TrackSearch.shared.foundedTracks[row].duration, forKey: "durationOfSelectedTrack")
        print("id track : ", TrackSearch.shared.foundedTracks[row].id)
        image.image = UIImage(url: URL(string: TrackSearch.shared.foundedTracks[row].imageUrl))
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? SelectEventViewController {
            let row = UserDefaults.standard.integer(forKey: "rowTrack")
            vc.selectedTrackId = TrackSearch.shared.foundedTracks[row].id
        }
    }
}
