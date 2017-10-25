//
//  Utilities.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 10/10/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import UIKit

extension UIFont {
    
    /**
     Convenience initializer to create a UIFont with the specified traits
     
     - parameters:
        - traits: list of UIFontDescriptorSymbolicTraits for the font
    
     Referenced from [Stack Overflow](https://stackoverflow.com/questions/4713236/how-do-i-set-bold-and-italic-on-uilabel-of-iphone-ipad)
     */
    func withTraits(traits: UIFontDescriptorSymbolicTraits...) -> UIFont {
        let descriptor = self.fontDescriptor.withSymbolicTraits(UIFontDescriptorSymbolicTraits(traits))
        return UIFont(descriptor: descriptor!, size: 0)
    }
}

extension UIColor {
    
    /// Extend UIColor initializer to take RGB integers
    convenience init(red: Int, green: Int, blue: Int) {
        let newRed = CGFloat(red) / 255
        let newGreen = CGFloat(green) / 255
        let newBlue = CGFloat(blue) / 255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
    
    /// Overload the above to take an alpha
    convenience init(red: Int, green: Int, blue: Int, withAlpha alpha: CGFloat) {
        let newRed = CGFloat(red) / 255
        let newGreen = CGFloat(green) / 255
        let newBlue = CGFloat(blue) / 255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: alpha)
    }
}

