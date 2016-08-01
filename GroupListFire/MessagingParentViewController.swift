//
//  MessagingParentViewController.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/29/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit

class MessagingParentViewController: UIViewController {

    var buttonPanelViewController: MessagingTextFieldViewController!
    var tableViewController: MessagingTableViewController!
    var group: Group!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tableViewController = segue.destinationViewController as? MessagingTableViewController {
            tableViewController.group = self.group
            tableViewController.title = self.group.name
            tableViewController.parentController = self
            self.tableViewController = tableViewController
        }
        else if let buttonPanelViewController = segue.destinationViewController as? MessagingTextFieldViewController {
            buttonPanelViewController.group = self.group
            buttonPanelViewController.parentController = self
            self.buttonPanelViewController = buttonPanelViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        buttonPanelViewController.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
