//
//  FirebaseUserData.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/30/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import Foundation
import Firebase

class FirebaseUserData {
    
    static var registeredUsers: [String] = []
    static var userToImage: [String: NSData?] = [:]
    static var userToID: [String: String] = [:]
    static var IDtoUser: [String: String] = [:]
    
    static func getAllInfo(completion: ([String], [String: NSData?], [String: String]) -> Void) {
        let ref = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/")
        ref.child("users").observeSingleEventOfType(.Value, withBlock: { snapshot in
            var registeredUsers: [String] = []
            var usernameToId: [String: String] = [:]
            var usernameToPhoto: [String: NSData?] = [:]
            for item in snapshot.children {
                if let item = item as? FIRDataSnapshot {
                    let key = item.key
                    if let postDict = item.value as? [String: AnyObject] {
                        let name = postDict["username"] as! String
                        registeredUsers.append(name)
                        usernameToId[name] = key
                        if let photoUrl = postDict["photoURL"] as? String {
                            let photoURL = NSURL(string: photoUrl)
                            let data = NSData(contentsOfURL: photoURL!)
                            usernameToPhoto[name] = data
                        } else {
                            usernameToPhoto[name] = nil
                        }
                    }
                }
            }
            self.registeredUsers = registeredUsers
            self.userToID = usernameToId
            self.userToImage = usernameToPhoto
            completion(registeredUsers, usernameToPhoto, usernameToId)
        })
    }
    
    static func getUsernameToId(completion: [String: String] -> Void) {
        let ref = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/")
        ref.child("users").observeSingleEventOfType(.Value, withBlock: { snapshot in
            var usernameToId: [String: String] = [:]
            for item in snapshot.children {
                if let item = item as? FIRDataSnapshot {
                    let key = item.key
                    if let postDict = item.value as? [String: AnyObject] {
                        let name = postDict["username"] as! String
                        usernameToId[name] = key
                    }
                }
            }
            self.userToID = usernameToId
            completion(usernameToId)
        })
    }
    static func getIdtoUsername(completion: [String: String] -> Void) {
        let ref = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/")
        ref.child("users").observeSingleEventOfType(.Value, withBlock: { snapshot in
            var IDToUsername: [String: String] = [:]
            for item in snapshot.children {
                if let item = item as? FIRDataSnapshot {
                    let key = item.key
                    if let postDict = item.value as? [String: AnyObject] {
                        let name = postDict["username"] as! String
                        IDToUsername[key] = name
                    }
                }
            }
            self.IDtoUser = IDToUsername
            completion(IDToUsername)
        })
    }
}