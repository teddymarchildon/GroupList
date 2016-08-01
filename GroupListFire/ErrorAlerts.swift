//
//  ErrorAlerts.swift
//  GroupListFire
//
//  Created by Teddy Marchildon on 8/1/16.
//  Copyright © 2016 Teddy Marchildon. All rights reserved.
//

import Foundation

class ErrorAlerts {
    
    static func invalidTextEntered(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Invalid Entry", message: message, preferredStyle: .Alert)
        let ok = UIAlertAction(title: "Ok", style: .Cancel, handler: nil)
        alert.addAction(ok)
        return alert
    }
    
    static func containsInvalidCharacters(message: String) -> Bool {
        if message.containsString("/") || message.containsString("$") || message.containsString("#") || message.containsString(".") || message.containsString("[") || message.containsString("]") {
            return true
        } else {
            return false
        }
    }
}
