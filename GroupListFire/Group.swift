//
//  Group.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/7/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import Foundation

class Group {
    
    var name: String
    var topic: String
    var list: List
    
    init(withName name: String, andTopic topic: String, andList list: List) {
        self.name = name
        self.topic = topic
        self.list = list
    }
    
    func toAnyObject() -> [String: [String]] {
        return ["\(name)-\(topic)": self.list.items]
    }
}