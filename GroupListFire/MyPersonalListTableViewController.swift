//
//  MyPersonalListTableViewController.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/20/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit
import Firebase

class MyPersonalListTableViewController: UITableViewController, FirebaseDelegation {
    
    var myRef: FIRDatabaseReference? = nil
    let user = FIRAuth.auth()?.currentUser
    var items: [ListItem] = []
    var lastClick: NSTimeInterval?
    var lastIndexPath: NSIndexPath?
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Assigned To Me"
        self.clearsSelectionOnViewWillAppear = true
        tableView.rowHeight = CGFloat(75.0)
        myRef = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/")
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }

        myRef?.child("users").child("\(user!.displayName!)-\(user!.uid)").child("assignedTo").queryOrderedByChild("completed").observeEventType(.Value, withBlock: { snapshot in
            if let postDict = snapshot.value as? [String: AnyObject] {
                self.items = []
                for item in postDict.keys {
                    let infoDict = postDict[item] as! [String: AnyObject]
                    let name = infoDict["name"] as! String
                    let quantity = infoDict["quantity"] as! String
                    let createdBy = infoDict["createdBy"] as! String
                    let completed = infoDict["completed"] as! Bool
                    let group = infoDict["group"] as! String
                    let timeFrame: String?
                    let assignedTo: String?
                    if let timeframe = infoDict["timeFrame"] {
                        timeFrame = (timeframe as! String)
                    } else { timeFrame = nil }
                    if let assignedto = infoDict["assignedTo"] {
                        assignedTo = (assignedto as! String)
                    } else { assignedTo = nil }
                    let groupRef = self.myRef?.child("groups").child(group).child("items").child(name)
                    let newItem = ListItem(withName: name, andQuantity: quantity, completed: completed, groupRef: groupRef, createdBy: createdBy, assignedTo: assignedTo, timeFrame: timeFrame, group: group)
                    self.items.append(newItem)
                }
            }
            self.tableView.reloadData()
        })
        
        self.myRef?.child("users").child("\(user!.displayName!)-\(user!.uid)").child("userGroups").observeEventType(.Value, withBlock: { snapshot in
            var newNames: [String] = []
            for item in snapshot.children {
                if let item = item as? FIRDataSnapshot {
                    let postDict = item.value as! [String: String]
                    newNames.append(postDict["name"]!)
                }
            }
            self.didFetchData(newNames, toMatch: nil)
        })
        
    }
    
    func didFetchData<T : SequenceType>(data: T, toMatch: String?) {
        print(data)
        if let data = data as? [String] {
            var i = 0
            for item in self.items {
                if !data.contains(item.group) {
                    self.myRef?.child("users").child("\(user!.displayName!)-\(user!.uid)").child("assignedTo").child("\(item.name)-\(item.quantity)").removeValue()
                }
                i += 1
            }
        }
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
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
        toggleCellCheckbox(cell, isCompleted: item.completed)
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
                toggleCellCheckbox(cell, isCompleted: toggledCompletion)
                item.updateCompletedRef(toggledCompletion)
                return
            }
        }
        lastClick = now
        lastIndexPath = indexPath
    }
    
    func toggleCellCheckbox(cell: PersonalItemTableViewCell, isCompleted: Bool) {
        cell.accessoryType = UITableViewCellAccessoryType.None
        if !isCompleted {
            cell.checkMarkImage.hidden = true
            cell.titleLabel.textColor = UIColor.blackColor()
            cell.quantityLabel.textColor = UIColor.blackColor()
            cell.createdByLabel.textColor = UIColor.blackColor()
            cell.assignedToLabel.textColor = UIColor.blackColor()
            cell.timeFrameLabel.textColor = UIColor.blackColor()
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
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    
    
}
