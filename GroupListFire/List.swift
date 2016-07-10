//
//  List.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/7/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import Foundation

class List {
    
    var items: [ListItem] = []
    
    init(list: [ListItem]) {
        self.items = list
    }
    
    convenience init () {
        self.init(list: [])
    }

}