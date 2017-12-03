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
    
    var isFiltered: Bool = false
    var filterType: Constants.ColorblindType = .normal
    
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
