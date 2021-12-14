//
//  DisplayFriendEventsViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 13/02/2021.
//

import UIKit

class DisplayFriendEventsViewController: UIViewController, UITableViewDataSource, FriendsEventDelegator {
    
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GetAFriendProfile.shared.friendProfileObject.events?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DisplayFriendEvent") as? FriendEventsTableViewCell else {
            return UITableViewCell()
        }
        cell.eventTitle.text = GetAFriendProfile.shared.friendProfileObject.events?[indexPath.row].name
        cell.eventId.text = GetAFriendProfile.shared.friendProfileObject.events?[indexPath.row].id
        cell.delegate = self
        return cell
    }
    
    func displayFriendEvent(eventId: String, eventTitle: String) {
        UserDefaults.standard.setValue(eventTitle, forKey: "selectedEvent")
        UserDefaults.standard.setValue(eventId, forKey: "selectedIdEvent")
        performSegue(withIdentifier: "DisplayFriendEventSegue", sender: self)
    }

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ShowSpecificEventViewController {
            let selectedEventId = UserDefaults.standard.string(forKey: "selectedIdEvent")!
            vc.event!.id = selectedEventId
        }
         if segue.identifier == "DisplayFriendEventSegue" {
          _ = segue.destination as! ShowSpecificEventViewController
         }
     }
} 
