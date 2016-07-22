//
//  ListTableViewController.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/7/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit
import Firebase

class ListTableViewController: UITableViewController, ChangeFromCellDelegate, FirebaseDelegation {
    
    var myRef: FIRDatabaseReference? = nil
    let user = FIRAuth.auth()?.currentUser
    var currGroup: Group?
    var currGroupObject: AnyObject?
    var lastClick: NSTimeInterval?
    var lastIndexPath: NSIndexPath?
    var registeredUsers: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button: UIButton = UIButton()
        button.setImage(UIImage(named: "Add User Male-100"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(self.addUserButtonPressed), forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 32, 32)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItems![1] = barButton
        self.currGroup!.groupUsers = []
        tableView.delegate = self
        tableView.rowHeight = CGFloat(75.0)
        myRef = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/")
        self.clearsSelectionOnViewWillAppear = true
        myRef?.child("groups").child("\(currGroup!.createdBy)-\(currGroup!.name)-\(currGroup!.topic)").child("users").observeSingleEventOfType(.Value, withBlock: { snapshot in
            if let users = snapshot.value as? [String] {
                for user in users {
                    self.currGroup!.groupUsers.append(user)
                }
            }
            self.tableView.reloadData()
        })
    }
    
    func addUserButtonPressed() {
        self.performSegueWithIdentifier("userSearchSegue", sender: nil)
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
        cell.currGroup = currGroup
        cell.delegate = self
        cell.titleLabel.text = item.name
        cell.quantityLabel.text = item.quantity
        cell.createdByLabel.text = item.createdBy
        cell.assignedToLabel.text = item.assignedTo?.componentsSeparatedByString("-")[0]
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
        self.presentViewController(controller, animated: true, completion: nil)
        self.tableView.reloadData()
    }
    
    func toggleCellCheckbox(cell: ItemTableViewCell, isCompleted: Bool) {
        cell.accessoryType = UITableViewCellAccessoryType.None
        if !isCompleted {
            cell.assignToButton.hidden = false
            cell.editItemButton.hidden = false
            cell.titleLabel.textColor = UIColor.blackColor()
            cell.quantityLabel.textColor = UIColor.blackColor()
            cell.createdByLabel.textColor = .blackColor()
            cell.assignedToLabel.textColor = .blackColor()
            cell.timeFrameLabel.textColor = .blackColor()
        } else {
            cell.assignToButton.hidden = true
            cell.editItemButton.adjustsImageWhenDisabled = true
            cell.editItemButton.enabled = false
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
            if !nameField.isEmpty {
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
    
    func findUserInDatabase(username: String) {
        self.myRef?.child("users").queryOrderedByChild("username").queryEqualToValue(username).observeEventType(.Value, withBlock: { snapshot in
            print(snapshot)
        })
    }
    
    func didFetchData<T : SequenceType>(data: T, toMatch: String?) {
        if let data = data as? [String: String], searchedUser = toMatch {
            var registeredNameArray: [String] = []
            let registeredNames = data.keys
            for name in registeredNames {
                registeredNameArray.append(name)
            }
            self.registeredUsers = registeredNameArray
            if registeredNames.contains(searchedUser) {
                self.myRef?.child("users").child("\(searchedUser)-\(data[searchedUser]!)").child("userGroups").child("\(self.currGroup!.createdBy)-\(self.currGroup!.name)-\(self.currGroup!.topic)").setValue(["name": "\(self.currGroup!.createdBy)-\(self.currGroup!.name)-\(self.currGroup!.topic)"])
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "userSearchSegue" {
            let listController = segue.destinationViewController as! UserSearchTableViewController
            listController.title = "Add User to \(currGroup!.name) group"
            listController.currGroup = self.currGroup
        }
    }
}
