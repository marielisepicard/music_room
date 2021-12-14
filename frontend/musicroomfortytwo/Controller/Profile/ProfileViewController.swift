//
//  ProfileViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 31/01/2021.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit


class ProfileViewController: UIViewController {

    @IBOutlet weak var disconnectButton: UIButton!
    @IBOutlet weak var pseudoLabel: UILabel!
    @IBOutlet weak var googleLinkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        SpotifyToken.shared.getSpotifyToken()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.view.subviews.forEach { $0.isHidden = true }
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        GetUserProfile.shared.getUserProfile() { (success) in
            if success == 1 {
                self.pseudoLabel.text = "Bienvenue " + GetUserProfile.shared.userInfos.pseudo
                UIView.transition(with: self.view, duration: 0.2, options: .transitionCrossDissolve, animations: self.displayAppearPage)
            } else {
                self.disconnectAccount(alert: nil)
            }
        }
    }
    
    func displayAppearPage() {
        self.view.subviews.forEach { $0.isHidden = false }
    }
    
    @IBAction func googleLinkButtonTapped(_ sender: Any) {
        self.googleLinkButton.isEnabled = false
        if GIDSignIn.sharedInstance()?.hasPreviousSignIn() == true {
            GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        } else {
            GIDSignIn.sharedInstance()?.signIn()
        }
        self.googleLinkButton.isEnabled = true
    }
    
    // Notification happening when a google user successfully connect himself
    @objc private func userDidSignInGoogle(_ notification: Notification) {
        if UserDefaults.standard.bool(forKey: "connected") == false {
            return
        }
        if GIDSignIn.sharedInstance()?.currentUser != nil {
            LinkAccountToGoogle.shared.linkAccountToGoogle() { (success) in
                if success == 1 {
                    self.presentAlert(nb: 1)
                } else {
                    self.presentAlert(nb: 2)
                }
            }
        }
    }
    
    func disconnectAccount(alert: UIAlertAction!) {
        self.disconnectButton.isEnabled = false
        removeUserInfos()
        if UserDefaults.standard.bool(forKey: "GoogleLogued") == true {
            if GIDSignIn.sharedInstance()?.currentUser != nil {
                GIDSignIn.sharedInstance()?.signOut()
                UserDefaults.standard.setValue(false, forKey: "GoogleLogued")
//                UserDefaults.standard.setValue("", forKey: "googleToken")
                UserDefaults.standard.set("", forKey: "userToken")
//                UserDefaults.standard.set("", forKey: "googleId")
                UserDefaults.standard.setValue("", forKey: "userId")
                UserDefaults.standard.setValue(false, forKey: "connected")
            }
        }
        if UserDefaults.standard.bool(forKey: "FacebookLogued") == true {
            UserDefaults.standard.setValue(false, forKey: "FacebookLogued")
            UserDefaults.standard.setValue("", forKey: "facebookToken")
            UserDefaults.standard.setValue("", forKey: "userToken")
            UserDefaults.standard.setValue(false, forKey: "connected")
            UserDefaults.standard.setValue("", forKey: "userId")
            UserDefaults.standard.set("", forKey: "facebookId")
            let loginManager = LoginManager()
            loginManager.logOut()
        }
        performSegue(withIdentifier: "unwind", sender: self)
    }
    
    @IBAction func disconnectButtonTapped(_ sender: Any) {
        let alertVC: UIAlertController
        alertVC = UIAlertController(title: title, message: "Voulez-vous vraiment vous déconnecter ?", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Oui", style: UIAlertAction.Style.default, handler: disconnectAccount))
        alertVC.addAction(UIAlertAction(title: "Non", style: UIAlertAction.Style.default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    private func removeUserInfos() {
        var roomControlDelegation: RoomControlDelegation!
        if let data = UserDefaults.standard.value(forKey:"roomControlDelegation") as? Data {
            roomControlDelegation = try? PropertyListDecoder().decode(RoomControlDelegation.self, from: data)
        }
        if (roomControlDelegation != nil) {
            SocketIOManager.shared.controlDelegLeaveRoom(friendId: UserDefaults.standard.value(forKey:"userId") as! String, roomId: roomControlDelegation.roomId)
        }
        UserDefaults.standard.setValue("", forKey: "userId")
        UserDefaults.standard.setValue("", forKey: "userToken")
        UserDefaults.standard.setValue(false, forKey: "connected")
        UserDefaults.standard.removeObject(forKey: "roomControlDelegation")
    }
    
    private func presentAlert(nb: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if nb == 0 {
            title = "Déjà connecté avec Google"
            message = "Ton compte est déjà lié, pas la peine :) "
        } else if nb == 1 {
            title = "Yeay"
            message = "Ton compte est bien lié :) "
        } else if nb == 2 {
            title = "Oups"
            message = "Désolé, on a une erreur en interne, reviens plus tard :) "
        }
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}
