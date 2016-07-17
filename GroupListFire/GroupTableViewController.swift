//
//  GroupTableViewController.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/7/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import FBSDKCoreKit
import FirebaseAuth

protocol FirebaseDelegation {
    
    func didFetchData(data: [String])
    
}

class GroupTableViewController: UITableViewController, FirebaseDelegation {
    
    var myUserRef: FIRDatabaseReference? = nil
    var myGroupRef: FIRDatabaseReference? = nil
    var userGroups: [Group] = []
    let user = FIRAuth.auth()?.currentUser
    var displayName: String {
        return (user?.displayName!)!
    }
    
    override func viewDidLoad() {
        myUserRef = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/").child("users").child(displayName)
        myGroupRef = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/").child("groups")
        let ref = myUserRef?.child("userGroups")
        ref?.observeEventType(.Value, withBlock: { snapshot in
            var newNames: [String] = []
            for item in snapshot.children {
                if let item = item as? FIRDataSnapshot {
                    let postDict = item.value as! [String: String]
                    newNames.append(postDict["name"]!)
                }
            }
           self.didFetchData(newNames)
        })
        super.viewDidLoad()
    }
    
    func didFetchData(data: [String]) {
        self.userGroups = []
        for item in data {
            self.myGroupRef?.child(item).observeSingleEventOfType(.Value, withBlock: { snapshot in
                let newGroup = Group(snapshot: snapshot)
                self.userGroups.append(newGroup)
                self.tableView.reloadData()
            })
        }
    }
    
    @IBAction func addGroup(sender: AnyObject) {
        let groupRef = self.myGroupRef!
        let alert = UIAlertController(title: "New Group", message: nil, preferredStyle: .Alert)
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
            let nameField = alert.textFields![0]
            let topicField = alert.textFields![1]
            let group = Group(withName: nameField.text!, andTopic: topicField.text!, andList: List(), andUser: self.user!)
            let newGroupRef = groupRef.child("\(nameField.text!)-\(topicField.text!)")
            newGroupRef.setValue(group.toAnyObject(self.user!))
            var nameArray: [String] = []
            for group in self.userGroups {
                nameArray.append(group.name)
            }
            self.myUserRef?.child("userGroups").child("\(nameField.text!)-\(topicField.text!)").setValue(["name": "\(nameField.text!)-\(topicField.text!)"])
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        alert.addTextFieldWithConfigurationHandler { (textGroup) -> Void in
            textGroup.placeholder = "Group Name"
        }
        
        alert.addTextFieldWithConfigurationHandler { (textTopic) -> Void in
            textTopic.placeholder = "Group Topic"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userGroups.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("groupCell", forIndexPath: indexPath)
        cell.textLabel?.text = userGroups[indexPath.row].name
        cell.detailTextLabel?.text = userGroups[indexPath.row].topic
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        return cell
    }
    
    @IBAction func logOut(sender: AnyObject) {
        try! FIRAuth.auth()!.signOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
        self.performSegueWithIdentifier("backToLogin", sender: nil)
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let group = userGroups[indexPath.row]
            self.userGroups.removeAtIndex(indexPath.row)
            var i = 0
            for user in group.groupUsers {
                if user == self.user!.displayName! {
                    group.groupUsers.removeAtIndex(i)
                }
                i += 1
            }
            myUserRef?.child("userGroups").child("\(group.name)-\(group.topic)").removeValue()
            myGroupRef?.child("\(group.name)-\(group.topic)").child("users").setValue(group.groupUsers)
            tableView.reloadData()
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "listSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let listController = segue.destinationViewController as! ListTableViewController
                listController.currGroup = userGroups[indexPath.row]
                listController.currGroupObject = userGroups[indexPath.row].toAnyObject(self.user!)
                listController.title = "\(userGroups[indexPath.row].name) list"
            }
        }
    }
}
