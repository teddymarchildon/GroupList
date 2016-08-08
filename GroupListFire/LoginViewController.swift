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
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    var facebookLoginButton: FBSDKLoginButton = FBSDKLoginButton()
    @IBOutlet weak var googleSignInButton: GIDSignInButton!
    var myRef: FIRDatabaseReference? = nil
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let view: UIView = UIView(frame: self.view.frame)
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.view.frame
        gradient.colors = [UIColor(red: 48/255.0, green: 131/255.0, blue: 251/255.0, alpha: 1.0).CGColor, UIColor.whiteColor().CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.didTap))
        view.addGestureRecognizer(tap)
        self.view.addSubview(view)
        self.view.addSubview(welcomeLabel)
        self.view.addSubview(infoLabel)
        self.view.addSubview(activityIndicator)
        GIDSignIn.sharedInstance().uiDelegate = self
        self.view.addSubview(emailTextField)
        self.view.addSubview(passwordTextField)
        self.view.addSubview(signInButton)
        self.view.addSubview(signUpButton)
        self.view.addSubview(googleSignInButton)
        self.facebookLoginButton.delegate = self
        self.facebookLoginButton.center = CGPoint(x: self.view.center.x, y: self.view.center.y + 180)
        self.facebookLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.view.addSubview(facebookLoginButton)
        myRef = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/")
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let _ = user {
                self.performSegueWithIdentifier("loginSegue", sender: nil)
            } else {
                self.facebookLoginButton.hidden = false
                self.googleSignInButton.hidden = false
            }
        }
        self.facebookLoginButton.hidden = false
    }
    
    func didTap() {
        self.view.endEditing(true)
    }
    
    func loadNewScreen(controller: UIViewController) {
        self.signupErrorAlert("Sign Up Error", message: "You need a display name to use this app")
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        self.activityIndicator.startAnimating()
        self.facebookLoginButton.hidden = true
        self.googleSignInButton.hidden = true
        self.emailTextField.hidden = true
        self.passwordTextField.hidden = true
        if let error = error {
            print(error.localizedDescription)
            self.signupErrorAlert("Oops! Something went wrong", message: "Try Again")
            self.facebookLoginButton.hidden = false
            self.googleSignInButton.hidden = false
            self.emailTextField.hidden = false
            self.passwordTextField.hidden = false
            activityIndicator.stopAnimating()
            return
        } else if result.isCancelled {
            self.facebookLoginButton.hidden = false
            self.googleSignInButton.hidden = false
            self.emailTextField.hidden = false
            self.passwordTextField.hidden = false
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
    
    @IBAction func signInButtonPressed(sender: AnyObject) {
        let email = emailTextField.text!
        let password = passwordTextField.text!
        FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
            if error == nil {
                self.passwordTextField.hidden = true
                self.emailTextField.hidden = true
                self.activityIndicator.startAnimating()
                self.performSegueWithIdentifier("loginSegue", sender: nil)
            } else {
                self.signupErrorAlert("Oops! Something went wrong", message: "Please try again")
                self.emailTextField.text = ""
                self.passwordTextField.text = ""
            }
        }
    }
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        let alert = UIAlertController(title: "Register", message: nil, preferredStyle: .Alert)
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
            let emailField = alert.textFields![0].text!
            let passwordField = alert.textFields![1].text!
            if !emailField.isEmpty && !passwordField.isEmpty && !ErrorAlerts.containsInvalidCharacters(emailField.componentsSeparatedByString("@")[0]){
                FIRAuth.auth()?.createUserWithEmail(emailField, password: passwordField) { (user, error) in
                    if error == nil {
                        self.passwordTextField.hidden = true
                        self.emailTextField.hidden = true
                        self.activityIndicator.startAnimating()
                        self.myRef?.child("users").child("\(emailField.componentsSeparatedByString("@")[0])-\(user!.uid)").child("email").setValue(emailField)
                        self.myRef?.child("users").child("\(emailField.componentsSeparatedByString("@")[0])-\(user!.uid)").child("id").setValue(user!.uid)
                        self.performSegueWithIdentifier("loginSegue", sender: nil)
                    } else {
                        print(error?.localizedDescription)
                        self.signupErrorAlert("Oops! Something went wrong", message: "We couldn't sign you in. Please try again")
                        return
                    }
                }
            } else {
                self.signupErrorAlert("Email and password cannot be empy, nor contain the following characters: $ # / [ ] . -", message: "I know that is a pain, so if your only email contains those then log in with Facebook or Google please")
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addTextFieldWithConfigurationHandler { (textGroup) -> Void in
            textGroup.placeholder = "email"
            textGroup.clearButtonMode = UITextFieldViewMode.WhileEditing
        }
        alert.addTextFieldWithConfigurationHandler { (quantity) -> Void in
            quantity.placeholder = "password"
            quantity.secureTextEntry = true
            quantity.clearButtonMode = UITextFieldViewMode.WhileEditing
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        presentViewController(alert, animated: true, completion: nil)
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

