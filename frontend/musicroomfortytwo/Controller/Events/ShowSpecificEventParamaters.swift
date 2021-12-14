//
//  showSpecificEventParamaters.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 11/03/2021.
//

import Foundation
import UIKit

class ShowSpecificEventParameterViewController: UIViewController {
    @IBOutlet weak var eventName: UITextField!
    @IBOutlet weak var eventVisibility: UISegmentedControl!
    @IBOutlet weak var eventTrackVote: UISegmentedControl!
    @IBOutlet weak var eventType: UISegmentedControl!
    @IBOutlet weak var eventPlace: UITextField!
    @IBOutlet weak var eventBeginDate: UITextField!
    @IBOutlet weak var eventEndDate: UITextField!
    @IBOutlet weak var physicalEventView: UIView!
    @IBOutlet weak var validateButton: UIButton!
    @IBOutlet weak var noEventLabel: UILabel!
    @IBOutlet weak var statusEventLabel: UILabel!
    @IBOutlet weak var statusEventSegment: UISegmentedControl!
    @IBOutlet weak var musicalStyle: UITextField!
    var vcParent: ShowSpecificEventViewController?
    
    let datePicker = UIDatePicker()
    let stylePicker = UIPickerView()
    var styles = ["Non défini", "Blues", "Country", "Disco", "Folk",
                  "Funk", "Jazz", "Raï", "Rap", "Raggae", "Rock",
                  "Salsa", "Soul", "Techno"];
    
    override func viewDidLoad() {
        createDatePicker()
        createMusicalStylePicker()
        eventName.delegate = self
        eventPlace.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        let name = Notification.Name(rawValue: "refreshParticipantEventData")
        NotificationCenter.default.addObserver(self, selector: #selector(loadEventParameters), name: name, object: nil)
        loadEventParameters()
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
        musicalStyle.tintColor = UIColor.clear
    }
    @objc func donePressedStyle() {
        self.view.endEditing(true)
    }
    @objc func loadEventParameters() {
        DispatchQueue.main.async {
            if self.vcParent!.event != nil && self.vcParent!.userEventRight == "admin" {
                print("Page has been reloaded in parameter controller!")
                self.displayEventParameters()
            } else {
                self.displayDeleteEvent()
            }
        }
    }
    func displayEventParameters() {
        eventName.text = vcParent!.event!.name
        if vcParent!.event!.public == true {
            eventVisibility.selectedSegmentIndex = 0
        } else {
            eventVisibility.selectedSegmentIndex = 1
        }
        if vcParent!.event!.votingPrerequisites == false {
            eventTrackVote.selectedSegmentIndex = 0
        } else {
            eventTrackVote.selectedSegmentIndex = 1
        }
        if vcParent!.event!.musicalStyle == "none" {
            musicalStyle.text = styles[0]
        } else {
            musicalStyle.text = vcParent!.event!.musicalStyle!.capitalized
        }
        if vcParent!.event!.status == "started" {
            statusEventSegment.selectedSegmentIndex = 1
        } else {
            statusEventSegment.selectedSegmentIndex = 0
        }
        if vcParent!.event!.physicalEvent == false {
            eventType.selectedSegmentIndex = 0
        } else {
            statusEventLabel.isHidden = true
            statusEventSegment.isHidden = true
            physicalEventView.isHidden = false
            eventType.selectedSegmentIndex = 1
            eventPlace.text = vcParent!.event!.place
            eventBeginDate.text = transformDateFormat(date: vcParent!.event!.beginDate!)
            eventEndDate.text = transformDateFormat(date: vcParent!.event!.endDate!)
        }
    }
    func displayDeleteEvent() {
        self.view.subviews.forEach { $0.isHidden = true }
        self.noEventLabel.isHidden = false
    }
    func transformDateFormat(date: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm'Z'"
        let localTime = formatter.date(from: date)!.addingTimeInterval(2 * 60 * 60)
        return dateFormatter.string(from: localTime)
    }
    func createDatePicker() {
        if #available(iOS 13.4, *) {
           datePicker.preferredDatePickerStyle = .wheels
        }
        let toolbar1 = UIToolbar()
        toolbar1.sizeToFit()
        let doneBtn1 = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed1))
        toolbar1.setItems([doneBtn1], animated: true)
        eventBeginDate.inputAccessoryView = toolbar1
        eventBeginDate.inputView = datePicker
        let doneBtn2 = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed2))
        let toolbar2 = UIToolbar()
        toolbar2.sizeToFit()
        toolbar2.setItems([doneBtn2], animated: true)
        eventEndDate.inputAccessoryView = toolbar2
        eventEndDate.inputView = datePicker
        datePicker.datePickerMode = .dateAndTime
    }
    @objc func donePressed1() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm'Z'"
        eventBeginDate.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    @objc func donePressed2() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm'Z'"
        eventEndDate.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    @objc func handleTap() {
        eventName.resignFirstResponder() // dismiss keyoard
        eventPlace.resignFirstResponder()
    }
    @IBAction func updatePhysicalToogle(_ sender: UISegmentedControl) {
        if eventType.selectedSegmentIndex == 0 {
            statusEventLabel.isHidden = false
            statusEventSegment.isHidden = false
            physicalEventView.isHidden = true
        } else {
            statusEventLabel.isHidden = true
            statusEventSegment.isHidden = true
            physicalEventView.isHidden = false
        }
    }
    @IBAction func buttonTapped(_ sender: Any) {
        validateButton.isHidden = true
        var visibility = ""
        if eventVisibility.selectedSegmentIndex == 0 {
            visibility = "public"
        } else {
            visibility = "private"
        }
        var votingPrerequisites = false
        if eventTrackVote.selectedSegmentIndex == 1 {
            votingPrerequisites = true
        }
        var status = "notStarted"
        if statusEventSegment.selectedSegmentIndex == 1 {
            status = "started"
        }
        var physicalEvent = false
        if eventType.selectedSegmentIndex == 1 {
            physicalEvent = true
        }
        var eventStyle: String!
        if musicalStyle.text! == styles[0] {
            eventStyle = "none"
        } else {
            eventStyle = musicalStyle.text!.lowercased()
        }
        transformToUTCDate()
        vcParent?.event!.updateEvent(name: eventName.text!, visibility: visibility, votingPrerequisites: votingPrerequisites, musicalStyle: eventStyle, status: status, physicalEvent: physicalEvent, place: eventPlace.text!, beginDate: eventBeginDate.text, endDate: eventEndDate.text) { (success) in
            if success == 1 {
                self.dismiss(animated: true, completion: nil)
            } else {
                self.validateButton.isHidden = false
                self.presentAlert(number: success)
            }
        }
    }
    func transformToUTCDate() {
        if eventType.selectedSegmentIndex == 1 {
            eventBeginDate.text = transformDateFormatToUTC(date: eventBeginDate.text!)
            eventEndDate.text = transformDateFormatToUTC(date: eventEndDate.text!)
        }
    }
    func transformDateFormatToUTC(date: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm'Z'"
        let UTCDate = formatter.date(from: date)
        let returnDate = UTCDate?.addingTimeInterval(-1 * 60 * 60)
        return formatter.string(from: returnDate!)
    }
}

extension ShowSpecificEventParameterViewController: UIPickerViewDataSource, UIPickerViewDelegate {
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

extension ShowSpecificEventParameterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if eventName.isFirstResponder == true { 
            return
        }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

extension ShowSpecificEventParameterViewController {
    private func presentAlert(number: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if  number == 400 {
            title = "Nom de l'évènement incorrect 😢"
            message = "Caractères autorisés: [a-zA-Z0-9éèàêô,'!- ]"
        } else if  number == 401 {
            title = "Format du lieux incorrect 😢"
            message = "Caractères autorisés: [a-zA-Zéèàêô0-9,'- ]"
        } else if  number == 402 {
            title = "Impossible de verifier l'addresse 😢"
            message = "L'addresse du lieux de l'évènement n'a pas pu être vérifiée"
        } else if  number == 403 {
            title = "Champ date de début manquant 😢"
            message = "Une date de début est obligatoire"
        } else if  number == 404 {
            title = "Champ date de fin manquant 😢"
            message = "Une date de fin est obligatoire"
        } else if  number == 405 {
            title = "Dates invalides 😢"
            message = "La date de fin doit être après la date de début!"
        } else if number == 0 {
            title = "Erreur interne 😢"
            message = "Une erreur interne est survenue...!"
        }
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in }
        alertVC.addAction(action)
        present(alertVC, animated: true, completion: nil)
        
    }
}
