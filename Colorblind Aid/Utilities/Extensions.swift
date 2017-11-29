//
//  Extensions.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 10/10/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import UIKit

extension UIImage {
    /**
     Return a cropped version of the provided image
     - parameter rect: A rectangle whose coordinates specify the area to create an image from
     - returns: The cropped image or nil otherwise
     */
    func crop(toRect rect: CGRect) -> UIImage? {
        guard let imageRef: CGImage = self.cgImage?.cropping(to: rect) else {
            return nil
        }
        let croppedImage: UIImage = UIImage(cgImage: imageRef)
        
        return croppedImage
    }
}

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
    
    /// Extend UIColor initializer to take RGB integers with alpha 1.0
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
    
    /**
     Return a tuple of RBGa cgfloats (Red, Green, Blue, Alpha)
     - returns: (Red, Green, Blue, alpha) tuple of CGFloats
     */
    func getRGBa() -> (CGFloat, CGFloat, CGFloat, CGFloat) {
        var red:   CGFloat = 0
        var green: CGFloat = 0
        var blue:  CGFloat = 0
        var alpha: CGFloat = 0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red*255, green*255, blue*255, alpha)
    }
    
    /**
     Return a tuple of HSL cgfloats (Hue, Saturation, Luminosity)
     - author: Adopted from from: Farbtastic 1.2 (http://acko.net/dev/farbtastic)
     */
    func getHSL() -> (CGFloat, CGFloat, CGFloat) {
        var (red, green, blue, _) = self.getRGBa()
        red /= 255.0
        green /= 255.0
        blue /= 255.0
        
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
        
        return (hue * 255, sat * 255, lum * 255)
    }
    
    /**
     Get the name of the hue corresponding to the color
     
     Relies upon color names struct declared in Constants
     - Author: Created by Chirag Mehta - http://chir.ag/tech/download/ntc
     ntc js (Name that Color JavaScript)
     */
    func toHueName() -> String {
        let (red, green, blue, _) = self.getRGBa()
        let (hue, sat, lum) = self.getHSL()
        
        var ndf1: CGFloat = 0
        var ndf2: CGFloat = 0
        var ndf: CGFloat = 0
        var df: CGFloat = -1
        var cl: Int = -1
        
        
        for (i, color) in Constants.colors.names.enumerated() {
            
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
        
        return cl < 0 ? "N/A" : Constants.colors.names[cl].hueName
    }
}

extension CGRect {
    /**
     Convenience initialize to create a rectangle from two points
     - parameters:
        - from: The top left corner point
        - to: The bottom right corner point
     */
    init(from: CGPoint, to: CGPoint) {
        let width = to.x - from.x
        let height = to.y - from.y
        
        self.init(x: from.x, y: from.y, width: width, height: height)
    }
    
    /**
     Convenience initializer to create a rectangle from a center point and a size
     - parameters:
        - center: The center of the rectangle
        - size: The size (height and width) of the rectangle
     */
    init(center: CGPoint, size: CGSize) {
        let origin = CGPoint(x: center.x - (size.width / 2.0), y: center.y - (size.height / 2.0))
        
        self.init(origin: origin, size: size)
    }
    
    /**
     Scale a rectangle from one set of coordinates to another
     - parameters:
        - from: The original set of coordinates as a rectangle
        - to: The new set of coordinates as a rectangle
     */
    mutating func scale(from: CGRect, to: CGRect) {
        // Calculate scale factors
        let xScale = to.width / from.width
        let yScale = to.height / from.height
        
        // Scale origin and size
        self.origin = CGPoint(x: self.origin.x * xScale, y: self.origin.y * yScale)
        self.size = CGSize(width: self.size.width * xScale, height: self.size.height * yScale)
    }
}

extension CGSize {
    /**
     Creates a square CGSize
     - parameter side: Integer side length
     */
    init(forSquare side: Int) {
        self.init(width: side, height: side)
    }
    
    /**
     Creates a square CGSize
     - parameter side: CGFloat side length
     */
    init(forSquare side: CGFloat) {
        self.init(width: side, height: side)
    }
    
    /**
     Returns a CGSize with height and width inverted
     - returns: CGSize with height and width inverted
     */
    func invert() -> CGSize {
        return CGSize(width: self.height, height: self.width)
    }
    
    /**
     Returns the aspect ratio of the size (width / height)
     - returns: The aspect ratio of the size (width / height)
     */
    func ratio() -> CGFloat {
        return self.width / self.height
    }
}

extension CGPoint {
    /**
     Returns a CGPoint with x and y inverted
     - returns: CGPoint with x and y inverted
     */
    func invert() -> CGPoint {
        return CGPoint(x: self.y, y: self.x)
    }
}
