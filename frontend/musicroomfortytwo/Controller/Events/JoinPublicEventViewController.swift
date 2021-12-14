//
//  JoinAnEventViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 06/02/2021.
//

import UIKit

class PublicEventViewController: UIViewController {
    @IBOutlet weak var searchView: UIView!
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var playlistSearch: UITextField!
    @IBOutlet weak var musicalStyle: UITextField!
    var selectedEventId: String?
    
    let stylePicker = UIPickerView()
    var styles = ["All", "Blues", "Country", "Disco", "Folk",
                  "Funk", "Jazz", "Raï", "Rap", "Raggae", "Rock",
                  "Salsa", "Soul", "Techno"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createMusicalStylePicker()
        playlistSearch.delegate = self
        playlistSearch.becomeFirstResponder()
        musicalStyle.tintColor = UIColor.clear
        searchView.layer.cornerRadius = 10
        searchView.layer.borderWidth = 2
        searchView.layer.borderColor = UIColor(red:28/255, green:20/255, blue:88/255, alpha: 1).cgColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
        EventSearch.shared.eventSearch(keyWord: playlistSearch.text!, musicalStyle: musicalStyle.text!.lowercased()) { (success) in
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
        self.navigationController?.isNavigationBarHidden = false
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
    }
    @IBAction func updateSearchPublicEvent(_ sender: Any) {
        EventSearch.shared.eventSearch(keyWord: playlistSearch.text!, musicalStyle: musicalStyle.text!.lowercased()) { (success) in
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }
    @objc func handleTap() {
        playlistSearch.resignFirstResponder()
    }
    @IBAction func updateFiltreSearchPublic(_ sender: Any) {
        EventSearch.shared.eventSearch(keyWord: playlistSearch.text!, musicalStyle: musicalStyle.text!.lowercased()) { (success) in
            DispatchQueue.main.async {
                self.tableview.reloadData()
            }
        }
    }
}

extension PublicEventViewController: MyPublicEventDelegator {
    func openPublicEvent(indexCell: Int) {
        selectedEventId = EventSearch.shared.eventResults[indexCell]._id
        performSegue(withIdentifier: "displayPublicEvent", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ShowSpecificEventViewController {
            vc.event!.id = selectedEventId
        }
    }
}

extension PublicEventViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = EventSearch.shared.eventResults.count
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PublicEventCell") as? PublicEventTableViewCell else {
            return UITableViewCell()
        }
        cell.eventName.text = EventSearch.shared.eventResults[indexPath.row].name
        cell.eventCreator.text = EventSearch.shared.eventResults[indexPath.row].creator
        cell.cellIndex = indexPath.row
        cell.delegate = self
        return cell
    }
}

extension PublicEventViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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
}

extension PublicEventViewController  {
    
    private func presentAlert(nb: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if nb == 1 {
            title = "Événement rejoint 😊"
            message = "Y'a plus qu'à t'éclater"
        } else if nb == 0 {
            title = "Erreur Interne 😢"
            message = "Nous avons un problème technique... Reviens plus tard !"
        } else if nb == 2 {
            title = "Événement privé 😢"
            message = "Désolé... t'es pas encore VIP"
        } else if nb == 3 {
            title = "Hep Hep Hep 😁"
            message = "T'as déjà rejoins cet événement, pas la peine de te réinscrire"
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
}

extension PublicEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // dismiss keyboard
            return true
        }
}
