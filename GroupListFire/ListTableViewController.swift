//
//  ListTableViewController.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/7/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit
import Firebase

class ListTableViewController: UITableViewController {
    
    var myRef: FIRDatabaseReference? = nil
    let user = FIRAuth.auth()?.currentUser
    var currGroup: Group?
    var currGroupObject: AnyObject?
    var lastClick: NSTimeInterval?
    var lastIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.rowHeight = CGFloat(75.0)
        myRef = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/")
        self.clearsSelectionOnViewWillAppear = false
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        let ref = self.myRef?.child("groups").child("\(currGroup!.name)-\(currGroup!.topic)").child("items")
        ref?.queryOrderedByChild("completed").observeEventType(.Value, withBlock: { snapshot in
            var newItems: [ListItem] = []
            for item in snapshot.children {
                if let item = item as? FIRDataSnapshot {
                    let postDict = item.value as! [String: AnyObject]
                    let newListItem = ListItem(withName: postDict["name"] as! String, andQuantity: postDict["quantity"] as! String, completed: postDict["completed"] as! Bool, groupRef: item.ref)
                    newItems.append(newListItem)
                }
            }
            self.currGroup!.list.items = newItems
            self.tableView.reloadData()
            }, withCancelBlock: { error in
                print(error.description)
        })
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currGroup!.list.items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("listCell", forIndexPath: indexPath)
        cell.selectionStyle = .None
        let item = currGroup!.list.items[indexPath.row]
        let itemName = item.name
        let detail = item.quantity
        cell.textLabel?.text = itemName
        cell.detailTextLabel?.text = detail
        toggleCellCheckbox(cell, isCompleted: item.completed)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let now: NSTimeInterval = NSDate().timeIntervalSince1970
        if let lastClick = lastClick, lastIndexPath = lastIndexPath {
            if (now - lastClick < 0.3) && indexPath.isEqual(lastIndexPath) {
                let cell = tableView.dequeueReusableCellWithIdentifier("listCell", forIndexPath: indexPath)
                cell.selectionStyle = .None
                let item = currGroup!.list.items[indexPath.row]
                let toggledCompletion = !item.completed
                toggleCellCheckbox(cell, isCompleted: toggledCompletion)
                item.groupRef?.updateChildValues([
                    "completed": toggledCompletion
                    ])
            }
        }
        lastClick = now
        lastIndexPath = indexPath
    }
    
    
    func toggleCellCheckbox(cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = UITableViewCellAccessoryType.None
            cell.textLabel?.textColor = UIColor.blackColor()
            cell.detailTextLabel?.textColor = UIColor.blackColor()
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            cell.textLabel!.textColor = UIColor.grayColor()
            cell.detailTextLabel!.textColor = UIColor.grayColor()
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let item = currGroup!.list.items[indexPath.row]
            item.groupRef!.removeValue()
            tableView.reloadData()
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    @IBAction func addItemToList(sender: AnyObject) {
        let alert = UIAlertController(title: "New Item", message: nil, preferredStyle: .Alert)
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
            let nameField = alert.textFields![0]
            let detailField = alert.textFields![1]
            let newItem = ListItem(withName: nameField.text!, andQuantity: detailField.text!)
            self.currGroup!.list.items.append(newItem)
            for item in self.currGroup!.list.items {
                let newItemDict = ["name": item.name,
                                   "quantity": item.quantity,
                                   "completed": item.completed,
                                   "createdBy": self.user!.displayName!]
                self.myRef?.child("groups").child("\(self.currGroup!.name)-\(self.currGroup!.topic)").child("items").child(nameField.text!).setValue(newItemDict)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction!) -> Void in
            self.view.endEditing(true)
        }
        
        alert.addTextFieldWithConfigurationHandler { (textGroup) -> Void in
            textGroup.placeholder = "Item Name"
        }
        alert.addTextFieldWithConfigurationHandler { (quantity) -> Void in
            quantity.placeholder = "Details"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func addUsersToGroup(sender: AnyObject) {
        let alert = UIAlertController(title: "Add User", message: nil, preferredStyle: .Alert)
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
            let nameField = alert.textFields![0]
            self.findUserInDatabase(nameField.text!)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction!) -> Void in
            self.view.endEditing(true)
        }
        
        alert.addTextFieldWithConfigurationHandler { (textGroup) -> Void in
            textGroup.placeholder = "Username"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func findUserInDatabase(username: String) {
        self.myRef?.child("users").child(username).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let _ = snapshot.value as? NSNull {
                print("no user")
            } else {
                let postDict = snapshot.value as! [String: AnyObject]
                let baseUsername = postDict["username"]!["username"] as? String
                if let baseUsername = baseUsername {
                    self.myRef?.child("users").child(baseUsername).child("userGroups").child("\(self.currGroup!.name)-\(self.currGroup!.topic)").setValue(["name": "\(self.currGroup!.name)-\(self.currGroup!.topic)"])
                }
            }
        })
    }
    
    
    /*
     
     
     
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
