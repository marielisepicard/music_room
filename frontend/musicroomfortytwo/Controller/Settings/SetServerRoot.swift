//
//  SetServerRoot.swift
//  musicroomfortytwo
//
//  Created by Tristan Leveque on 19/04/2021.
//

import Foundation

class SetServerRoot: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var serverAddress: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
        let savedServerAddress = UserDefaults.standard.string(forKey: "route")!.replacingOccurrences(of: "/api", with: "")
        serverAddress.text = savedServerAddress
        serverAddress.delegate = self
    }
    @IBAction func ValidateServerAddress(_ sender: Any) {
        if serverAddress == nil || serverAddress.text == "" {
            serverAddress.text = "http://62.34.5.191:45559"
        }
        UserDefaults.standard.setValue(serverAddress.text! + "/api", forKey: "route")
        UserDefaults.standard.setValue(serverAddress.text!, forKey: "socketServer")
        SocketIOManager.shared.setSocketServer()
        SocketIOManager.shared.establishConnection()
        self.dismiss(animated: true, completion: nil)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        serverAddress.resignFirstResponder()
        return true
    }
    @objc func handleTap() {
        serverAddress.resignFirstResponder()
    }
}
