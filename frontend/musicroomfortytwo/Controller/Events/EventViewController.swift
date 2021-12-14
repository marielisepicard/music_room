//
//  EventViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 06/02/2021.
//

import UIKit

class EventViewController: UIViewController {
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var searchView: UIView!
    var userEvents = EventsList()
    var selectedEvent: String?
    var eventMapping = [Int()]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableview.delegate = self
        self.navigationController?.isNavigationBarHidden = true
        searchView.layer.cornerRadius = 10
        searchView.layer.borderWidth = 2
        searchView.layer.borderColor = UIColor(red:28/255, green:20/255, blue:88/255, alpha: 1).cgColor
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapSearchView))
        searchView.addGestureRecognizer(tap)
        let notifName = Notification.Name(rawValue: "refreshUserEventsData")
        NotificationCenter.default.addObserver(self, selector: #selector(refreshEventsData), name: notifName, object: nil)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        refreshEventsData()
    }
    func displayEventData() {
        self.tableview.isHidden = false
        UIView.transition(with: self.tableview, duration: 0.35, options: .transitionCrossDissolve, animations: { self.tableview.reloadData() })
    }
    @objc func refreshEventsData() {
        userEvents.getUserEvents() { (success) in
            if (success != 1) {
                print("error when retrieving events list!")
                return
            }
            self.joinAllEventsRoom()
            DispatchQueue.main.async {
                self.displayEventData()
            }
        }
    }
    func joinAllEventsRoom() {
        if userEvents.events.count == 0 {
            return
        }
        for i in 0 ..< 3 {
            for j in 0 ..< userEvents.events[i]!.count {
                SocketIOManager.shared.joinRoom(roomId: userEvents.events[i]![j].id!)
            }
        }
    }
}

extension EventViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return userEvents.events.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Évènements en cours"
        } else if section ==  1 {
            return "Évènements à venir"
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UsersEvents") as? UsersEventsTableViewCell else {
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
        cell.eventName.text = userEvents.events[indexPath.section]?[indexPath.row].name //Segfault!: Thread 1: Fatal error: Index out of range first ? souligne en rouge
        if userEvents.events[indexPath.section]?[indexPath.row].creator != nil {
            cell.creator.text = "par " + userEvents.events[indexPath.section]![indexPath.row].creator!
        }
        cell.delegate = self
        return cell
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            let tmpEvent = self.userEvents.events[indexPath.section]![indexPath.row]
            self.userEvents.events[indexPath.section]!.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
            tmpEvent.deleteSpecifiedEvent() { (success, code) in
                if (success) {
                    print("Event successfully deleted")
                } else {
                    print("Cannot delete event")
                    self.refreshEventsData()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor.white
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = #colorLiteral(red: 0.1272085607, green: 0.0007708931807, blue: 0.3564728498, alpha: 1)
    }
}

extension EventViewController: UsersEventDelegator {
    func eventSelected(indexPath: IndexPath) {
        if userEvents.events.count <= indexPath.section || userEvents.events[indexPath.section]!.count <= indexPath.row {
            return
        }
        selectedEvent = userEvents.events[indexPath.section]![indexPath.row].id!
        self.performSegue(withIdentifier: "DisplayEvent", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ShowSpecificEventViewController {
            vc.event!.id = selectedEvent
        }
    }
}

extension EventViewController: UITextFieldDelegate {
    @objc func handleTapSearchView() {
        self.performSegue(withIdentifier: "displaySearchPublicEvent", sender: self)
    }
}
