//
//  LogViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 31/01/2021.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit

class LogViewController: UIViewController {
    
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var googleButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Thanks to this notification, we are aware of the connexion of a user to google and
        // we automatically call the function "userDidSignInGoogle" when a user is connected
        mailField.delegate = self
        passwordField.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDidSignInGoogle(_:)),
                                               name: .signInGoogleCompleted,
                                               object: nil)
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    
    
    // When a user tapped the google button, we try to connect him.
    @IBAction func googleButtonTapped(_ sender: Any) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    // When a user successfully connect to Google, then we make a request, so that
    // he can also be authenticated with our backend server
    @objc private func userDidSignInGoogle(_ notification: Notification) {
        if UserDefaults.standard.bool(forKey: "connected") == true {
            return
        }
        LogGoogleUser.shared.logGoogleUser() { (success) in
            if success == 0 {
                self.presentAlert(nb: 500)
            } else if success == 1 {
                self.performSegue(withIdentifier: "ConnectionSegue", sender: self)
            } else if success == 2 {
                self.presentAlert(nb: 402)
            } else if success == 3 {
                self.presentAlert(nb: 401)
            } else if success == 4 {
                self.presentAlert(nb: 404)
            }
        }
    }
    
    // when a user get log with his mail and password
    @IBAction func buttonTapped(_ sender: Any) {
        button.isEnabled = false
        let mail = mailField.text!
        let password = passwordField.text!
        if mail.isEmpty || password.isEmpty {
            presentAlert(nb: 1)
            button.isEnabled = true
            return
        }
        LogUser.shared.logUser(mail: mail, password: password) { (success) in
            if success == 200 {
                self.performSegue(withIdentifier: "ConnectionSegue", sender: self)
            } else {
                self.presentAlert(nb: success)
                self.button.isEnabled = true
            }
        }
    }
    
    @IBAction func facebookButtonTapped(_ sender: Any) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: ["public_profile", "email"], from: self) { [weak self] (result, error) in
            guard error == nil else {
                // Error occurred
                print(error!.localizedDescription)
                self?.presentAlert(nb: 500)
                return
            }
            guard let result = result, !result.isCancelled else {
                print("User cancelled login")
                return
            }
            Profile.loadCurrentProfile { (profile, error) in
                let token = AccessToken.current?.tokenString ?? ""
                UserDefaults.standard.setValue(token, forKey: "facebookToken")
                UserDefaults.standard.setValue(token, forKey: "userToken")
                LogFacebookUser.shared.logFacebookUser() { (success) in
                    if success == 1 {
                        UserDefaults.standard.setValue(true, forKey: "connected")
                        UserDefaults.standard.setValue(true, forKey: "FacebookLogued")
                        self!.performSegue(withIdentifier: "ConnectionSegue", sender: self)
                    } else if success == 0 {
                        UserDefaults.standard.setValue("", forKey: "facebookToken")
                        UserDefaults.standard.setValue("", forKey: "userToken")
                        self?.presentAlert(nb: 500)
                    } else if success == 4 {
                        UserDefaults.standard.setValue("", forKey: "facebookToken")
                        UserDefaults.standard.setValue("", forKey: "userToken")
                        self?.presentAlert(nb: 404)
                    } else {
                        UserDefaults.standard.setValue("", forKey: "facebookToken")
                        UserDefaults.standard.setValue("", forKey: "userToken")
                        let loginManager = LoginManager()
                        loginManager.logOut()
                        self?.presentAlert(nb: 401)
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConnectionSegue" {
            _ = segue.destination as! UITabBarController
            self.navigationController?.isNavigationBarHidden = true
        }
    }
    @objc func handleTap() {
        self.mailField.resignFirstResponder() // dismiss keyoard
        self.passwordField.resignFirstResponder()
    }
}

extension LogViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension LogViewController {
    
    private func presentAlert(nb: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if nb == 401 {
            title = "Pas de compte"
            message = "Tu n'es pas encore inscrit"
        } else if nb == 402 {
            title = "Compte inactif"
            message = "Check tes mails, il faut que tu valides notre lien de validation!"
        } else if nb == 403 {
            title = "Mauvais Mot de passe"
            message = "Mauvaise combinaison Mail & Mot de passe !"
        } else if nb == 404 {
            title = "Compte temporairement bloqué"
            message = "Votre compte a été bloqué par mesure de sécurité pour une durée de 5 minutes car vous vous êtes trompé au moins 5 fois de mot de passe"
        } else if nb == 500 {
            title = "Erreur Interne 😢"
            message = "Désolé... reviens plus tard"
        } else if nb == 1 {
            title = "Champ vide 😢"
            message = "il nous manque des infos !"
        }
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}
