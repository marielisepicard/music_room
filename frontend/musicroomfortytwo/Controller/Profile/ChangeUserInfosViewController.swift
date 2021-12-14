//
//  ChangeUserInfosViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 10/02/2021.
//

import UIKit
import GoogleSignIn

class ChangeUserInfosViewController: UIViewController {
    @IBOutlet weak var lastnameLabel: UITextField!
    @IBOutlet weak var firstnameLabel: UITextField!
    @IBOutlet weak var pseudoLabel: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var userInformations: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var linkGoogleAccount: UIButton!
    @IBOutlet weak var secondaryEmailLabel: UILabel!
    
    let userInfos: UserInfos = GetUserProfile.shared.userInfos
    let userData: UserData = GetUserProfile.shared.userData
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        NotificationCenter.default.removeObserver(self, name: .signInGoogleCompleted, object: nil)
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDidSignInGoogle(_:)),
                                               name: .signInGoogleCompleted,
                                               object: nil)
        lastnameLabel.delegate = self
        firstnameLabel.delegate = self
        pseudoLabel.delegate = self
        self.lastnameLabel.text = userInfos.lastName
        self.firstnameLabel.text = userInfos.firstName
        self.pseudoLabel.text = userInfos.pseudo
        self.emailLabel.text = userInfos.email
        printUserInformations()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    func printUserInformations() {
        if userData.friendsId.count < 2 {
            self.userInformations.text = String(userData.friendsId.count) + " ami"
        } else {
            self.userInformations.text = String(userData.friendsId.count) + " amis"
        }
        if userData.playlists.count < 2 {
            self.userInformations.text! += " | " + String(userData.playlists.count) + " playlist"
        } else {
            self.userInformations.text! += " | " + String(userData.playlists.count) + " playlists"
        }
        if userData.events.count < 2 {
            self.userInformations.text! += " | " + String(userData.events.count) + " event"
        } else {
            self.userInformations.text! += " | " + String(userData.events.count) + " events"
        }
        if self.userInfos.secondaryEmail != nil {
            self.secondaryEmailLabel.text = userInfos.secondaryEmail!
            linkGoogleAccount.isHidden = true
        } else {
            secondaryEmailLabel.isHidden = true
        }
    }
    @IBAction func googleLinkButtonTapped(_ sender: Any) {
        self.linkGoogleAccount.isEnabled = false
        if GIDSignIn.sharedInstance()?.hasPreviousSignIn() == true {
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        } else {
            GIDSignIn.sharedInstance()?.signIn()
        }
        self.linkGoogleAccount.isEnabled = true
    }
    
    // Notification happening when a google user successfully connect himself
    @IBAction private func userDidSignInGoogle(_ sender: Any) {
        if UserDefaults.standard.bool(forKey: "connected") == false {
            return
        }
        if GIDSignIn.sharedInstance()?.currentUser != nil {
            LinkAccountToGoogle.shared.linkAccountToGoogle() { (success) in
                if success == 1 {
                    self.presentGoogleAlert(nb: 1)
                }
            }
        }
    }
    func isThereUpdateInfo() -> Int {
        if lastnameLabel.text != userInfos.lastName {
            return 1
        }
        if firstnameLabel.text != userInfos.firstName {
            return 1
        }
        if pseudoLabel.text != userInfos.pseudo {
            return 1
        }
        return 0
    }
    
    @IBAction func buttonTapped(_ sender: Any) {
        self.button.isEnabled = false
        if isThereUpdateInfo() == 1 {
            let newInfos = UserInfos(firstName: self.firstnameLabel.text!, lastName: self.lastnameLabel.text!, pseudo: self.pseudoLabel.text!, email: self.userInfos.email, musicalPreferences: [""])
            DispatchQueue.main.async {
                UpdateUserInfos.shared.updateUserInfos(userNewInfos: newInfos) { (success) in
                    if success == 0 {
                        DispatchQueue.main.async {
                            self.presentAlert(nb: 0)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.presentAlert(nb: success)
                        }
                    }
                    DispatchQueue.main.async {
                        self.button.isEnabled = true
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.presentAlert(nb: 2)
                self.button.isEnabled = true
            }
        }
    }
    @objc func handleTap() {
        self.pseudoLabel.resignFirstResponder() // dismiss keyoard
        self.firstnameLabel.resignFirstResponder()
        self.lastnameLabel.resignFirstResponder()
    }
}

extension ChangeUserInfosViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @objc func keyboardWillShow(notification: NSNotification) {
        if pseudoLabel.isFirstResponder == true {
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

extension ChangeUserInfosViewController {
    private func presentGoogleAlert(nb: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if nb == 0 {
            title = "Compte déjà lié à Google"
//            message = "Ton compte est déjà lié à Google"
        } else if nb == 1 {
            title = "Compte lié à Google"
//            message = "Ton compte est bien lié :) "
        } else if nb == 2 {
            title = "Oups"
            message = "Désolé, on a une erreur en interne, reviens plus tard"
        }
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            self.navigationController?.popViewController(animated: true)
        }))
        present(alertVC, animated: true, completion: nil)
    }
    private func presentAlert(nb: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if nb == 0 {
            title = "Erreur"
            message = "Sorry, reviens plus tard"
        } else if nb == 1 {
            title = "Informations mises à jour"
//            message = "On a bien modifié tes informations"
        } else if nb == 2 {
            title = "Aucun changement demandé"
//            message = "Change au moins une info :)"
        } else if nb == 5 {
            title = "Ce pseudo existe déjà"
        } else if nb == 6 {
            title = "Le format d'un des champs est invalide"
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
