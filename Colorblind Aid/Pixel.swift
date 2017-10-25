//
//  Pixel.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 10/25/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import UIKit
import Accelerate

class Pixel {
    
    // MARK: - Properties
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
    var a: CGFloat
    
    let convMatrix = [ 0.4497288, 0.3162486, 0.1844926,
                       0.2446525, 0.6720283, 0.0833192,
                       0.0251848, 0.1411824, 0.9224628 ]
    
    init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) {
        self.r = r / CGFloat(255.0)
        self.g = g / CGFloat(255.0)
        self.b = b / CGFloat(255.0)
        self.a = a / CGFloat(255.0)
    }
    
    convenience init(data: UnsafePointer<UInt8>, pixelInfo: Int) {
        let r = CGFloat(data[pixelInfo])
        let g = CGFloat(data[pixelInfo+1])
        let b = CGFloat(data[pixelInfo+2])
        let a = CGFloat(data[pixelInfo+3])
        
        self.init(r: r, g: g, b: b, a: a)
    }
    
    func toUIColor() -> UIColor {
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    func toRGBString() -> String {
        return String(format: "Red: %3.2f, Green: %3.2f, Blue: %3.2f", r, g, b)
    }
    
    // Uses matrix from http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
    func toXYZ() -> (CGFloat, CGFloat, CGFloat) {
        let RGBMatrix: [Double] = [Double(r), Double(g), Double(b)]
        var XYZMatrix = [Double](repeating: 0.0, count: 3)
        
        vDSP_mmulD(convMatrix, 1, RGBMatrix, 1, &XYZMatrix, 1, 3, 1, 3)
        
        print(XYZMatrix)
        
        return (CGFloat(XYZMatrix[0]), CGFloat(XYZMatrix[1]), CGFloat(XYZMatrix[2]))
    }
}
