//
//  User.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/18/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import Foundation

class User {
    
    var displayName: String
    var ID: String
    var photoURL: NSURL
    
    init(withDisplayName displayName: String, andID ID: String, andPhotoURL photoURL: NSURL) {
        self.displayName = displayName
        self.ID = ID
        self.photoURL = photoURL
    }
    
    func toAnyObject() -> [String: AnyObject]{
        var retDict: [String: AnyObject] = [:]
        retDict["displayName"] = displayName
        retDict["ID"] = ID
        retDict["photoURL"] = String(photoURL)
        return retDict
    }
}
