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
    
    init(withName name: String, andTopic topic: String, andList list: List) {
        self.name = name
        self.topic = topic
        self.list = list
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        let fullName = snapshot.key.componentsSeparatedByString("-")
        let groupName = fullName[0]
        let topicName = fullName[1]
        self.name = groupName
        self.topic = topicName
        self.list = List()
        self.ref = snapshot.ref
    }
    
    func toAnyObject(user: FIRUser) -> [String: AnyObject] {
        return ["name": name,
                "topic": topic,
                "createdByUser": user.uid]
    }
}