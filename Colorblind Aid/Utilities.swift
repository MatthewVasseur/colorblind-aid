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
    
    /// Return a tuple of RBGa cgfloats (Red, Green, Blue, Alpha)
    func getRGBa() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var red:   CGFloat = 0
        var green: CGFloat = 0
        var blue:  CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red*255, green*255, blue*255, alpha)
    }
    
    /** Return a tuple of HSL cgfloats (Hue, Saturation, Luminosity)
     * Adopted from from: Farbtastic 1.2 (http://acko.net/dev/farbtastic)
     */
    func getHSL() -> (CGFloat, CGFloat, CGFloat) {
        var (red, green, blue, _) = self.getRGBa()
        red /= 255
        green /= 255
        blue /= 255
        
        let minimum = min(red, min(green, blue))
        let maximum = max(red, max(green, blue))
        let delta = maximum - minimum
        let lum = (minimum + maximum) / 2
        
        var sat = CGFloat(0)
        if (lum > 0 && lum < 1) {
            sat = delta / (lum < 0.5 ? (2.0 * lum) : (2.0 - 2.0 * lum))
        }
        
        var hue = CGFloat(0)
        if (delta > 0) {
            if (maximum == red && maximum != green) {
                hue += (green - blue) / delta
            }
            if (maximum == green && maximum != blue) {
                hue += (2 + (blue - red) / delta)
            }
            if (maximum == blue && maximum != red) {
                hue += (4 + (red - green) / delta)
            }
            hue /= 6
        }
        print ((hue * 255, sat * 255, lum * 255))
        return (hue * 255, sat * 255, lum * 255)
    }
    
    /// Get the name of the hue corresponding to the color
    func toHueName() -> String {
        let (red, green, blue, _) = self.getRGBa()
        let (hue, sat, lum) = self.getHSL()
        
        print (self.getRGBa())
        print (self.getHSL())
        
        var ndf1: CGFloat = 0
        var ndf2: CGFloat = 0
        var ndf: CGFloat = 0
        var df: CGFloat = -1
        var cl: Int = -1
        
        
        for (i, color) in Constants.colorNames.enumerated() {
            
            if (red, green, blue) == (color.red, color.green, color.blue) {
                return color.hueName
            }
            
            ndf1 = pow(red - color.red, 2) + pow(green - color.green, 2) + pow(blue - color.blue, 2)
            ndf2 = abs(pow(hue - color.hue, 2)) + pow(sat - color.sat, 2) + abs(pow(lum - color.lum, 2))
            ndf = ndf1 + ndf2 * 2
            if (df < 0 || df > ndf) {
                df = ndf
                cl = i
            }
        }
        
        return cl < 0 ? "N/A" : Constants.colorNames[cl].hueName
    }
}

//
//+-----------------------------------------------------------------+
//|   Created by Chirag Mehta - http://chir.ag/tech/download/ntc    |
//|-----------------------------------------------------------------|
//|               ntc js (Name that Color JavaScript)               |
//+-----------------------------------------------------------------+
//
//All the functions, code, lists etc. have been written specifically
//for the Name that Color JavaScript by Chirag Mehta unless otherwise
//specified.

//
//    shades: [
//    ["FF0000", "Red"],
//    ["FFA500", "Orange"],
//    ["FFFF00", "Yellow"],
//    ["008000", "Green"],
//    ["0000FF", "Blue"],
//    ["EE82EE", "Violet"],
//    ["A52A2A", "Brown"],
//    ["000000", "Black"],
//    ["808080", "Grey"],
//    ["FFFFFF", "White"]
//    ]

