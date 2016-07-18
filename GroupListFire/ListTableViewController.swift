//
//  ListTableViewController.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/7/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit
import Firebase

class ListTableViewController: UITableViewController, ChangeFromCellDelegate {
    
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
        self.clearsSelectionOnViewWillAppear = true
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        let ref = self.myRef?.child("groups").child("\(currGroup!.createdBy)-\(currGroup!.name)-\(currGroup!.topic)").child("items")
        ref?.queryOrderedByChild("completed").observeEventType(.Value, withBlock: { snapshot in
            var newItems: [ListItem] = []
            for item in snapshot.children {
                if let item = item as? FIRDataSnapshot {
                    let newListItem = ListItem(snapshot: item)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemTableViewCell", forIndexPath: indexPath) as! ItemTableViewCell
        cell.selectionStyle = .None
        let item = currGroup!.list.items[indexPath.row]
        cell.item = item
        cell.group = currGroup
        cell.delegate = self
        cell.titleLabel.text = item.name
        cell.quantityLabel.text = item.quantity
        cell.createdByLabel.text = item.createdBy
        cell.assignedToLabel.text = item.assignedTo
        cell.timeFrameLabel.text = item.timeFrame
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        toggleCellCheckbox(cell, isCompleted: item.completed)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let now: NSTimeInterval = NSDate().timeIntervalSince1970
        if let lastClick = lastClick, lastIndexPath = lastIndexPath {
            if (now - lastClick < 0.3) && indexPath.isEqual(lastIndexPath) {
                let cell = tableView.dequeueReusableCellWithIdentifier("ItemTableViewCell", forIndexPath: indexPath) as! ItemTableViewCell
                cell.selectionStyle = .None
                let item = currGroup!.list.items[indexPath.row]
                let toggledCompletion = !item.completed
                toggleCellCheckbox(cell, isCompleted: toggledCompletion)
                item.groupRef?.updateChildValues([
                    "completed": toggledCompletion
                    ])
                return
            }
        }
        lastClick = now
        lastIndexPath = indexPath
    }
    
    func loadNewScreen(controller: UIViewController, item: ListItem) {
        let alert = UIAlertController(title: "Assign To", message: nil, preferredStyle: .ActionSheet)
        for user in currGroup!.groupUsers {
            let userAction = UIAlertAction(title: user, style: .Default) { (action: UIAlertAction!) -> Void in
                item.assignedTo = user
                self.myRef?.child("groups").child("\(self.currGroup!.createdBy)-\(self.currGroup!.name)-\(self.currGroup!.topic)").child("items").child(item.name).setValue(item.toAnyObject())
            }
            alert.addAction(userAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func toggleCellCheckbox(cell: ItemTableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = UITableViewCellAccessoryType.None
            cell.titleLabel.textColor = UIColor.blackColor()
            cell.quantityLabel.textColor = UIColor.blackColor()
            cell.createdByLabel.textColor = .blackColor()
            cell.assignedToLabel.textColor = .blackColor()
            cell.timeFrameLabel.textColor = .blackColor()
            cell.assignToButton.hidden = false
        } else {
            cell.assignToButton.hidden = true
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            cell.titleLabel.textColor = UIColor.grayColor()
            cell.quantityLabel.textColor = UIColor.grayColor()
            cell.createdByLabel.textColor = .grayColor()
            cell.assignedToLabel.textColor = .grayColor()
            cell.timeFrameLabel.textColor = .grayColor()
            
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
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
            let nameField = alert.textFields![0].text!
            let detailField = alert.textFields![1].text!
            let timeFrame = alert.textFields![2].text!
            var newItem: ListItem
            if timeFrame == "" {
                newItem = ListItem(withName: nameField, andQuantity: detailField, createdBy: self.user!.displayName!, timeFrame: nil)
            } else {
                newItem = ListItem(withName: nameField, andQuantity: detailField, createdBy: self.user!.displayName!, timeFrame: timeFrame)
            }
            self.currGroup!.list.items.append(newItem)
            for item in self.currGroup!.list.items {
                self.myRef?.child("groups").child("\(self.currGroup!.createdBy)-\(self.currGroup!.name)-\(self.currGroup!.topic)").child("items").child(nameField).setValue(item.toAnyObject())
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default) { (action: UIAlertAction!) -> Void in
            self.view.endEditing(true)
        }
        
        alert.addTextFieldWithConfigurationHandler { (textGroup) -> Void in
            textGroup.placeholder = "Item Name"
        }
        alert.addTextFieldWithConfigurationHandler { (quantity) -> Void in
            quantity.placeholder = "How much?"
        }
        alert.addTextFieldWithConfigurationHandler { (timeFrame) -> Void in
            timeFrame.placeholder = "When does it need to get done?"
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
        self.myRef?.child("users").queryOrderedByChild(username).observeSingleEventOfType(.Value, withBlock: { snapshot in
            print(snapshot)
//            if let _ = snapshot.value as? NSNull {
//                print("no user")
//            } else {
//                let postDict = snapshot.value as! [String: AnyObject]
//                let baseUsername = postDict["username"]!["username"] as? String
//                if let baseUsername = baseUsername {
//                    self.currGroup?.groupUsers.append(baseUsername)
//                    self.myRef?.child("users").child(baseUsername).child("userGroups").child("\(self.currGroup!.name)-\(self.currGroup!.topic)").setValue(["name": "\(self.currGroup!.name)-\(self.currGroup!.topic)"])
//                    self.myRef?.child("groups").child("\(self.currGroup!.name)-\(self.currGroup!.topic)").child("users").setValue(self.currGroup!.groupUsers)
//                }
//            }
        })
    }
    
    // MARK: - Navigation
    
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //
    //    }
}
