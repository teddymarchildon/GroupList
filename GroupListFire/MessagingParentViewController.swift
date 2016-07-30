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
            self.tableViewController = tableViewController
        }
        else if let buttonPanelViewController = segue.destinationViewController as? MessagingTextFieldViewController {
            buttonPanelViewController.group = self.group
            self.buttonPanelViewController = buttonPanelViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view.
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
