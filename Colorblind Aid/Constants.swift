//
//  Constants.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 10/24/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import Foundation
import UIKit

class Constants: NSObject {
    
    // MARK: -
    static let mainStoryboard = "Main"
    
    // MARK: - Miscellaneous
    // Amount of time app is in background before reloading data (in seconds)
    static let reloadAfterElapsedTime = 60 * 10.0
    
    // MARK: - Colors
    struct colors {
        // Colors for the error label text upon error or success (red or green)
        static let error = UIColor(red: 0xFF, green: 0x00, blue: 0x00)
        static let success = UIColor(red: 0x00, green: 0x80, blue: 0x00)
        
        // Blue text color
        static let textBlue = UIColor(red: 0x15, green: 0x7E, blue: 0xFB)
    }
    
    // MARK: - Constraints
    struct constraints {
        // Default value for password text field's bottom constraint in SignInView
        static let defaultKeyboard = CGFloat(-195.0)
    }
    
    // MARK: - Text
    struct texts {
        // Replacement text for note on page 0
        static let pageZero = "Book"
        
        // Error text when unable to connect
        static let networkConnectionError = "Network Connection Interupted!"
    }
    
    // MARK: - Enumerations
    struct enums {
        // which function to run upon retry (e.g. unable to upload photo)
        enum retryCode {
            case savePhoto
            case deletePhoto
        }
    }
    
    // MARK: - Segue ID Constants
    struct segues {
        // BookTableViewController Segue to Add new book
        static let addBook = "AddBook"
        
        // BookTableViewController Segue to Show existing book
        static let showBook = "ShowBook"
        
        // BookViewController Segue to Edit note
        static let editNote = "EditNote"
        
        // BookViewController Segue to Save book
        static let saveBook = "SaveBook"
        
        // SignInViewController Segue to Sign In
        static let signIn = "SignIn"
    }
}
