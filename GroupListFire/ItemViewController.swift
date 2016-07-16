//
//  ItemViewController.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/15/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit

class ItemViewController: UIViewController {

    @IBOutlet weak var createdByLabel: UILabel!
    
    @IBOutlet weak var timeFrameLabel: UILabel!
    
    @IBOutlet weak var assignedToLabel: UILabel!
    
    var item: ListItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let createdBy = item!.createdBy {
            createdByLabel.text = "Created by: \(createdBy)"
        }
        timeFrameLabel.text = "Needs to be done by: time"
        assignedToLabel.text = "Assigned to: user"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    


}
