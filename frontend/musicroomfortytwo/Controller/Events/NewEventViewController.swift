//
//  NewEventViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 06/02/2021.
//

import UIKit

class NewEventViewController: UIViewController {
    
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var visibilityControl: UISegmentedControl! // 0 = public, 1 = private
    @IBOutlet weak var eventPlace: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var physicalEventToggle: UISegmentedControl!
    @IBOutlet weak var votingPrerequisitesToggle: UISegmentedControl!
    @IBOutlet weak var physicalEventView: UIView!
    @IBOutlet weak var beginDateText: UITextField!
    @IBOutlet weak var endDateText: UITextField!
    @IBOutlet weak var musicalStyle: UITextField!
    
    let datePicker = UIDatePicker()
    let stylePicker = UIPickerView()
    var styles = ["Non défini", "Blues", "Country", "Disco", "Folk",
                  "Funk", "Jazz", "Raï", "Rap", "Raggae", "Rock",
                  "Salsa", "Soul", "Techno"];
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        createDatePicker()
        createMusicalStylePicker()
        eventName.becomeFirstResponder()
        eventName.delegate = self
        eventPlace.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        musicalStyle.tintColor = UIColor.clear
    }
    @objc func donePressedStyle() {
        self.view.endEditing(true)
    }
    func createDatePicker() {
        if #available(iOS 13.4, *) {
           datePicker.preferredDatePickerStyle = .wheels
        }
        let toolbar1 = UIToolbar()
        toolbar1.sizeToFit()
        let doneBtn1 = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed1))
        toolbar1.setItems([doneBtn1], animated: true)
        beginDateText.inputAccessoryView = toolbar1
        beginDateText.inputView = datePicker
        let doneBtn2 = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed2))
        let toolbar2 = UIToolbar()
        toolbar2.sizeToFit()
        toolbar2.setItems([doneBtn2], animated: true)
        endDateText.inputAccessoryView = toolbar2
        endDateText.inputView = datePicker
        datePicker.datePickerMode = .dateAndTime
    }
    @objc func donePressed1() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm'Z'"
        beginDateText.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    @objc func donePressed2() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm'Z'"
        endDateText.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    @objc func handleTap() {
        eventName.resignFirstResponder() // dismiss keyoard
        eventPlace.resignFirstResponder()
    }
    @IBAction func updatePhysicalToogle(_ sender: UISegmentedControl) {
        if physicalEventToggle.selectedSegmentIndex == 0 {
            physicalEventView.isHidden = true
        } else {
            physicalEventView.isHidden = false
        }
    }
    @IBAction func buttonTapped(_ sender: Any) {
        button.isEnabled = false
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        var visibility = ""
        if visibilityControl.selectedSegmentIndex == 0 {
            visibility = "public"
        } else {
            visibility = "private"
        }
        var votingPrerequisites = false
        if votingPrerequisitesToggle.selectedSegmentIndex == 1 {
            votingPrerequisites = true
        }
        var physicalEvent = false
        if physicalEventToggle.selectedSegmentIndex == 1 {
            physicalEvent = true
            transformToUTCDate()
        }
        var eventStyle: String!
        if musicalStyle.text! == styles[0] {
            eventStyle = "none"
        } else {
            eventStyle = musicalStyle.text!.lowercased()
        }
        Event().createEvent(name: eventName.text!, visibility: visibility, votingPrerequisites: votingPrerequisites, musicalStyle: eventStyle, physicalEvent: physicalEvent, place: eventPlace.text!, beginDate: beginDateText.text, endDate: endDateText.text) { (success) in
            print("success ? ", success)
            if success == 1 {
                self.presentAlert(number: 1)
            } else {
                self.button.isEnabled = true
                self.presentAlert(number: success)
            }
        }
    }
    func transformToUTCDate() {
        beginDateText.text = transformDateFormatToUTC(date: beginDateText.text!)
        endDateText.text = transformDateFormatToUTC(date: endDateText.text!)
    }
    func transformDateFormatToUTC(date: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm'Z'"
        let UTCDate = formatter.date(from: date)
        let returnDate = UTCDate?.addingTimeInterval(-1 * 60 * 60)
        return formatter.string(from: returnDate!)
    }
}

extension NewEventViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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

extension NewEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // dismiss keyboard
        return true
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if eventName.isFirstResponder == true {
            return
        }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                let tabBarHeight = tabBarController?.tabBar.frame.size.height ?? 0
                self.view.frame.origin.y -= keyboardSize.height - tabBarHeight
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

extension NewEventViewController {
    private func presentAlert(number: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if number == 1 {
            title = "Évènement créé"
            
        } else if  number == 400 {
            title = "Nom de l'évènement incorrect"
            message = "Caractères autorisés: [a-zA-Z0-9éèàêô,'!- ]"
        } else if  number == 401 {
            title = "Format du lieux incorrect"
            message = "Caractères autorisés: [a-zA-Zéèàêô0-9,'- ]"
        } else if  number == 402 {
            title = "Impossible de verifier l'adresse"
            message = "L'adresse du lieux de l'évènement n'a pas pu être vérifiée"
        } else if  number == 403 {
            title = "Champ date de début manquant"
            message = "Une date de début est obligatoire"
        } else if  number == 404 {
            title = "Champ date de fin manquant"
            message = "Une date de fin est obligatoire"
        } else if  number == 405 {
            title = "Dates invalides"
            message = "La date de fin doit être après la date de début!"
        } else if number == 0 {
            title = "Erreur interne 😢"
            message = "Une erreur interne est survenue...!"
        }
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            if number == 1 {
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
    }
}

