//
//  PersonalItemTableViewCell.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/22/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit

class PersonalItemTableViewCell: UITableViewCell {

    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var timeFrameLabel: UILabel!
    @IBOutlet weak var assignedToLabel: UILabel!
    @IBOutlet weak var checkMarkImage: UIImageView!
    @IBOutlet weak var groupLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
