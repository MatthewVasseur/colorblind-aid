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
        
        self.backgroundColor = UIColor.clear.withAlphaComponent(0.5)
        self.layer.borderColor = UIColor.black.cgColor
        
        // Initialize the edit tap gesture
        editGesture = UITapGestureRecognizer()
        self.addGestureRecognizer(editGesture)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
