//
//  ViewController.swift
//  GroupList
//
//  Created by Teddy Marchildon on 7/5/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate, ChangeFromCellDelegate {
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    var facebookLoginButton: FBSDKLoginButton = FBSDKLoginButton()
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    var myRef: FIRDatabaseReference? = nil
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let view: UIView = UIView(frame: self.view.frame)
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.view.frame
        gradient.colors = [UIColor(red: 48/255.0, green: 131/255.0, blue: 251/255.0, alpha: 1.0).CGColor, UIColor.whiteColor().CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
        self.view.addSubview(view)
        self.view.addSubview(welcomeLabel)
        self.view.addSubview(infoLabel)
        self.view.addSubview(googleSignInButton)
        self.view.addSubview(activityIndicator)
        GIDSignIn.sharedInstance().uiDelegate = self
        self.facebookLoginButton.delegate = self
        self.facebookLoginButton.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 80)
        self.facebookLoginButton.readPermissions = ["public_profile", "email"]
        self.view.addSubview(facebookLoginButton)
        myRef = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/")
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let _ = user?.displayName {
                self.performSegueWithIdentifier("loginSegue", sender: nil)
            } else {
                self.facebookLoginButton.hidden = false
                self.googleSignInButton.hidden = false
            }
        }
        self.facebookLoginButton.hidden = false
    }
    
    func loadNewScreen(controller: UIViewController) {
        self.signupErrorAlert("Sign Up Error", message: "You need a display name to use this app")
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        self.activityIndicator.startAnimating()
        self.facebookLoginButton.hidden = true
        self.googleSignInButton.hidden = true
        if let error = error {
            print(error.localizedDescription)
            self.signupErrorAlert("Oops! Something went wrong", message: "Try Again")
            self.facebookLoginButton.hidden = false
            self.googleSignInButton.hidden = false
            activityIndicator.stopAnimating()
            return
        } else if result.isCancelled {
            self.facebookLoginButton.hidden = false
            self.googleSignInButton.hidden = false
            activityIndicator.stopAnimating()
        } else {
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                if error == nil {
                    if let user = user {
                        if let displayName = user.displayName {
                            self.myRef?.child("users").child("\(user.displayName!)-\(user.uid)").child("username").setValue(displayName)
                        } else {
                            self .signupErrorAlert("Error!", message: "You need a display name to use this app")
                        }
                        if let email = user.email {
                            self.myRef?.child("users").child("\(user.displayName!)-\(user.uid)").child("email").setValue(email)
                        }
                        self.myRef?.child("users").child("\(user.displayName!)-\(user.uid)").child("id").setValue(user.uid)
                        if let photoUrl = user.photoURL {
                            self.myRef?.child("users").child("\(user.displayName!)-\(user.uid)").child("photoURL").setValue(String(photoUrl))
                        }
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

