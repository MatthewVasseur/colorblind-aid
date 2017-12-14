//
//  AppState.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 11/29/17.
//  Copyright © 2017 Matthew Vasseur. All rights reserved.
//

import Foundation

class AppState: NSObject {
    
    static let sharedInstance = AppState()
    
    /// Collection of rooms
    var rooms: [Room] = []
}
