//
//  MessagingTextFieldViewController.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/29/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit
import Firebase
import Photos

class MessagingTextFieldViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var messageTextFieldBottomConstraint: NSLayoutConstraint!
    var originalBottomConstraint: CGFloat? = nil
    var keyboardHeight: CGFloat = 0.0
    let ref = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/")
    var storageRef: FIRStorageReference!
    var group: Group!
    var currentUser = FIRAuth.auth()?.currentUser!
    var parentController: MessagingParentViewController!
    var keyboardIsUp: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.originalBottomConstraint = self.messageTextFieldBottomConstraint.constant
        messageTextField.delegate = self
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        storageRef = FIRStorage.storage().referenceForURL("gs://grouplistfire-39d22.appspot.com")
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillChangeFrame(_ :)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillChangeFrame), name: UIKeyboardWillChangeFrameNotification, object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dismissKeyboard() {
        parentController.view.endEditing(true)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if !textField.text!.isEmpty {
            let text = textField.text! as String
            let name = FIRAuth.auth()?.currentUser!.displayName!
            var data = [String: String]()
            data["user"] = name
            data["text"] = text
            sendMessage(data)
            textField.text = ""
            textField.resignFirstResponder()
        }
        return true
    }
    
    func sendMessage(data: [String: String]) {
        self.ref.child("groups").child("\(group.createdBy)-\(group.name)-\(group.topic)").child("messages").childByAutoId().setValue(data)
    }
    
    @IBAction func didPressSendButton(sender: AnyObject) {
        self.textFieldShouldReturn(self.messageTextField)
    }
    
    @IBAction func didPressAddPhotoButton(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            let available = UIImagePickerController.availableMediaTypesForSourceType(.PhotoLibrary)
            if let available = available {
                if available.contains("kUTTypeImage") {
                    picker.mediaTypes = ["kUTTypeImage"]
                }
            }
        }
        picker.allowsEditing = false
        presentViewController(picker, animated: true, completion:nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let imageData = UIImageJPEGRepresentation(image, 0.1)
        let imagePath = "\(FIRAuth.auth()!.currentUser!.uid)/\(Int(NSDate.timeIntervalSinceReferenceDate() * 1000)).jpg"
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        self.storageRef.child(imagePath).putData(imageData!, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error uploading: \(error)")
                return
            }
            self.sendMessage(["imageUrl":
                self.storageRef.child((metadata?.path)!).description,
                "user": self.currentUser!.displayName!])
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion:nil)
    }
    
    //    func keyboardWillShow(notification: NSNotification) {
    //        if let userInfoDict = notification.userInfo, keyboardFrameValue = userInfoDict[UIKeyboardFrameEndUserInfoKey] as? NSValue{
    //            let keyboardFrame = keyboardFrameValue.CGRectValue()
    //            UIView.animateWithDuration(1.0){
    //                self.keyboardHeight = keyboardFrame.size.height
    //                print(self.keyboardHeight)
    //                self.messageTextField.backgroundColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1.0)
    //                self.messageTextFieldBottomConstraint.constant += self.keyboardHeight
    //                self.view.layoutIfNeeded()
    //            }
    //        }
    //    }
    
    func keyboardWillChangeFrame(notification: NSNotification) {
        if let userInfoDict = notification.userInfo, keyboardFrameValue = userInfoDict[UIKeyboardFrameEndUserInfoKey] as? NSValue{
            let keyboardFrame = keyboardFrameValue.CGRectValue()
            self.keyboardHeight = keyboardFrame.size.height
            self.messageTextField.backgroundColor = UIColor(red: 204/255.0, green: 204/255.0, blue: 204/255.0, alpha: 1.0)
            self.messageTextFieldBottomConstraint.constant = self.originalBottomConstraint! + self.keyboardHeight
            self.view.layoutIfNeeded()
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        UIView.animateWithDuration(1.0) {
            self.keyboardIsUp = false
            self.messageTextField.backgroundColor = .whiteColor()
            self.messageTextFieldBottomConstraint.constant = self.originalBottomConstraint!
            self.view.layoutIfNeeded()
        }
    }
}
