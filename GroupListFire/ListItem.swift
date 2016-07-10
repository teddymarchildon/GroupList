//
//  ListItem.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/9/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import Foundation
import Firebase

class ListItem {
    
    let name: String
    let quantity: String
    var completed: Bool = false
    var ref: FIRDatabaseReference?
    var user = FIRAuth.auth()?.currentUser
    var createdBy: String {
        return (user?.uid)!
    }
    
    convenience init(withName name: String, andQuantity quantity: String) {
        self.init(withName: name, andQuantity: quantity, completed: false, ref: nil)
    }
    
    init(withName name: String, andQuantity quantity: String, completed: Bool, ref: FIRDatabaseReference?) {
        self.name = name
        self.quantity = quantity
        self.completed = completed
        self.ref = ref
    }
    
    func toAnyObject() -> [String: AnyObject]{
        return ["name": name,
                "quantity": quantity,
                "completed": "\(completed)"
                ]
    }
    
}