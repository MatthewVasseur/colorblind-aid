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
    var r: Int
    var g: Int
    var b: Int
    var a: CGFloat
    
    let convMatrix = [ 0.4497288, 0.3162486, 0.1844926,
                                   0.2446525, 0.6720283, 0.0833192,
                                   0.0251848, 0.1411824, 0.9224628 ]
    
    init(r: Int, g: Int, b: Int, a: Int) {
        self.r = r
        self.g = g
        self.b = b
        self.a = CGFloat(a)
    }
    
    init(data: UnsafePointer<UInt8>, pixelInfo: Int) {
        r = Int(data[pixelInfo])
        g = Int(data[pixelInfo+1])
        b = Int(data[pixelInfo+2])
        a = CGFloat(data[pixelInfo+3])
        
        print("done!")
    }
    
    func toUIColor() -> UIColor {
        let a = self.a / CGFloat(255.0)
        return UIColor(red: r, green: g, blue: b, withAlpha: a)
    }
    
    func toRGBString() -> String {
        return String(format: "Red: %3d, Green: %3d, Blue: %d", r, g, b)
    }
    
    // Uses matrix from http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html
    func toXYZ() -> (CGFloat, CGFloat, CGFloat) {
        let RGBMatrix: [Double] = [Double(r), Double(g), Double(b)]
        var XYZMatrix = [Double](repeating: 0.0, count: 3)
        
       vDSP_mmulD(convMatrix, 1, RGBMatrix, 1, &XYZMatrix, 3, 1, 3, 3)
       
        print(XYZMatrix)
        
        return (CGFloat(XYZMatrix[0]), CGFloat(XYZMatrix[1]), CGFloat(XYZMatrix[2]))
    }
}
