//
//  FilterRectView.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 11/15/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import UIKit

class FilterRectView: UIView {

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
        
        self.backgroundColor = UIColor.clear
        self.layer.borderColor = UIColor.black.withAlphaComponent(0.75).cgColor
        self.layer.borderWidth = 3.0
        
        // Initialize the edit tap gesture
        editGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(editGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
