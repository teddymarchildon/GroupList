//
//  Group.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/7/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import Foundation
import Firebase

class Group {
    
    var name: String
    var topic: String
    var list: List
    var ref: FIRDatabaseReference?
    var groupUsers: [String]
    
    init(withName name: String, andTopic topic: String, andList list: List, andUser user: FIRUser) {
        self.name = name
        self.topic = topic
        self.list = list
        self.ref = nil
        self.groupUsers = [user.displayName!]
    }
    
    init(snapshot: FIRDataSnapshot) {
        let fullName = snapshot.key.componentsSeparatedByString("-")
        let groupName = fullName[0]
        let topicName = fullName[1]
        self.name = groupName
        self.topic = topicName
        self.ref = snapshot.ref
        var groupList: [ListItem] = []
        let postDict = snapshot.value! as? [String: AnyObject]
        if let items = postDict!["items"] as? [String: AnyObject] {
            for elem in items.keys {
                let dict = items[elem] as! [String: AnyObject]
                let completed = dict["completed"] as! Bool
                let name = dict["name"] as! String
                let quantity = dict["quantity"] as! String
                let newListItem = ListItem(withName: name, andQuantity: quantity, completed: completed, groupRef: snapshot.ref)
                groupList.append(newListItem)
            }
            self.list = List(list: groupList)
        } else {
            self.list = List()
        }
        if let users = postDict!["users"] as? [String] {
            self.groupUsers = users
        } else {
            self.groupUsers = []
        }
    }
    
    func toAnyObject(user: FIRUser) -> [String: AnyObject] {
        return ["name": name,
                "topic": topic,
                "list": list.items,
                "users": groupUsers,
                "createdByUser": user.displayName!]
    }
}