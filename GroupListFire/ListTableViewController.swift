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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.rowHeight = CGFloat(75.0)
        myRef = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/")
        self.clearsSelectionOnViewWillAppear = false
        
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
                    let newListItem = ListItem(withName: postDict["name"] as! String, andQuantity: postDict["quantity"] as! String, completed: postDict["completed"] as! Bool, ref: item.ref)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("listCell", forIndexPath: indexPath)
        cell.selectionStyle = .None
        let item = currGroup!.list.items[indexPath.row]
        let toggledCompletion = !item.completed
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        item.ref?.updateChildValues([
            "completed": toggledCompletion
        ])
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
    
//    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        
//    }
    
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let item = currGroup!.list.items[indexPath.row]
            item.ref!.removeValue()
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
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    @IBAction func addItemToList(sender: AnyObject) {
        let alert = UIAlertController(title: "New Item", message: nil, preferredStyle: .Alert)
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
            let nameField = alert.textFields![0]
            let detailField = alert.textFields![1]
            let newItem = ListItem(withName: nameField.text!, andQuantity: detailField.text!)
            self.currGroup!.list.items.append(newItem)
            var refDict = [[String: AnyObject]]()
            for item in self.currGroup!.list.items {
                let newItemDict = ["name": item.name,
                                   "quantity": item.quantity,
                                   "completed": item.completed,
                                   "createdBy": self.user!.uid]
                refDict.append(newItemDict as! [String : AnyObject])
            }
            let ref = self.myRef?.child("groups").child("\(self.currGroup!.name)-\(self.currGroup!.topic)").child("items")
            if let ref = ref {
                ref.setValue(refDict)
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
    
    
    /*
     
     
     
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
