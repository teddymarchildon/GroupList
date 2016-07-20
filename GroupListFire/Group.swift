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
    var createdBy: String
    
    init(withName name: String, andTopic topic: String, andList list: List, createdBy: String, andUser user: FIRUser) {
        self.name = name
        self.topic = topic
        self.list = list
        self.ref = nil
        self.createdBy = createdBy
        self.groupUsers = ["\(user.displayName!)-\(user.uid)"]
    }
    
    init(snapshot: FIRDataSnapshot) {
        let fullName = snapshot.key.componentsSeparatedByString("-")
        let createdBy = fullName[0]
        let groupName = fullName[1]
        let topicName = fullName[2]
        self.createdBy = createdBy
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
                let createdBy = dict["createdBy"] as! String
                let timeFrame = dict["timeFrame"] as? String
                let assignedTo = dict["assignedTo"] as? String
                let newListItem = ListItem(withName: name, andQuantity: quantity, completed: completed, groupRef: snapshot.ref, createdBy: createdBy, assignedTo: assignedTo, timeFrame: timeFrame)
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
    
    func toAnyObject() -> [String: AnyObject] {
        return ["name": name,
                "topic": topic,
                "list": list.items,
                "users": groupUsers,
                "createdByUser": createdBy]
    }
}