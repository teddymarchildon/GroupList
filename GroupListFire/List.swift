//
//  List.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/7/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import Foundation

class List {
    
    var items: [String] = []
    
    init(list: [String]) {
        self.items = list
    }
    
    convenience init () {
        self.init(list: [])
    }
    
    func addItem(item: String) {
        items.append(item)
    }
    
    func addAllItems(items: [String]) {
        self.items.appendContentsOf(items)
    }
    
    func removeItem(item: String) {
        var dex = 0
        for elem in items {
            if elem == item {
                items.removeAtIndex(dex)
                return
            } else {
                dex += 1
            }
        }
    }
}