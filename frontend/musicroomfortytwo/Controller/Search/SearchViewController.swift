//
//  SearchViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 01/02/2021.
//

import UIKit

extension UIImage {
  convenience init?(url: URL?) {
    guard let url = url else { return nil }
    do {
      self.init(data: try Data(contentsOf: url))
    } catch {
      print("Cannot load image from url: \(url) with error: \(error)")
      return nil
    }
  }
}

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var tableview: UITableView!
    var tabBarView: TabBarViewController!
    var selectedTrackTitle: String?
    var selectedTrackId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGesture.minimumPressDuration = 0.5
        self.tableview.addGestureRecognizer(longPressGesture)
        tabBarView = self.tabBarController as? TabBarViewController
        // For the custom tableview cell
        self.tableview.dataSource = self
        self.tableview.delegate = self
        self.searchField.delegate = self
        searchView.layer.cornerRadius = 10
        searchView.layer.borderWidth = 2
        searchView.layer.borderColor = UIColor(red:28/255, green:20/255, blue:88/255, alpha: 1).cgColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
        self.registerTableViewCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    @objc func handleTap() {
        searchField.resignFirstResponder()
    }
    @objc func handleLongPress(longPressGesture: UILongPressGestureRecognizer) {
        let p = longPressGesture.location(in: self.tableview)
        let indexPath = self.tableview.indexPathForRow(at: p)
        if indexPath == nil {
            print("Long press on tableView, not row!")
        } else if longPressGesture.state == UIGestureRecognizer.State.began {
            print("long press on row, at \(indexPath!.row)")
            if indexPath!.row >= TrackSearch.shared.foundedTracks.count {
                print("Invalid index!")
                return
            }
            self.selectedTrackId = TrackSearch.shared.foundedTracks[indexPath!.row].id
            self.selectedTrackTitle = TrackSearch.shared.foundedTracks[indexPath!.row].title
            performSegue(withIdentifier: "ShareTrackFriend", sender: self)
        }
    }
    // Registering the new custom UITableViewCell with the UITableView
    private func registerTableViewCells() {
        let textFieldCell = UINib(nibName: "SearchTableViewCell", bundle: nil)
        self.tableview.register(textFieldCell, forCellReuseIdentifier: "SearchTableViewCell")
    }
    @IBAction func updateMusicSearch(_ sender: Any) {
        let textfield = searchField.text ?? ""
        TrackSearch.shared.searchTracks(textfield: textfield) { (success) in
            if success {
                OperationQueue.main.addOperation( {
                    self.tableview.reloadData()
                    UIView.transition(with: self.tableview, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
                })
            }
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if TrackSearch.shared.foundedTracks.count == 0 {
            self.tableview.isHidden = true
        } else {
            self.tableview.isHidden = false
        }
        return TrackSearch.shared.foundedTracks.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell", for: indexPath) as? SearchTableViewCell
        if (TrackSearch.shared.foundedTracks.count > indexPath.row) {
            let track = TrackSearch.shared.foundedTracks[indexPath.row]
            let title = track.title + " - " + track.artist
            cell?.trackTitle.text = title
            cell?.trackImage.image = track.image
            cell?.trackIndex = indexPath.row
            cell?.trackIds.removeAll()
            for i in 0...TrackSearch.shared.foundedTracks.count - 1 {
                cell?.trackIds.append(String(TrackSearch.shared.foundedTracks[i].id))
            }
            cell?.playerView = tabBarView.playerView
            cell!.delegate = self
            return cell!
        }
        return UITableViewCell()
    }
    
}

extension SearchViewController: SearchTableViewCellDelegator {
    
    func callSegueFromCell(cell: UITableViewCell) {
        if let indexPath = tableview.indexPath(for: cell) {
            UserDefaults.standard.setValue(indexPath.row, forKey: "rowTrack")
        }
        self.performSegue(withIdentifier: "DisplayTrack", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ShareTrackViewController {
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

extension SearchViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // dismiss keyboard
            return true
        }
}
