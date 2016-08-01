//
//  SlideMenuTableViewController.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/20/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit
import Firebase

class SlideMenuTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 4 {
            try! FIRAuth.auth()!.signOut()
        }
    }
}
