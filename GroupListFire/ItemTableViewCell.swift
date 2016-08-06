//
//  ItemTableViewCell.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/17/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit
import Firebase
import MessageUI

protocol ChangeFromCellDelegate: NSObjectProtocol {
    func loadNewScreen(controller: UIViewController)
}

class ItemTableViewCell: UITableViewCell, MFMailComposeViewControllerDelegate {
    
    let myRef = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/")
    
    @IBOutlet weak var editItemButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var assignedToLabel: UILabel!
    @IBOutlet weak var timeFrameLabel: UILabel!
    @IBOutlet weak var assignToButton: UIButton!
    var item: ListItem?
    var currGroup: Group?
    weak var delegate: ChangeFromCellDelegate?
    
    @IBAction func assignItemToUser(sender: AnyObject) {
        let alert = UIAlertController(title: "Assign To", message: nil, preferredStyle: .ActionSheet)
        for user in self.currGroup!.groupUsers {
            let name = user.componentsSeparatedByString("-")[0]
            let userAction = UIAlertAction(title: name, style: .Default) { (action: UIAlertAction!) -> Void in
                self.item!.assignToUser(user)
                let notifyAlert = UIAlertController(title: "Would you like to email the user you just added?", message: nil, preferredStyle: .Alert)
                let yesAction = UIAlertAction(title: "Yes", style: .Default) { (action: UIAlertAction!) -> Void in
                    self.configuredMailComposeViewController(user)
                }
                let noAction = UIAlertAction(title: "No", style: .Default, handler: nil)
                notifyAlert.addAction(noAction)
                notifyAlert.addAction(yesAction)
                if (self.delegate?.respondsToSelector(#selector(ListTableViewController.loadNewScreen))) != nil {
                    self.delegate?.loadNewScreen(notifyAlert)
                }
            }
            alert.addAction(userAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        if (delegate?.respondsToSelector(#selector(ListTableViewController.loadNewScreen))) != nil {
            delegate?.loadNewScreen(alert)
        }
    }
    
    func sendMail(mailComposeViewController: MFMailComposeViewController) {
        if MFMailComposeViewController.canSendMail() {
            if (delegate?.respondsToSelector(#selector(ListTableViewController.loadNewScreen))) != nil {
                delegate?.loadNewScreen(mailComposeViewController)
            }
        } else {
            if (delegate?.respondsToSelector(#selector(ListTableViewController.loadNewScreen))) != nil {
                delegate?.loadNewScreen(showSendMailErrorAlert("Your device could not send email at this time. Please try again later"))
            }
        }
    }
    
    func showSendMailErrorAlert(message: String) -> UIAlertController{
        let alert = UIAlertController(title: "Could not send email", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        return alert
    }
    
    func configuredMailComposeViewController(user: String) {
        self.myRef.child("users").child(user).observeSingleEventOfType(.Value, withBlock: {snapshot in
            let mailComposerVC = MFMailComposeViewController()
            if let postDict = snapshot.value as? [String: AnyObject] {
                if let email = postDict["email"] as? String {
                    mailComposerVC.mailComposeDelegate = self
                    mailComposerVC.setToRecipients([email])
                    mailComposerVC.setSubject("You've been assigned an item in GrpLst")
                    mailComposerVC.setMessageBody("You've been assigned \(self.item!.name) from the \(self.currGroup!.name) group", isHTML: false)
                    self.sendMail(mailComposerVC)
                } else {
                    if (self.delegate?.respondsToSelector(#selector(ListTableViewController.loadNewScreen))) != nil {
                        self.delegate?.loadNewScreen(self.showSendMailErrorAlert("That user does not have a registered email"))
                    }
                }
            }
        })
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func setNewProperties(sender: AnyObject) {
        let alert = UIAlertController(title: "Edit Item", message: nil, preferredStyle: .Alert)
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
            let nameField = alert.textFields![0].text!
            let detailField = alert.textFields![2].text!
            let timeFrame = alert.textFields![1].text!
            if ErrorAlerts.containsInvalidCharacters(nameField) {
                let malTextAlert = ErrorAlerts.invalidTextEntered("Name may not contain the following characters: $ # / [ ] .")
                if (self.delegate?.respondsToSelector(#selector(ListTableViewController.loadNewScreen))) != nil {
                    self.delegate?.loadNewScreen(malTextAlert)
                }
                return
            } else {
                self.item!.setNewProperties(newName: nameField, newQuantity: detailField, newTimeFrame: timeFrame)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        alert.addTextFieldWithConfigurationHandler { (textGroup) -> Void in
            textGroup.placeholder = "New Name"
            textGroup.autocorrectionType = UITextAutocorrectionType.Default
            textGroup.autocapitalizationType = UITextAutocapitalizationType.Sentences
            textGroup.clearButtonMode = UITextFieldViewMode.WhileEditing
        }
        alert.addTextFieldWithConfigurationHandler { (quantity) -> Void in
            quantity.placeholder = "When does it need to get done?"
            quantity.autocorrectionType = UITextAutocorrectionType.Default
            quantity.autocapitalizationType = UITextAutocapitalizationType.Sentences
            quantity.clearButtonMode = UITextFieldViewMode.WhileEditing
            
        }
        alert.addTextFieldWithConfigurationHandler { (timeFrame) -> Void in
            timeFrame.placeholder = "Additional notes"
            timeFrame.autocorrectionType = UITextAutocorrectionType.Default
            timeFrame.autocapitalizationType = UITextAutocapitalizationType.Sentences
            timeFrame.clearButtonMode = UITextFieldViewMode.WhileEditing
        }
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        if (delegate?.respondsToSelector(#selector(ListTableViewController.loadNewScreen))) != nil {
            delegate?.loadNewScreen(alert)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
