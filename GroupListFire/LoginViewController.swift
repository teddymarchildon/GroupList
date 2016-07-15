//
//  ViewController.swift
//  GroupList
//
//  Created by Teddy Marchildon on 7/5/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {
    
    @IBOutlet weak var facebookLoginButton: FBSDKLoginButton!
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    var myRef: FIRDatabaseReference? = nil
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().uiDelegate = self
//        GIDSignIn.sharedInstance().signInSilently()
        self.facebookLoginButton.delegate = self
        self.facebookLoginButton.readPermissions = ["public_profile", "email"]
        myRef = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/")
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let _ = user {
                self.facebookLoginButton.hidden = false
                self.performSegueWithIdentifier("loginSegue", sender: nil)
            } else {
                self.facebookLoginButton.hidden = false
            }
        }
//        self.facebookLoginButton.hidden = false
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        self.facebookLoginButton.hidden = true
        self.activityIndicator.startAnimating()
        if let error = error {
            print(error.localizedDescription)
            self.facebookLoginButton.hidden = false
            activityIndicator.stopAnimating()
        } else if result.isCancelled {
            self.facebookLoginButton.hidden = false
            activityIndicator.stopAnimating()
        } else {
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                if error == nil {
                    if let user = user, displayName = user.displayName {
                        self.myRef?.child("users").child(displayName).child("username").setValue([
                            "username": displayName,
                            ])
                        self.performSegueWithIdentifier("loginSegue", sender: nil)
                    }
                } else {
                    print(error?.localizedDescription)
                    self.signupErrorAlert("Oops! Something went wrong", message: "Try Again")
                }
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        try! FIRAuth.auth()!.signOut()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func signupErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}

