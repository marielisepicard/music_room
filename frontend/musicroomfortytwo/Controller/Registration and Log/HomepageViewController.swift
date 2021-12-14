//
//  HomepageViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 31/01/2021.
//

import UIKit

class HomepageViewController: UIViewController {
    
    @IBOutlet weak var registrationButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        // If the User is already connected, we skip that controller
        if UserDefaults.standard.bool(forKey: "connected") == true {
            performSegue(withIdentifier: "connectedUserArrival", sender: self)
        }
    }
    
    @IBAction func unwindToHomepage(segue:UIStoryboardSegue) { }
    
    // Segue that is performed when a user is already loggued when he opens the app
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "connectedUserArrival" {
            _ = segue.destination as! UITabBarController
        }
    }
}
