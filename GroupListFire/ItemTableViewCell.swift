//
//  ItemTableViewCell.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/17/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var assignedToLabel: UILabel!
    @IBOutlet weak var timeFrameLabel: UILabel!
    @IBOutlet weak var assignToButton: UIButton!
    var item: ListItem?
    var group: Group?
    
    @IBAction func assignItemToUser(sender: AnyObject) {
        
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
