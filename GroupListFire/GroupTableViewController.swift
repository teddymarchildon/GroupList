//
//  GroupTableViewController.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/7/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit
import Firebase

class GroupTableViewController: UITableViewController {
    
    var myRef: FIRDatabaseReference? = nil
    var userGroups: [Group] = []
    let user = FIRAuth.auth()?.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myRef = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/")
        self.clearsSelectionOnViewWillAppear = false
    }
    
    override func viewDidAppear(animated: Bool) {
        let ref = myRef?.child("groups")
        ref?.observeEventType(.Value, withBlock: { snapshot in
            var newGroups: [Group] = []
            for item in snapshot.children {
                if let item = item as? FIRDataSnapshot {
                    let dict = item.value as! [String: AnyObject]
                    let list = dict["list"] as? [String]
                    if let list = list {
                        let group = Group(snapshot: item, andList: List(list: list))
                        newGroups.append(group)
                    } else {
                        let group = Group(snapshot: item, andList: List())
                        newGroups.append(group)
                    }
                }
            }
            self.userGroups = newGroups
            self.tableView.reloadData()
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    @IBAction func addGroup(sender: AnyObject) {
        let ref = self.myRef?.child("groups")
        let alert = UIAlertController(title: "New Group", message: nil, preferredStyle: .Alert)
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
            let nameField = alert.textFields![0]
            let topicField = alert.textFields![1]
            let group = Group(withName: nameField.text!, andTopic: topicField.text!, andList: List())
            let newRef = ref?.child("\(nameField.text!)-\(topicField.text!)")
            if let newRef = newRef {
                newRef.setValue(group.toAnyObject(self.user!))
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction!) -> Void in
            self.view.endEditing(true)
        }
        
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
        return cell
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let group = userGroups[indexPath.row]
            group.ref?.removeValue()
            tableView.reloadData()
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
     
     }
     */
    
    // Override to support conditional rearranging of the table view.
    //    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    //        return true
    //    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "listSegue" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let listController = segue.destinationViewController as! ListTableViewController
                listController.currGroup = userGroups[indexPath.row]
                listController.title = "\(userGroups[indexPath.row].name)  List"
            }
        }
    }
}
