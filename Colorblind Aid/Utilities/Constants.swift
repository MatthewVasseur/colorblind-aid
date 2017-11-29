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
    
    // MARK: - Colors
    struct colors {
        // Colors for the error label text upon error or success (red or green)
        static let error = UIColor(red: 0xFF, green: 0x00, blue: 0x00)
        
        // Color names data
        static let names = ColorNamesData().data
    }
    
    // MARK: - Storyboard ID Constants
    struct storyboardIDs {
        static let main = "Main"
        
        static let left = "Settings"
        static let middle = "AR"
        static let right = "Filter"
    }
    
    // MARK: - Segue ID Constants
    struct segues {
        // SignInViewController Segue to Sign In
        static let signIn = "SignIn"
    }
    
    // achromatopsia = Monochromacy; Achromatomaly = Partial Monochromacy
    /// Supported types of colorblindness
    enum ColorblindType {
        case normal, protanopia, protanomaly, deuteranopia, deuteranomaly, tritanopia, tritanomaly
        /// Monochromacy
        case achromatopsia, achromatomaly
    }
}