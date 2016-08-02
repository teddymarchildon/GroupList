//
//  MessagingTableViewCell.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/29/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit

class MessagingTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageTextLabel: UILabel!
    
    @IBOutlet weak var messageImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
