//
//  AppDelegate.swift
//  musicroomfortytwo
//
//  Created by ML on 21/01/2021.
//

import UIKit
import GoogleSignIn
import FBSDKCoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch
        UserDefaults.standard.setValue("http://localhost:45559/api", forKey: "route")
        // UserDefaults.standard.setValue("http://62.34.5.191:45559/api", forKey: "route")
        UserDefaults.standard.setValue("http://62.34.5.191:45559", forKey: "socketServer")
        UserDefaults.standard.setValue("524786201017-giagchb12v60sefkfvhp0vbldap7hfak.apps.googleusercontent.com", forKey: "googleClientId")
        SocketIOManager.shared.establishConnection()
        
        // Initialize sign-in (Google)
        //GIDSignIn.sharedInstance().clientID = "856970011632-pvjlo12sq8ld2vltvbjbqjsoipmdhc19.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().clientID =  "524786201017-giagchb12v60sefkfvhp0vbldap7hfak.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance()?.restorePreviousSignIn()
        
        // Facebook SDK
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions:
                launchOptions
        )
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // Google & Facebook SDK
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        
        let google = GIDSignIn.sharedInstance()?.handle(url) ?? false
        
        let facebook = ApplicationDelegate.shared.application( app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation] )
    
        return google || facebook
    }
    
    // Google SDK
    func application(_ application: UIApplication,
                     open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
      return GIDSignIn.sharedInstance().handle(url)
    }
    
    // Google SDK
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
    print("sign is appDelegate is called!")
      if let error = error {
        if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
          print("The user has not signed in before or they have since signed out.")
        } else {
          print("\(error.localizedDescription)")
        }
        return
      }
      // Perform any operations on signed in user here.
//      let userId = user.userID                  // For client-side use only!
      let idToken = user.authentication.idToken // Safe to send to the server
//      let fullName = user.profile.name
//      let givenName = user.profile.givenName
//      let familyName = user.profile.familyName
//      let email = user.profile.email
      // ...
        NotificationCenter.default.post(name: .signInGoogleCompleted, object: nil)
        UserDefaults.standard.set(idToken, forKey: "googleToken")
        //UserDefaults.standard.setValue(idToken, forKey: "userToken")
    }
    
    // Google SDK
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
      // Perform any operations when the user disconnects from app here.
      // ...
    }
}

// Google Sign In Button
extension Notification.Name {

    // Notification when user successfully sign in using Google
    static var signInGoogleCompleted: Notification.Name {
        return .init(rawValue: #function)
    }
}

