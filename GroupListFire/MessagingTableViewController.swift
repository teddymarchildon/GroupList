//
//  MessagingTableViewController.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/29/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit
import Firebase

class MessagingTableViewController: UITableViewController {
    
    var group: Group!
    var messages: [FIRDataSnapshot]! = []
    let ref = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/")
    var currentUser = FIRAuth.auth()?.currentUser!
    var parentController: MessagingParentViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 75
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        ref.child("groups").child("\(group.createdBy)-\(group.name)-\(group.topic)").child("messages").observeEventType(.ChildAdded, withBlock: { snapshot in
            self.messages.append(snapshot)
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.messages.count-1, inSection: 0)], withRowAnimation: .Automatic)
        })
    }
    
    func dismissKeyboard() {
        parentController.view.endEditing(true)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCellWithIdentifier("messagingCell", forIndexPath: indexPath) as! MessagingTableViewCell
        cell.usernameLabel.adjustsFontSizeToFitWidth = true
        cell.messageTextLabel.adjustsFontSizeToFitWidth = true
        let messageSnapshot: FIRDataSnapshot! = self.messages[indexPath.row]
        let message = messageSnapshot.value as! [String: String]
        let name = message["user"] as String!
        if let text = message["text"] as String! {
            cell.messageTextLabel.text = "\(text)"
        } else {
            cell.messageTextLabel.text = ""
        }
        cell.usernameLabel.text = "\(name)"
        if let imageUrl = message["imageUrl"] {
            if imageUrl.hasPrefix("gs://") {
                FIRStorage.storage().referenceForURL(imageUrl).dataWithMaxSize(INT64_MAX){ (data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    cell.messageImage.image = UIImage(data: data!)
                }
            } else if let url = NSURL(string: imageUrl), data = NSData(contentsOfURL: url) {
                cell.messageImage.image = UIImage(data: data)
            }
            cell.usernameLabel.text = "\(name)"
        } else {
            if let photoUrl = message["imageUrl"], url = NSURL(string:photoUrl), data = NSData(contentsOfURL: url) {
                cell.messageImage.image = UIImage(data: data)
            }
        }
        return cell
    }
}
