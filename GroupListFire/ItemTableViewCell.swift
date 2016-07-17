//
//  ItemTableViewCell.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/17/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit

protocol ChangeFromCellDelegate: NSObjectProtocol {
    func loadNewScreen(controller: UIViewController, item: ListItem)
}

class ItemTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var assignedToLabel: UILabel!
    @IBOutlet weak var timeFrameLabel: UILabel!
    @IBOutlet weak var assignToButton: UIButton!
    var item: ListItem?
    var group: Group?
    weak var delegate: ChangeFromCellDelegate?
    
    @IBAction func assignItemToUser(sender: AnyObject) {
        let pickerVC = UIImagePickerController()
        if (delegate?.respondsToSelector(Selector("loadNewScreen"))) != nil
        {
            delegate?.loadNewScreen(pickerVC, item: self.item!)
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
