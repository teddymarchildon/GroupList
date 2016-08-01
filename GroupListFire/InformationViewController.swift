//
//  InformationViewController.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/22/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit

class InformationViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle)
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
