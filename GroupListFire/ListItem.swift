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
    var groupRef: FIRDatabaseReference?
    var createdBy: String?
    
    convenience init(withName name: String, andQuantity quantity: String) {
        self.init(withName: name, andQuantity: quantity, completed: false, groupRef: nil, createdBy: nil)
    }
    
    init(withName name: String, andQuantity quantity: String, completed: Bool, groupRef: FIRDatabaseReference?, createdBy: String?) {
        self.name = name
        self.quantity = quantity
        self.completed = completed
        self.groupRef = groupRef
        self.createdBy = createdBy
    }
    
    func toAnyObject() -> [String: AnyObject]{
        return ["name": name,
                "quantity": quantity,
                "completed": "\(completed)"
                ]
    }
}