//
//  SelectEventViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 23/02/2021.
//

import UIKit

class SelectEventViewController: UIViewController {
    @IBOutlet weak var tableview: UITableView!
    var userEvents = EventsList()
    var selectedTrackId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        tableview.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        getAllUserEvents()
    }
    
    func getAllUserEvents() {
        userEvents.getEditableEvents() { (success) in
            if success == 1 {
                DispatchQueue.main.async {
                    self.tableview.reloadData()
                }
            }
        }
    }
}

extension SelectEventViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return userEvents.events.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Évènements en cours"
        } else if section == 1 {
            return  "Évènements à venir"
        } else {
            return "Évènements terminés"
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if userEvents.events[section]!.count == 0  {
            return 0
        } else {
            return 30
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if userEvents.events.count == 0 {
            return 0
        }
        switch section {
            case 0:
                return userEvents.events[0]!.count
            case 1:
                return userEvents.events[1]!.count
            case 2:
                return userEvents.events[2]!.count
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PickEvent") as? SelectingEventTableViewCell else {
            return UITableViewCell()
        }
        if (indexPath.section >= userEvents.events.count || indexPath.row >= userEvents.events[indexPath.section]!.count) {
            return cell
        }
        if userEvents.events[indexPath.section]?[indexPath.row].coverEvent != nil {
            cell.coverImage.image = userEvents.events[indexPath.section]?[indexPath.row].coverEvent
        } else {
            cell.coverImage.image = UIImage(named: "defaultThumbnail")
        }
        cell.eventTitle.text = userEvents.events[indexPath.section]![indexPath.row].name
        cell.creator.text = "par \(userEvents.events[indexPath.section]![indexPath.row].creator ?? "")"
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.white
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = #colorLiteral(red: 0.1272085607, green: 0.0007708931807, blue: 0.3564728498, alpha: 1)
    }
}

extension SelectEventViewController: MySelectionOfEventDelegator {
    func addTrackToEvent(_ indexPath: IndexPath) {
        let eventId = userEvents.events[indexPath.section]![indexPath.row].id!
        let trackId = selectedTrackId!
        // make the request to add the title and present alert
        AddTrackToEvent.shared.addTrackToEvent(eventId: eventId, trackId: trackId) { (success) in
            print("success : ", success)
            self.presentAlert(nb: success)
        }
    }
}

extension SelectEventViewController {
    
    private func presentAlert(nb: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if nb == 1 {
            title = "Morceau ajouté à l'évènement"
            message = ""
        } else if nb == 0 {
            title = "Aie aie aie"
            message = "On a des problèmes en interne, reviens plus tard (désoooo)"
        } else if nb == 3 {
            title = "Ce morceau est déjà dans cet évènement"
            message = ""
        }
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}
