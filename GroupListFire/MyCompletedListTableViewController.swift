//
//  MyCompletedListTableViewController.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/24/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit
import Firebase

class MyCompletedListTableViewController: UITableViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var myRef: FIRDatabaseReference? = nil
    let user = FIRAuth.auth()?.currentUser
    var userReference: String!
    var items: [ListItem] = []
    var lastClick: NSTimeInterval?
    var lastIndexPath: NSIndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userReference = ErrorAlerts.getUserReferenceType(self.user!)
        self.clearsSelectionOnViewWillAppear = true
        tableView.rowHeight = CGFloat(75.0)
        myRef = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/")
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        myRef?.child("users").child("\(userReference)-\(user!.uid)").child("assignedTo").queryOrderedByChild("completed").queryEqualToValue(true).observeEventType(.Value, withBlock: { snapshot in
            for item in snapshot.children {
                if let item = item as? FIRDataSnapshot {
                    let newItem = ListItem(snapshot: item)
                    let groupRef = self.myRef?.child("groups").child(newItem.group).child("items").child(newItem.name)
                    newItem.groupRef = groupRef
                    self.items.append(newItem)
                }
            }
            self.tableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PersonalItemTableViewCell", forIndexPath: indexPath) as! PersonalItemTableViewCell
        let item = self.items[indexPath.row]
        cell.titleLabel.text = item.name
        cell.quantityLabel.text = item.quantity
        cell.groupLabel.text = item.group.componentsSeparatedByString("-")[1]
        cell.createdByLabel.text = item.createdBy
        cell.assignedToLabel.text = item.assignedTo?.componentsSeparatedByString("-")[0]
        cell.timeFrameLabel.text = item.timeFrame
        toggleCellCheckbox(cell, isCompleted: item.completed, index: indexPath)
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let now: NSTimeInterval = NSDate().timeIntervalSince1970
        if let lastClick = lastClick, lastIndexPath = lastIndexPath {
            if (now - lastClick < 0.3) && indexPath.isEqual(lastIndexPath) {
                let cell = tableView.dequeueReusableCellWithIdentifier("PersonalItemTableViewCell", forIndexPath: indexPath) as! PersonalItemTableViewCell
                cell.selectionStyle = .None
                let item = self.items[indexPath.row]
                let toggledCompletion = !item.completed
                toggleCellCheckbox(cell, isCompleted: toggledCompletion, index: indexPath)
                item.updateCompletedRef(toggledCompletion)
                self.tableView.reloadData()
                return
            }
        }
        lastClick = now
        lastIndexPath = indexPath
    }
    
    func toggleCellCheckbox(cell: PersonalItemTableViewCell, isCompleted: Bool, index: NSIndexPath) {
        cell.accessoryType = UITableViewCellAccessoryType.None
        if !isCompleted {
            self.items.removeAtIndex(index.row)
            self.tableView.deleteRowsAtIndexPaths([index], withRowAnimation: .Fade)
            cell.checkMarkImage.hidden = true
            cell.titleLabel.textColor = UIColor.blackColor()
            cell.quantityLabel.textColor = UIColor.blackColor()
            cell.createdByLabel.textColor = UIColor.blackColor()
            cell.assignedToLabel.textColor = UIColor.blackColor()
            cell.timeFrameLabel.textColor = UIColor.blackColor()
            cell.groupLabel.textColor = UIColor.blackColor()
        } else {
            cell.checkMarkImage.hidden = false
            cell.titleLabel.textColor = UIColor.grayColor()
            cell.quantityLabel.textColor = UIColor.grayColor()
            cell.groupLabel.textColor = UIColor.grayColor()
            cell.createdByLabel.textColor = UIColor.grayColor()
            cell.assignedToLabel.textColor = UIColor.grayColor()
            cell.timeFrameLabel.textColor = UIColor.grayColor()
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let item = self.items[indexPath.row]
            item.updateAssignedUserRefForDeletion()
            self.items.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
}

