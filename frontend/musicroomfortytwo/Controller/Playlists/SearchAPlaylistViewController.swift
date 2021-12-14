//
//  SearchAPlaylistViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 03/02/2021.
//

import UIKit

/*
        The purpose of this Controller is to manage the search results
        when a user looks for playlists that he can follow.
        Example : a User wants to find a playlist with only rocknroll music,
        he can make a search with "rock" and we will show him the public playlist
        That contains the word "rock" in its title.
 */

class SearchAPlaylistViewController: UIViewController, UITextFieldDelegate {
    

    
    @IBOutlet weak var fieldSearchPlaylists: UITextField!
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var tableview: UITableView!
    var playlists: [FoundPlaylists]? = nil
    
    @IBOutlet weak var musicalStyle: UITextField!
    
    let stylePicker = UIPickerView()
    var styles = ["All", "blues", "country", "disco", "folk",
                  "funk", "jazz", "raï", "rap", "raggae", "rock",
                  "salsa", "soul", "techno"];
        
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
        createMusicalStylePicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        searchView.layer.cornerRadius = 10
        searchView.layer.borderWidth = 2
        searchView.layer.borderColor = UIColor(red:28/255, green:20/255, blue:88/255, alpha: 1).cgColor
        fieldSearchPlaylists.delegate = self
        PlaylistSearch.shared.playlistSearch(keyWord: fieldSearchPlaylists.text!, filtre: musicalStyle.text!) {(success, searchedPlaylists) in
            if (searchedPlaylists != nil) {
                self.playlists = searchedPlaylists
                DispatchQueue.main.async {
                    self.tableview.reloadData()
                    UIView.transition(with: self.tableview, duration: 0.25, options: .transitionCrossDissolve, animations: nil)
                }
            }
        }
    }
    
    func createMusicalStylePicker() {
        stylePicker.delegate = self
        stylePicker.dataSource = self

        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressedStyle))
        toolbar.setItems([doneBtn], animated: true)
        musicalStyle.inputAccessoryView = toolbar
        musicalStyle.inputView = stylePicker
        musicalStyle.text = styles[0]
    }
    @objc func donePressedStyle() {
        self.view.endEditing(true)
        PlaylistSearch.shared.playlistSearch(keyWord: fieldSearchPlaylists.text!, filtre: musicalStyle.text!) {(success, searchedPlaylists) in
            if (searchedPlaylists != nil) {
                self.playlists = searchedPlaylists
                DispatchQueue.main.async {
                    self.tableview.reloadData()
                    UIView.transition(with: self.tableview, duration: 0.25, options: .transitionCrossDissolve, animations: nil)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @IBAction func searchPlaylist(_ sender: Any) {
        PlaylistSearch.shared.playlistSearch(keyWord: fieldSearchPlaylists.text!, filtre: musicalStyle.text!) {(success, searchedPlaylists) in
            if (searchedPlaylists != nil) {
                self.playlists = searchedPlaylists
                DispatchQueue.main.async {
                    self.tableview.reloadData()
                    UIView.transition(with: self.tableview, duration: 0.25, options: .transitionCrossDissolve, animations: nil)
                }
            }
        }
    }
    
    @objc func handleTap() {
        self.fieldSearchPlaylists.resignFirstResponder()
    }
}

extension SearchAPlaylistViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (playlists != nil) {
            return playlists!.count
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PlaylistSearchResult") as? PlaylistSearchResultTableViewCell else {
            return UITableViewCell()
        }
        if (playlists != nil) {
            let playlist = playlists![indexPath.row]
            cell.playlistName.text = playlist.name
            cell.playlistCreator.text = "Par " + playlist.creator
            cell.playlistId = playlist._id
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
}

extension SearchAPlaylistViewController: MyPlaylistListDelegator {
    func callSegueFromPlaylistCell(cell: UITableViewCell) {
        let _ = UserDefaults.standard.string(forKey: "titleOfSelectedPlaylist")
        let _ = UserDefaults.standard.string(forKey: "idOfSelectedPlaylist")
        self.performSegue(withIdentifier: "ShowPlaylistSegue", sender: self)
    }
}

extension SearchAPlaylistViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPlaylistSegue" {
            _ = segue.destination as! ShowPlaylistViewController
        }
    }
}

class PlaylistSearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var playlistName: UILabel!
    @IBOutlet weak var playlistCreator: UILabel!
    
    @IBOutlet weak var playlistCell: UIView!
    var playlistId = String()

    var delegate: MyPlaylistListDelegator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(displayPlaylistDetail(sender:)))
        self.playlistCell?.addGestureRecognizer(tapGesture)
    }

    @objc func displayPlaylistDetail(sender: UITapGestureRecognizer) {
        if self.delegate != nil {
            UserDefaults.standard.setValue(self.playlistName.text!, forKey: "titleOfSelectedPlaylist")
            UserDefaults.standard.setValue(self.playlistId, forKey: "idOfSelectedPlaylist")
            self.delegate.callSegueFromPlaylistCell(cell: self)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
}


extension SearchAPlaylistViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.styles.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return styles[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        musicalStyle.text = styles[row]
    }

    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        self.stylePicker.isHidden = false
        return false
    }
    
}
