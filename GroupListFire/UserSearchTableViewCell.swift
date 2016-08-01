//
//  UserSearchTableViewCell.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/19/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit

class UserSearchTableViewCell: UITableViewCell {

    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
