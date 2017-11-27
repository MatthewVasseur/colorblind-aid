//
//  FilterRectView.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 11/15/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import UIKit

class FilterRectView: UIImageView {

    // MARK: - Properties
    var editGesture: UITapGestureRecognizer!
    
    var i: Int = 0
    var colors = [UIColor.clear.withAlphaComponent(0.5), UIColor.blue.withAlphaComponent(0.5),
                  UIColor.red.withAlphaComponent(0.5), UIColor.brown.withAlphaComponent(0.5),
                  UIColor.green.withAlphaComponent(0.5), UIColor.yellow.withAlphaComponent(0.5),
                  UIColor.purple.withAlphaComponent(0.5)]
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Set style and properties
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = UIColor.black.withAlphaComponent(0.6).cgColor
        self.layer.borderWidth = 4.0
        
        self.isUserInteractionEnabled = true
        self.contentMode = .scaleAspectFit
        
        // Initialize the edit tap gesture
        editGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(editGesture)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
