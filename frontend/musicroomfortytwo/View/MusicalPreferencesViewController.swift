//
//  MusicalPreferencesViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 12/02/2021.
//

import UIKit

class MusicalPreferencesViewController: UIViewController {
    
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var bluesButton: UIButton!
    @IBOutlet weak var discoButton: UIButton!
    @IBOutlet weak var folkButton: UIButton!
    @IBOutlet weak var funkButton: UIButton!
    @IBOutlet weak var jazzButton: UIButton!
    @IBOutlet weak var raiButton: UIButton!
    @IBOutlet weak var technoButton: UIButton!
    @IBOutlet weak var soulButton: UIButton!
    @IBOutlet weak var salsaButton: UIButton!
    @IBOutlet weak var rockButton: UIButton!
    @IBOutlet weak var raggaeButton: UIButton!
    @IBOutlet weak var rapButton: UIButton!
    
    var country = false
    var blues = false
    var disco = false
    var folk = false
    var funk = false
    var jazz = false
    var rai = false
    var techno = false
    var soul = false
    var salsa = false
    var rock = false
    var raggae = false
    var rap = false
    var newMusicalPreferences = ""
    
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.isEnabled = false
        button.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        self.navigationController?.isNavigationBarHidden = false
        loadColor()
    }
    
    @IBAction func countryButtonTapped(_ sender: Any) {
        if (countryButton.backgroundColor == #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)) {
            countryButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            country = false
        } else {
            countryButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            country = true
        }
        button.isEnabled = true
        button.backgroundColor = #colorLiteral(red: 0.115548484, green: 0.08298525959, blue: 0.3455429971, alpha: 1)
        
    }
    @IBAction func bluesButtonTapped(_ sender: Any) {
        if (bluesButton.backgroundColor == #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)) {
            bluesButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            blues = false
        } else {
            bluesButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            blues = true
        }
        button.isEnabled = true
        button.backgroundColor = #colorLiteral(red: 0.115548484, green: 0.08298525959, blue: 0.3455429971, alpha: 1)
    }
    
    @IBAction func discoButtonTapped(_ sender: Any) {
        if (discoButton.backgroundColor == #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)) {
            discoButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            disco = false
        } else {
            discoButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            disco = true
        }
        button.isEnabled = true
        button.backgroundColor = #colorLiteral(red: 0.115548484, green: 0.08298525959, blue: 0.3455429971, alpha: 1)
    }
    
    @IBAction func folkButtonTapped(_ sender: Any) {
        if (folkButton.backgroundColor == #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)) {
            folkButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            folk = false
        } else {
            folkButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            folk = true
        }
        button.isEnabled = true
        button.backgroundColor = #colorLiteral(red: 0.115548484, green: 0.08298525959, blue: 0.3455429971, alpha: 1)
    }
    
    @IBAction func funkButtonTapped(_ sender: Any) {
        if (funkButton.backgroundColor == #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)) {
            funkButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            funk = false
        } else {
            funkButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            funk = true
        }
        button.isEnabled = true
        button.backgroundColor = #colorLiteral(red: 0.115548484, green: 0.08298525959, blue: 0.3455429971, alpha: 1)
    }
    
    @IBAction func jazzButtonTapped(_ sender: Any) {
        if (jazzButton.backgroundColor == #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)) {
            jazzButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            jazz = false
        } else {
            jazzButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            jazz = true
        }
        button.isEnabled = true
        button.backgroundColor = #colorLiteral(red: 0.115548484, green: 0.08298525959, blue: 0.3455429971, alpha: 1)
    }
    @IBAction func raiButtonTapped(_ sender: Any) {
        if (raiButton.backgroundColor == #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)) {
            raiButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            rai = false
        } else {
            raiButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            rai = true
        }
        button.isEnabled = true
        button.backgroundColor = #colorLiteral(red: 0.115548484, green: 0.08298525959, blue: 0.3455429971, alpha: 1)
    }
    @IBAction func rapButtonTapped(_ sender: Any) {
        if (rapButton.backgroundColor == #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)) {
            rapButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            rap = false
        } else {
            rapButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            rap = true
        }
        button.isEnabled = true
        button.backgroundColor = #colorLiteral(red: 0.115548484, green: 0.08298525959, blue: 0.3455429971, alpha: 1)
    }
    
    @IBAction func raggaeButtonTapped(_ sender: Any) {
        if (raggaeButton.backgroundColor == #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)) {
            raggaeButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            raggae = false
        } else {
            raggaeButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            raggae = true
        }
        button.isEnabled = true
        button.backgroundColor = #colorLiteral(red: 0.115548484, green: 0.08298525959, blue: 0.3455429971, alpha: 1)
    }
    
    @IBAction func rockButtonTapped(_ sender: Any) {
        if (rockButton.backgroundColor == #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)) {
            rockButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            rock = false
        } else {
            rockButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            rock = true
        }
        button.isEnabled = true
        button.backgroundColor = #colorLiteral(red: 0.115548484, green: 0.08298525959, blue: 0.3455429971, alpha: 1)
    }
    
    @IBAction func salsaButtonTapped(_ sender: Any) {
        if (salsaButton.backgroundColor == #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)) {
            salsaButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            salsa = false
        } else {
            salsaButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            salsa = true
        }
        button.isEnabled = true
        button.backgroundColor = #colorLiteral(red: 0.115548484, green: 0.08298525959, blue: 0.3455429971, alpha: 1)
    }
    
    @IBAction func soulButtonTapped(_ sender: Any) {
        if (soulButton.backgroundColor == #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)) {
            soulButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            soul = false
        } else {
            soulButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            soul = true
        }
        button.isEnabled = true
        button.backgroundColor = #colorLiteral(red: 0.115548484, green: 0.08298525959, blue: 0.3455429971, alpha: 1)
    }
    @IBAction func technoButtonTapped(_ sender: Any) {
        if (technoButton.backgroundColor == #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)) {
            technoButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            techno = false
        } else {
            technoButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            techno = true
        }
        button.isEnabled = true
        button.backgroundColor = #colorLiteral(red: 0.115548484, green: 0.08298525959, blue: 0.3455429971, alpha: 1)
    }
    
    func getNewMusicalPreferences() {
        newMusicalPreferences = ""
        if blues {
            if newMusicalPreferences.isEmpty {
                newMusicalPreferences = "blues"
            } else {
                newMusicalPreferences = newMusicalPreferences + ",blues"
            }
        }
        if country {
            if newMusicalPreferences.isEmpty {
                newMusicalPreferences = "country"
            } else {
                newMusicalPreferences = newMusicalPreferences + ",country"
            }
        }
        if disco {
            if newMusicalPreferences.isEmpty {
                newMusicalPreferences = "disco"
            } else {
                newMusicalPreferences = newMusicalPreferences + ",disco"
            }
        }
        if folk {
            if newMusicalPreferences.isEmpty {
                newMusicalPreferences = "folk"
            } else {
                newMusicalPreferences = newMusicalPreferences + ",folk"
            }
        }
        if funk {
            if newMusicalPreferences.isEmpty {
                newMusicalPreferences = "funk"
            } else {
                newMusicalPreferences = newMusicalPreferences + ",funk"
            }
        }
        if jazz {
            if newMusicalPreferences.isEmpty {
                newMusicalPreferences = "jazz"
            } else {
                newMusicalPreferences = newMusicalPreferences + ",jazz"
            }
        }
        if rai {
            if newMusicalPreferences.isEmpty {
                newMusicalPreferences = "raï"
            } else {
                newMusicalPreferences = newMusicalPreferences + ",raï"
            }
        }
        if rap {
            if newMusicalPreferences.isEmpty {
                newMusicalPreferences = "rap"
            } else {
                newMusicalPreferences = newMusicalPreferences + ",rap"
            }
        }
        if raggae {
            if newMusicalPreferences.isEmpty {
                newMusicalPreferences = "raggae"
            } else {
                newMusicalPreferences = newMusicalPreferences + ",raggae"
            }
        }
        if rock {
            if newMusicalPreferences.isEmpty {
                newMusicalPreferences = "rock"
            } else {
                newMusicalPreferences = newMusicalPreferences + ",rock"
            }
        }
        if salsa {
            if newMusicalPreferences.isEmpty {
                newMusicalPreferences = "salsa"
            } else {
                newMusicalPreferences = newMusicalPreferences + ",salsa"
            }
        }
        if soul {
            if newMusicalPreferences.isEmpty {
                newMusicalPreferences = "soul"
            } else {
                newMusicalPreferences = newMusicalPreferences + ",soul"
            }
        }
        if techno {
            if newMusicalPreferences.isEmpty {
                newMusicalPreferences = "techno"
            } else {
                newMusicalPreferences = newMusicalPreferences + ",techno"
            }
        }
        
        print("string à envoyer : ", newMusicalPreferences)
        
    }
    @IBAction func buttonTapped(_ sender: Any) {
        getNewMusicalPreferences()
        
        let musicalPreferencesArr = self.newMusicalPreferences.components(separatedBy: ",")
        GetUserProfile.shared.userInfos.musicalPreferences = musicalPreferencesArr
        UpdateMusicalPreferences.shared.updateUserInfos(newMusicalPreferences: self.newMusicalPreferences) { (success) in
            if success == 1 {
                print("success de la requête : ", success)
                DispatchQueue.main.async {
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
            } else {
                print("yolo")
            }
        }
    }
    
    func loadColor() {
        AdjustStringFormat.shared.prepareStringFormat(GetUserProfile.shared.userInfos.musicalPreferences!)
        let currentMusicalPreferences = UserDefaults.standard.string(forKey: "testString")!
        print("current Musical Preferences : ", currentMusicalPreferences)
        
        if currentMusicalPreferences.contains("blues") {
            bluesButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            blues = true
        } else {
            bluesButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        if currentMusicalPreferences.contains("country") {
            countryButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            country = true
        } else {
            countryButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        if currentMusicalPreferences.contains("disco") {
            discoButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            disco = true
        } else {
            discoButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        if currentMusicalPreferences.contains("folk") {
            folkButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            folk = true
        } else {
            folkButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        if currentMusicalPreferences.contains("funk") {
            funkButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            funk = true
        } else {
            funkButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        if currentMusicalPreferences.contains("jazz") {
            jazzButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            jazz = true
        } else {
            jazzButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        if currentMusicalPreferences.contains("raï") {
            raiButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            rai = true
        } else {
            raiButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        if currentMusicalPreferences.contains("rap") {
            rapButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            rap = true
        } else {
            rapButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        if currentMusicalPreferences.contains("raggae") {
            raggaeButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            raggae = true
        } else {
            raggaeButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        if currentMusicalPreferences.contains("rock") {
            rockButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            rock = true
        } else {
            rockButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        if currentMusicalPreferences.contains("salsa") {
            salsaButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            salsa = true
        } else {
            salsaButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        if currentMusicalPreferences.contains("soul") {
            soulButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            soul = true
        } else {
            soulButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        if currentMusicalPreferences.contains("techno") {
            technoButton.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
            techno = true
        } else {
            technoButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
}
