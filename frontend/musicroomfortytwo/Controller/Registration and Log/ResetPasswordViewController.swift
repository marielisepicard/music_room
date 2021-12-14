//
//  ResetPasswordViewController.swift
//  musicroomfortytwo
//
//  Created by Jerome on 12/04/2021.
//

import UIKit

class ResetPasswordViewController: UIViewController {

    @IBOutlet weak var mailAddress: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }
    
    @objc func handleTap() {
        mailAddress.resignFirstResponder()
    }

    @IBAction func resetPassword(_ sender: Any) {
        let alertVC: UIAlertController
        alertVC = UIAlertController(title: title, message: "Voulez-vous vraiment réinitialiser le mot de passe de " + mailAddress.text! + " ?", preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Oui", style: UIAlertAction.Style.default, handler: validateResetPassword))
        alertVC.addAction(UIAlertAction(title: "Non", style: UIAlertAction.Style.default, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    func validateResetPassword(alert: UIAlertAction!) {
        ResetPassword.shared.resetPassword(mail: mailAddress.text!) { (success) in
            if (success == 1) {
                let alertVC: UIAlertController
                alertVC = UIAlertController(title: self.title, message: "Un mail avec votre nouveau mot de passe vous a été envoyé !", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                    self.navigationController?.popViewController(animated: true)
                }
                alertVC.addAction(action)
                self.present(alertVC, animated: true, completion: nil)
            } else {
                let alertVC: UIAlertController
                alertVC = UIAlertController(title: self.title, message: "L'addresse remplie n'est pas valide !", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default)
                alertVC.addAction(action)
                self.present(alertVC, animated: true, completion: nil)
            }
        }
    }
}
