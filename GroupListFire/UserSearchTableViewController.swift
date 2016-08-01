//
//  UserSearchTableViewController.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 7/19/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import UIKit
import Firebase

class UserSearchTableViewController: UITableViewController, UISearchResultsUpdating {
    
    var registeredUsers: [String] = []
    var userToImage: [String: NSData?] = [:]
    var userToID: [String: String] = [:]
    var myRef: FIRDatabaseReference? = nil
    var currGroup: Group?
    let searchController = UISearchController(searchResultsController: nil)
    var filteredUsers: [String] = []
    
    override func viewDidLoad() {
        self.tableView.rowHeight = 75.0
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        super.viewDidLoad()
        myRef = FIRDatabase.database().referenceFromURL("https://grouplistfire-39d22.firebaseio.com/")
        self.myRef?.child("users").observeSingleEventOfType(.Value, withBlock: { snapshot in
            self.registeredUsers = []
            var usernameToId: [String: String] = [:]
            var usernameToPhoto: [String: NSData?] = [:]
            for item in snapshot.children {
                if let item = item as? FIRDataSnapshot {
                    let name = item.key.componentsSeparatedByString("-")[0]
                    let id = item.key.componentsSeparatedByString("-")[1]
                    if let postDict = item.value as? [String: AnyObject] {
                        self.registeredUsers.append(name)
                        usernameToId[name] = id
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
            self.userToID = usernameToId
            self.userToImage = usernameToPhoto
            self.tableView.reloadData()
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredUsers.count
        } else {
            return self.registeredUsers.count
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as! UserSearchTableViewCell
        let user: String
        if searchController.active && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            user = registeredUsers[indexPath.row]
        }
        cell.userName.text = user
        let image = self.userToImage[user]
        if let image = image {
            cell.userImage.image = UIImage(data: image!)
        } else {
            cell.userImage.image = nil
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let userName: String
        if searchController.active && searchController.searchBar.text != "" {
            userName = filteredUsers[indexPath.row]
        } else {
            userName = registeredUsers[indexPath.row]
        }
        let userID = self.userToID[userName]
        if !self.currGroup!.groupUsers.contains("\(userName)-\(userID!)") {
            self.currGroup!.groupUsers.append("\(userName)-\(userID!)")
        }
        self.currGroup!.addUser(userName, userID: userID!)
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredUsers = registeredUsers.filter { user in
            return user.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
