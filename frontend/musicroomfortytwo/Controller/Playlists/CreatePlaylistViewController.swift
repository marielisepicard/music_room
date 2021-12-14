//
//  CreatePlaylistViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 01/02/2021.
//

import UIKit

class CreatePlaylistViewController: UIViewController {

    @IBOutlet weak var editionRight: UISwitch!
    @IBOutlet weak var publicPlaylist: UISwitch!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var musicalStyle: UITextField!
    
    let stylePicker = UIPickerView()
    var styles = ["none", "blues", "country", "disco", "folk",
                  "funk", "jazz", "raï", "rap", "raggae", "rock",
                  "salsa", "soul", "techno"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
        createMusicalStylePicker()
    }
    
    @objc func handleTap() {
        nameField.resignFirstResponder()
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
    
    @IBAction func buttonTapped(_ sender: Any) {
        if (nameField.text != "") {
            button.isEnabled = true
            CreatePlaylist.shared.createNewPlaylist(title: nameField.text!, publicPlaylist: publicPlaylist.isOn, editionRight: editionRight.isOn, musicalStyle: musicalStyle.text!) { (success) in
                self.presentAlert(nb: success)
                self.nameField.text = ""
                self.button.isEnabled = true
            }
        }
        
    }
    
    private func presentAlert(nb: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if nb == 1 {
            title = "Playlist créée"
        } else if nb == 0 {
            title = "Erreur Interne 😢"
            message = "Nous avons un problème technique... Reviens plus tard !"
        }
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {action in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alertVC, animated: true, completion: nil)
    }
}


extension CreatePlaylistViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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

extension CreatePlaylistViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder() // dismiss keyboard
            return true
        }
}
