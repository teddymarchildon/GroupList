//
//  ImageViewController.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 8/2/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let left = NSLayoutConstraint(item: self.image, attribute: .Leading, relatedBy: .Equal, toItem: self.view, attribute: .Leading, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: self.image, attribute: .Trailing, relatedBy: .Equal, toItem: self.view, attribute: .Trailing, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint(item: self.image, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: self.image, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1.0, constant: 0)
        self.image.addConstraints([
            left,
            right,
            top,
            bottom])
        self.view.addSubview(self.image)
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
