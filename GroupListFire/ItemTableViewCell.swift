//
//  ItemTableViewCell.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/17/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit
import Firebase

protocol ChangeFromCellDelegate: NSObjectProtocol {
    func loadNewScreen(controller: UIViewController)
}

class ItemTableViewCell: UITableViewCell {
    
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
            }
            alert.addAction(userAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alert.addAction(cancelAction)
        if (delegate?.respondsToSelector(Selector("loadNewScreen"))) != nil {
            delegate?.loadNewScreen(alert)
        }
    }
    
    @IBAction func setNewProperties(sender: AnyObject) {
        let alert = UIAlertController(title: "Edit Item", message: nil, preferredStyle: .Alert)
        let saveAction = UIAlertAction(title: "Save", style: .Default) { (action: UIAlertAction!) -> Void in
            let nameField = alert.textFields![0].text!
            let detailField = alert.textFields![1].text!
            let timeFrame = alert.textFields![2].text!
            self.item!.setNewProperties(newName: nameField, newQuantity: detailField, newTimeFrame: timeFrame)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: nil)
        
        alert.addTextFieldWithConfigurationHandler { (textGroup) -> Void in
            textGroup.placeholder = "New Name"
        }
        alert.addTextFieldWithConfigurationHandler { (quantity) -> Void in
            quantity.placeholder = "How much?"
        }
        alert.addTextFieldWithConfigurationHandler { (timeFrame) -> Void in
            timeFrame.placeholder = "When does it need to get done?"
        }
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        if (delegate?.respondsToSelector(Selector("loadNewScreen"))) != nil {
            delegate?.loadNewScreen(alert)
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
