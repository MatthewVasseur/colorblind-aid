//
//  Pixel.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 10/25/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import UIKit
import Accelerate

/**
 An RGB pixel
 
 - note: This class is immuatable
 */
class Pixel {
    
    // MARK: - Properties
    let red: CGFloat
    let green: CGFloat
    let blue: CGFloat
    let alpha: CGFloat
    
    var x: CGFloat!
    var y: CGFloat!
    var z: CGFloat!
    
    let convMatrix = [ 0.4497288, 0.3162486, 0.1844926,
                       0.2446525, 0.6720283, 0.0833192,
                       0.0251848, 0.1411824, 0.9224628 ]
    
    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.red = red / CGFloat(255.0)
        self.green = green / CGFloat(255.0)
        self.blue = blue / CGFloat(255.0)
        self.alpha = alpha / CGFloat(255.0)
    }
    
    convenience init(data: UnsafePointer<UInt8>, pixelInfo: Int) {
        let red = CGFloat(data[pixelInfo])
        let green = CGFloat(data[pixelInfo+1])
        let blue = CGFloat(data[pixelInfo+2])
        let alpha = CGFloat(data[pixelInfo+3])
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func toUIColor() -> UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func toRGBString() -> String {
        return String(format: "Red: %3.2f, Green: %3.2f, Blue: %3.2f", red, green, blue)
    }
    
    // Uses technique from https://github.com/mikz/PhilipsHueSDKiOS/blob/master/ApplicationDesignNotes/RGB%20to%20xy%20Color%20conversion.md
    func toXYZ() -> (CGFloat, CGFloat, CGFloat) {
        // Use cached values
        if (x != nil && y != nil && z != nil) {
            return (x, y, z)
        }
        
        // Apply a gamma correction to the RGB values (magic numbers as far as I know)
        let red = (self.red > 0.04045) ? pow((self.red + 0.055) / (1.0 + 0.055), 2.4) : (self.red / 12.92);
        let green = (self.green > 0.04045) ? pow((self.green + 0.055) / (1.0 + 0.055), 2.4) : (self.green / 12.92);
        let blue = (self.blue > 0.04045) ? pow((self.blue + 0.055) / (1.0 + 0.055), 2.4) : (self.blue / 12.92);
        
        // Convert the RGB values to XYZ using the Wide RGB D65 conversion formula
        let X: CGFloat = red * 0.649926 + green * 0.103455 + blue * 0.197109
        let Y: CGFloat = red * 0.234327 + green * 0.743075 + blue * 0.022598
        let Z: CGFloat = red * 0.0000000 + green * 0.053077 + blue * 1.035763
        
        // Calculate the xyz values from the XYZ values
        x = X / (X + Y + Z)
        y = Y / (X + Y + Z)
        z = 1.0 - x - y
        
//        let RGBMatrix: [Double] = [Double(r), Double(g), Double(b)]
//        var XYZMatrix = [Double](repeating: 0.0, count: 3)
//
//        vDSP_mmulD(convMatrix, 1, RGBMatrix, 1, &XYZMatrix, 1, 3, 1, 3)
//
//        print(XYZMatrix)
        
        return (x, y, z)
    }
    
    func toColorName() -> String {
        var colorName: String!
        
        // ensure we have xyz values
        _ = toXYZ()
        
        if (y > 0.5) {
            if (x < 0.3) {
                colorName = "Green"
            } else if (x < 0.4) {
                colorName = "Yellow Green"
            } else if (x < 0.5) {
                colorName = "Yellow"
            }
        } else if (y > 0.3) {
            if (x < 0.2) {
                colorName = "Blue Green"
            } else if (x < 0.4) {
                colorName = "White"
            } else if (x < 0.7) {
                colorName = "Orange"
            }
        } else if (y > 0.2) {
            if (x < 0.2) {
                colorName = "Blue"
            } else if (x < 0.35) {
                colorName = "White"
            } else if (x < 0.5) {
                colorName = "Pink"
            } else if (x < 0.75) {
                colorName = "Red"
            }
        } else if (y > 0.1) {
            if (x < 0.15) {
                colorName = "Blue"
            } else if (x < 0.35) {
                colorName = "Purple"
            } else if (x < 0.55) {
                colorName = "Red Purple"
            } else if (x < 0.75) {
                colorName = "Red"
            }
        } else if (y > 0) {
            if (x < 0.1) {
                colorName = "Blue"
            } else if (x < 0.4) {
                colorName = "Purple"
            }
        }
        
        return colorName ?? "N/A"
    }
}
