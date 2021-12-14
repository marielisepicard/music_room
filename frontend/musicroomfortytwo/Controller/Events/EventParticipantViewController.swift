//
//  EventParticipantViewController.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 12/03/2021.
//

import Foundation
import UIKit

class EventParticipantViewController: UIViewController {
    var event: Event?
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noEventLabel: UILabel!
    var vcParent: ShowSpecificEventViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let name = Notification.Name(rawValue: "refreshParticipantEventData")
        NotificationCenter.default.addObserver(self, selector: #selector(loadSpecificEventData), name: name, object: nil)
        loadSpecificEventData()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    @objc private func loadSpecificEventData() {
        self.event = vcParent!.event
        DispatchQueue.main.async {
            if self.event != nil && self.vcParent!.userEventRight == "admin" {
                print("Page has been reloaded!")
                self.displayParticipantView()
            } else {
                self.displayDeleteEvent()
                print("Need to handle this error. It can occurs when an event is deleted! FromEventParticipantViewController")
            }
        }
    }
    func displayParticipantView() {
        DispatchQueue.main.async {
            self.view.subviews.forEach { $0.isHidden = false }
            self.noEventLabel.isHidden = true
            self.tableView.reloadData()
        }
    }
    func displayDeleteEvent() {
        DispatchQueue.main.async {
            self.view.subviews.forEach { $0.isHidden = true }
            self.noEventLabel.isHidden = false
        }
    }
}

extension EventParticipantViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return event!.guestsInfo!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipantCell") as? EventParticipantCell else {
            return UITableViewCell()
        }
        cell.userPseudo.text = event!.guestsInfo![indexPath.row].pseudo
        if (event!.guestsInfo![indexPath.row].right == "guest") {
            cell.userRight.selectedSegmentIndex = 1
        } else if (event!.guestsInfo![indexPath.row].right == "superUser") {
            cell.userRight.selectedSegmentIndex = 2
        } else {
            cell.userRight.selectedSegmentIndex = 3
        }
        cell.userRight.tag = indexPath.row
        cell.delegate = self
        return cell
    }
}

extension EventParticipantViewController: MyEventParticipantDelegator {
    func updateUserRight(cellSegment: UISegmentedControl) {
        let userSelectedRight: String?
        if (cellSegment.selectedSegmentIndex == 0) {
            userSelectedRight = "delete"
        } else if (cellSegment.selectedSegmentIndex == 1) {
            userSelectedRight = "guest"
        } else if (cellSegment.selectedSegmentIndex == 2) {
            userSelectedRight = "superUser"
        } else {
            userSelectedRight = "admin"
        }
        event!.updateParticipantRight(participantId: event!.guestsInfo![cellSegment.tag].userId, participantRight: userSelectedRight!) { (success) in
            if (success != 0) {
                self.presentAlert(nb: success)
                self.loadSpecificEventData()
            }
        }
    }
}

extension EventParticipantViewController {
    private func presentAlert(nb: Int) {
        print("erro nb: ", nb)
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if nb == 2 {
            title = "Droit de l'utilisateur inchangeable 😢"
            message = "Vous ne pouvez pas changer vos propres droits"
         } else {
            title = "Erreur Interne 😢"
            message = "Nous avons un problème technique... Reviens plus tard !"
        }
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            if nb == 1 {
                self.navigationController?.popViewController(animated: true)
            }
        }
        alertVC.addAction(action)
        let name = Notification.Name(rawValue: "refreshEventsData")
        let notification = Notification(name: name)
        NotificationCenter.default.post(notification)
        present(alertVC, animated: true, completion: nil)
    }
}
