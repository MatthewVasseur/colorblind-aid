//
//  ConfirmDialogue.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 11/28/17.
//  Copyright © 2017 Matthew Vasseur. All rights reserved.
//

import UIKit

extension UIView {
    
    /**
     Create a confirmation dialogue alert over the current view
     - parameters:
        - title: Title of the alert
        - message: Message of the alert
        - confirm: Function to run upon confirmation
     - returns: The created alert
     */
    func confirmDialogue(title: String?, message: String?, confirm: @escaping () -> Void) -> UIAlertController {
        let confirmation = UIAlertController(title: title, message: message, preferredStyle: .alert)
        confirmation.popoverPresentationController?.sourceView = self
        
        // Run the confirmation method
        let confirm = UIAlertAction(title: "Confirm", style: .default) {
            (alert: UIAlertAction) in
            confirm()
            
            return
        }
        // Cancel
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) {
            (alert: UIAlertAction) in
            return
        }
        confirmation.addAction(confirm)
        confirmation.addAction(cancel)
        
        return confirmation
    }
}
