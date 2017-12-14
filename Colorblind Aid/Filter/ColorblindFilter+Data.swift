//
//  ColorblindFilter+Data.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 11/26/17.
//  Copyright © 2017 Matthew Vasseur. All rights reserved.
//

import CoreImage

/// Data for supported colorblind filters
extension ColorblindFilter {
    
    struct colorblindTransformMatrix {
        var red: CIVector
        var green: CIVector
        var blue: CIVector
        var algoName: Constants.algoNames
    }
    
    static let data: [Constants.ColorblindType: colorblindTransformMatrix] = [
        .normal: colorblindTransformMatrix(red: CIVector(x: 1, y: 0, z: 0, w: 0), green: CIVector(x: 0, y: 1, z: 0, w: 0), blue: CIVector(x: 0, y: 0, z: 1, w: 0), algoName: .rgb),
        .protanopia: colorblindTransformMatrix(red: CIVector(x: 0.567, y: 0.433, z: 0, w: 0), green: CIVector(x: 0.558, y: 0.442, z: 0, w: 0), blue: CIVector(x: 0, y: 0.242, z: 0.758, w: 0), algoName: .rgb),
        .protanomaly: colorblindTransformMatrix(red: CIVector(x: 0.817, y: 0.183, z: 0, w: 0), green: CIVector(x: 0.333, y: 0.667, z: 0, w: 0), blue: CIVector(x: 0, y: 0.125, z: 0.875, w: 0), algoName: .rgb),
        .deuteranopia: colorblindTransformMatrix(red: CIVector(x: 0.625, y: 0.375, z: 0, w: 0), green: CIVector(x: 0.7, y: 0.3, z: 0, w: 0), blue: CIVector(x: 0, y: 0.3, z: 0.7, w: 0), algoName: .rgb),
        .deuteranomaly: colorblindTransformMatrix(red: CIVector(x: 0.8, y: 0.2, z: 0, w: 0), green: CIVector(x: 0.258, y: 0.742, z: 0, w: 0), blue: CIVector(x: 0, y: 0.142, z: 0.858, w: 0), algoName: .rgb),
        .tritanopia: colorblindTransformMatrix(red: CIVector(x: 0.95, y: 0.05, z: 0, w: 0), green: CIVector(x: 0, y: 0.433, z: 0.567, w: 0), blue: CIVector(x: 0, y: 0.475, z: 0.525, w: 0), algoName: .rgb),
        .tritanomaly: colorblindTransformMatrix(red: CIVector(x: 0.967, y: 0.033, z: 0, w: 0), green: CIVector(x: 0, y: 0.733, z: 0.267, w: 0), blue: CIVector(x: 0, y: 0.183, z: 0.817, w: 0), algoName: .rgb),
        .achromatopsia: colorblindTransformMatrix(red: CIVector(x: 0.299, y: 0.587, z: 0.114, w: 0), green: CIVector(x: 0.299, y: 0.587, z: 0.114, w: 0), blue: CIVector(x: 0.299, y: 0.587, z: 0.114, w: 0), algoName: .rgb),
        .achromatomaly: colorblindTransformMatrix(red: CIVector(x: 0.618, y: 0.32, z: 0.062, w: 0), green: CIVector(x: 0.163, y: 0.775, z: 0.062, w: 0), blue: CIVector(x: 0.163, y: 0.32, z: 0.516, w: 0), algoName: .rgb),
        
        .protanopiaLMS: colorblindTransformMatrix(red: CIVector(x: 0.0, y: 2.02344, z: -2.52581, w: 0), green: CIVector(x: 0.0, y: 1.0, z: 0.0, w: 0), blue: CIVector(x: 0.0, y: 0.0, z: 1.0, w: 0), algoName: .lms),
        .deuteranopiaLMS: colorblindTransformMatrix(red: CIVector(x: 1.0, y: 0.0, z: 0.0, w: 0), green: CIVector(x: 0.494207, y: 0.0, z: 1.24827, w: 0), blue: CIVector(x: 0.0, y: 0.0, z: 1.0, w: 0), algoName: .lms),
        .tritanopiaLMS: colorblindTransformMatrix(red: CIVector(x: 1.0, y: 0.0, z: 0.0, w: 0), green: CIVector(x: 0.0, y: 1.0, z: 0.0, w: 0), blue: CIVector(x: -0.395913, y: 0.801109, z: 0.0, w: 0), algoName: .lms)
    ]
}
