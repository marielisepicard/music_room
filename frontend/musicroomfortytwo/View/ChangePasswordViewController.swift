//
//  ChangePasswordViewController.swift
//  musicroomfortytwo
//
//  Created by ML on 12/02/2021.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmNewPassword: UITextField!
    @IBOutlet weak var button: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        button.isEnabled = false
        button.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        self.navigationController?.isNavigationBarHidden = false
        currentPassword.delegate = self
        newPassword.delegate = self
        confirmNewPassword.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
        
    }
    @objc func handleTap() {
        currentPassword.resignFirstResponder() // dismiss keyoard
        newPassword.resignFirstResponder()
        confirmNewPassword.resignFirstResponder()
    }
    
    @IBAction func confirmationPasswordChange(_ sender: Any) {
        if currentPassword.text != "" && newPassword.text != "" && newPassword.text == confirmNewPassword.text {
            button.isEnabled = true
            button.backgroundColor = #colorLiteral(red: 0.115548484, green: 0.08298525959, blue: 0.3455429971, alpha: 1)
        } else {
            button.isEnabled = false
            button.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
    }
    
    @IBAction func newPasswordChange(_ sender: Any) {
        if currentPassword.text != "" && newPassword.text != "" && newPassword.text == confirmNewPassword.text {
            button.isEnabled = true
            button.backgroundColor = #colorLiteral(red: 0.115548484, green: 0.08298525959, blue: 0.3455429971, alpha: 1)
        } else {
            button.isEnabled = false
            button.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
    }
    @IBAction func currentPasswordChange(_ sender: Any) {
        if currentPassword.text != "" && newPassword.text != "" && newPassword.text == confirmNewPassword.text {
            button.isEnabled = true
            button.backgroundColor = #colorLiteral(red: 0.115548484, green: 0.08298525959, blue: 0.3455429971, alpha: 1)
        } else {
            button.isEnabled = false
            button.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        }
    }
    @IBAction func button(_ sender: Any) {
        self.button.isEnabled = false
        if newPassword.text != confirmNewPassword.text {
            presentAlert(nb: 4)
        }
        ChangePassword.shared.changePassword(currentPassword: currentPassword.text!, newPassword: newPassword.text!) { (success) in
            self.button.isEnabled = true
            self.presentAlert(nb: success) //1 = OK, 2 = CURRENT PASSWORD INVALID, 3 = bad format
            // 0 intern error
            if success == 1 {
                DispatchQueue.main.async {
                    self.currentPassword.text = ""
                    self.newPassword.text = ""
                    self.confirmNewPassword.text = ""
                    self.navigationController?.popViewController(animated: true)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}

extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension ChangePasswordViewController {
    
    private func presentAlert(nb: Int) {
        let alertVC: UIAlertController
        var title = ""
        var message = ""
        if nb == 2 {
            title = "Mot de passe actuel incorrect"
            message = ""
        } else if nb == 3 {
            title = "Format du nouveau mot de passe invalide"
            message = "Caractère autorisés: [a-zA-Z0-9éèàêô,'!@# -]"
        } else if nb == 0 {
            title = "Aie 😢"
            message = "On a des problèmes en interne, reviens plus tard !"
        } else {
            return
        }
        alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }

}
