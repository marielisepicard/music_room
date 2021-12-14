//
//  RegistrationViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 31/01/2021.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit

class RegistrationViewController: UIViewController {
    
    @IBOutlet weak var registrationLabel: UILabel!
    @IBOutlet weak var firstnameField: UITextField!
    @IBOutlet weak var lastnameField: UITextField!
    @IBOutlet weak var pseudoField: UITextField!
    @IBOutlet weak var mailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    // Google Sign Up Button
    @IBOutlet weak var googleSignInButton: UIButton!
    @IBOutlet weak var facebookSignInButton: UIButton!
    
    override func viewDidLoad() {
        print("view did load")
        super.viewDidLoad()
        firstnameField.delegate = self
        lastnameField.delegate = self
        pseudoField.delegate = self
        mailField.delegate = self
        passwordField.delegate = self
        // Google SDK
        GIDSignIn.sharedInstance()?.presentingViewController = self
        // Automatically sign in the user.
        // GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        if GIDSignIn.sharedInstance()?.currentUser == nil {
            // No Google user logued
        }
        // Register notification to update screen after user successfully signed in Google
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(userDidSignInGoogle(_:)),
                                               name: .signInGoogleCompleted,
                                               object: nil)
    }
    
    // GOOGLE
    @IBAction func googleSignInButtonTapped(_ sender: Any) {
        googleSignInButton.isEnabled = false
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func addGoogleUser() {
        if GIDSignIn.sharedInstance()?.currentUser != nil {
            let googleIdToken = GIDSignIn.sharedInstance()?.currentUser.authentication.idToken
            UserDefaults.standard.setValue(googleIdToken, forKey: "googleToken")
            UserDefaults.standard.setValue(googleIdToken, forKey: "userToken")
            RegisterGoogleUser.shared.registerGoogleUser(idToken: googleIdToken!) { (success) in
                print("success : ", success)
                if success == 0 {
                    UserDefaults.standard.setValue("", forKey: "googleToken")
                    UserDefaults.standard.setValue("", forKey: "userToken")
                    self.presentAlert(nb: 0)
                } else if success == 1 {
                    UserDefaults.standard.setValue(true, forKey: "GoogleLogued")
                    UserDefaults.standard.setValue(true, forKey: "connected")
                    self.performSegue(withIdentifier: "GoogleOrFacebookConnexionSegue", sender: self)
                } else if success == 2 {
                    UserDefaults.standard.setValue("", forKey: "googleToken")
                    UserDefaults.standard.setValue("", forKey: "userToken")
                    self.presentAlert(nb: 1)
                } else if success == 3 {
                    UserDefaults.standard.setValue("", forKey: "googleToken")
                    UserDefaults.standard.setValue("", forKey: "userToken")
                    self.presentAlert(nb: 3)
                }
            }
        }
        googleSignInButton.isEnabled = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoogleOrFacebookConnexionSegue" {
         _ = segue.destination as! UITabBarController
        }
    }
    
    // Notification happening when a google user successfully connect himself
    @objc private func userDidSignInGoogle(_ notification: Notification) {
        addGoogleUser()
    }
    
    // Facebook Button Tapped
    @IBAction func facebookSignInButtonTapped(_ sender: Any) {
        
        // Create an instance of Facebook SDK’s LoginManager class to handle login and logout operations.
        let loginManager = LoginManager()
        
        if let _ = AccessToken.current {
            // it means a user is already loggued.
            // It's an error : a facebook loggued user shouldn't be on that view controller ! (never)
            
            print("on deconnecte le user : ")
            loginManager.logOut()
        } else {
            // perform Log In
            print("on log un user  !")
            loginManager.logIn(permissions: ["public_profile", "email"], from: self) { [weak self] (result, error) in
                // Check for error
                guard error == nil else {
                    // Error occurred
                    print(error!.localizedDescription)
                    return
                }
                // Check for cancel
                guard let result = result, !result.isCancelled else {
                    print("User cancelled login")
                    return
                }
                
                // The user is now logued
                Profile.loadCurrentProfile { (profile, error) in
                    //
                    let name = Profile.current?.name
                    print("name of the logued user : ", name ?? "")
                    
                    // Récupérer le Token de Facebook
                    let token = AccessToken.current?.tokenString ?? ""
                    UserDefaults.standard.setValue(token, forKey: "facebookToken")
                    UserDefaults.standard.setValue(token, forKey: "userToken")

                    RegisterFacebookUser.shared.registerFacebookUser() { (success) in
                        if success == 1 {
                            // user defaults facebook
                            UserDefaults.standard.setValue(true, forKey: "FacebookLogued")
                            UserDefaults.standard.setValue(true, forKey: "connected")

                            self!.performSegue(withIdentifier: "GoogleOrFacebookConnexionSegue", sender: self)
                        } else if success == 2 {
                            UserDefaults.standard.setValue("", forKey: "facebookToken")
                            UserDefaults.standard.setValue("", forKey: "userToken")

                            self?.presentAlert(nb: 3)
                            
                        } else if success == 0 {
                            // intern error
                            UserDefaults.standard.setValue("", forKey: "facebookToken")
                            UserDefaults.standard.setValue("", forKey: "userToken")

                            self?.presentAlert(nb: 0)
                        }
                    }
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        firstnameField.autocorrectionType = .no
        lastnameField.autocorrectionType = .no
        pseudoField.autocorrectionType = .no
        mailField.autocorrectionType = .no
        passwordField.autocorrectionType = .no
    }
    @IBAction func buttonTapped(_ sender: Any) {
        button.isEnabled = false
        let firstname = firstnameField.text!
        let lastname = lastnameField.text!
        let pseudo = pseudoField.text!
        let mail = mailField.text!
        let password = passwordField.text!
        if (firstname.isEmpty || lastname.isEmpty || pseudo.isEmpty || mail.isEmpty || password.isEmpty) {
            presentAlert(nb: 4)
            button.isEnabled = true
            return
        } else if !isValidEmailAddress(emailAddressString: mail) {
            presentAlert(nb: 5)
            button.isEnabled = true
            return
        }
        print("HELLO1")
        let newUser = User(firstname: firstname, lastname: lastname, pseudo: pseudo, mail: mail, password: password)
        print("newUser", newUser)
        RegisterUser.shared.registerNewUser(user: newUser) { (success) in
            print("success: ", success)
            self.button.isEnabled = true
            self.presentAlert(nb: success)
            // 0: Inter Error, 1: Success, 2: Pseudo already taken, 3: Mail already in DataBase
        }
    }
    @objc func handleTap() {
        self.mailField.resignFirstResponder() // dismiss keyoard
        self.passwordField.resignFirstResponder()
        self.firstnameField.resignFirstResponder()
        self.lastnameField.resignFirstResponder()
        self.pseudoField.resignFirstResponder()
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// Manage All Alerts
extension RegistrationViewController {
    
    private func presentAlert(nb: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if nb == 1 {
            title = "Inscription validée"
            message = "Afin de finaliser votre inscription, clique sur le lien de validation que nous venons de t'envoyer par mail !"
        } else if nb == 0 {
            title = "Erreur Interne"
            message = "Nous avons un problème technique... Reviens plus tard !"
        } else if nb == 2 {
            title = "Pseudo déjà pris"
            message = "Choisis en un autre !"
        } else if nb == 3 {
            title = "Compte existant"
            message = "Un compte existe déjà avec cette adresse mail !"
        } else if nb == 4 {
            title = "Champ manquant"
            message = "Tous les champs ne sont pas remplis !"
        } else if nb == 5 {
            title = "Mail invalide"
            message = "Ton mail n'est pas valide !"
        } else if nb == 6 {
            title = "Mot de passe invalide"
            message = "Le mot de passe doit contenir au moins 5 caractères !"
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

// Check that email adresss is valid 
extension RegistrationViewController {
    
    func isValidEmailAddress(emailAddressString: String) -> Bool {
        let mailRegex = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        do {
            let regex = try NSRegularExpression(pattern: mailRegex)
            let nsString = emailAddressString as NSString
            let results = regex.matches(in: emailAddressString, range: NSRange(location: 0, length: nsString.length))
            if results.count == 0 {
                return false
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return false
        }
        return true
   }
}
