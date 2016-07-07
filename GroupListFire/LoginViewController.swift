//
//  ViewController.swift
//  GroupList
//
//  Created by Teddy Marchildon on 7/5/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var myRef: FIRDatabaseReference? = nil
    
    override func viewDidLoad() {
        FIRApp.configure()
        myRef = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/")
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let _ = user {
                self.performSegueWithIdentifier("loginSegue", sender: nil)
            }
        }
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.hideKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func hideKeyboard () {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func loginButtonPressed(sender: AnyObject) {
        if let email = usernameTextField.text, password = passwordTextField.text {
            FIRAuth.auth()?.signInWithEmail(email, password: password) { (user, error) in
                if error == nil {
                    self.performSegueWithIdentifier("loginSegue", sender: nil)
                } else {
                    self.signupErrorAlert("Oops! Something went wrong", message: "Try Again")
                }
            }
        }
    }
    
    @IBAction func signUpButtonPressed(sender: AnyObject) {
        let alert = UIAlertController(title: "Register", message: nil, preferredStyle: .Alert)
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
            let emailField = alert.textFields![0]
            let passwordField = alert.textFields![1]
            let usernameField = alert.textFields![2]
            FIRAuth.auth()?.createUserWithEmail(emailField.text!, password: passwordField.text!) { (user, error) in
                if error == nil {
                    FIRAuth.auth()?.signInWithEmail(emailField.text!, password: passwordField.text!) { (user, error) in
                        if error == nil {
                            self.myRef?.child("users").child(user!.uid).setValue(["username": usernameField.text!])
                            self.performSegueWithIdentifier("loginSegue", sender: nil)
                        }
                    }
                } else {
                    self.signupErrorAlert("Oops! Something went wrong", message: "Try Again")
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction!) -> Void in
            self.view.endEditing(true)
        }
        
        alert.addTextFieldWithConfigurationHandler { (textEmail) -> Void in
            textEmail.placeholder = "Enter your email"
        }
        
        alert.addTextFieldWithConfigurationHandler { (textPassword) -> Void in
            textPassword.secureTextEntry = true
            textPassword.placeholder = "Enter your password"
        }
        
        alert.addTextFieldWithConfigurationHandler { (username) -> Void in
            username.placeholder = "Create a username"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func signupErrorAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Ok", style: .Default, handler: nil)
        alert.addAction(action)
        presentViewController(alert, animated: true, completion: nil)
    }
}

