//
//  ColorblindFilter.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 11/26/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import Foundation
import CoreImage

class ColorblindFilter {
//{Normal:{ R:[100, 0, 0], G:[0, 100, 0], B:[0, 100, 0]},
//    Protanopia:{ R:[56.667, 43.333, 0], G:[55.833, 44.167, 0], B:[0, 24.167, 75.833]},
//    Protanomaly:{ R:[81.667, 18.333, 0], G:[33.333, 66.667, 0], B:[0, 12.5, 87.5]},
//    Deuteranopia:{ R:[62.5, 37.5, 0], G:[70, 30, 0], B:[0, 30, 70]},
//    Deuteranomaly:{ R:[80, 20, 0], G:[25.833, 74.167, 0], B:[0, 14.167, 85.833]},
//    Tritanopia:{ R:[95, 5, 0], G:[0, 43.333, 56.667], B:[0, 47.5, 52.5]},
//    Tritanomaly:{ R:[96.667, 3.333, 0], G:[0, 73.333, 26.667], B:[0, 18.333, 81.667]},
//    Achromatopsia:{ R:[29.9, 58.7, 11.4], G:[29.9, 58.7, 11.4], B:[29.9, 58.7, 11.4]},
//    Achromatomaly:{ R:[61.8, 32, 6.2], G:[16.3, 77.5, 6.2], B:[16.3, 32.0, 51.6]}
    
//    return({'Normal':[1,0,0,0,0, 0,1,0,0,0, 0,0,1,0,0, 0,0,0,1,0, 0,0,0,0,1],
//    'Protanopia':[0.567,0.433,0,0,0, 0.558,0.442,0,0,0, 0,0.242,0.758,0,0, 0,0,0,1,0, 0,0,0,0,1],
//    'Protanomaly':[0.817,0.183,0,0,0, 0.333,0.667,0,0,0, 0,0.125,0.875,0,0, 0,0,0,1,0, 0,0,0,0,1],
//    'Deuteranopia':[0.625,0.375,0,0,0, 0.7,0.3,0,0,0, 0,0.3,0.7,0,0, 0,0,0,1,0, 0,0,0,0,1],
//    'Deuteranomaly':[0.8,0.2,0,0,0, 0.258,0.742,0,0,0, 0,0.142,0.858,0,0, 0,0,0,1,0, 0,0,0,0,1],
//    'Tritanopia':[0.95,0.05,0,0,0, 0,0.433,0.567,0,0, 0,0.475,0.525,0,0, 0,0,0,1,0, 0,0,0,0,1],
//    'Tritanomaly':[0.967,0.033,0,0,0, 0,0.733,0.267,0,0, 0,0.183,0.817,0,0, 0,0,0,1,0, 0,0,0,0,1],
//    'Achromatopsia':[0.299,0.587,0.114,0,0, 0.299,0.587,0.114,0,0, 0.299,0.587,0.114,0,0, 0,0,0,1,0, 0,0,0,0,1],
//    'Achromatomaly':[0.618,0.320,0.062,0,0, 0.163,0.775,0.062,0,0, 0.163,0.320,0.516,0,0,0,0,0,1,0,0,0,0,0]}[v]);

    
    struct colorblindTransform {
        var red: CIVector
        var green: CIVector
        var blue: CIVector
        var alpha: CIVector
        var bias: CIVector
    }
    
    var data: [Constants.ColorblindType: colorblindTransform] = [:]
    
    init () {
        let normalA = CIVector(x: 0, y: 0, z: 0, w: 1)
        let normalBias = CIVector(x: 0, y: 0, z: 0, w: 0)
        
        data[.normal] = colorblindTransform(red: CIVector(x: 1, y: 0, z: 0, w: 0), green: CIVector(x: 0, y: 1, z: 0, w: 0), blue: CIVector(x: 0, y: 0, z: 1, w: 0), alpha: normalA, bias: normalBias)
        data[.protanopia] = colorblindTransform(red: CIVector(x: 0.567, y: 0.433, z: 0, w: 0), green: CIVector(x: 0.558, y: 0.442, z: 0, w: 0), blue: CIVector(x: 0, y: 0.242, z: 0.758, w: 0), alpha: normalA, bias: normalBias)
        data[.protanomaly] = colorblindTransform(red: CIVector(x: 0.817, y: 0.183, z: 0, w: 0), green: CIVector(x: 0.333, y: 0.667, z: 0, w: 0), blue: CIVector(x: 0, y: 0.125, z: 0.875, w: 0), alpha: normalA, bias: normalBias)
        data[.deuteranopia] = colorblindTransform(red: CIVector(x: 0.625, y: 0.375, z: 0, w: 0), green: CIVector(x: 0.7, y: 0.3, z: 0, w: 0), blue: CIVector(x: 0, y: 0.3, z: 0.7, w: 0), alpha: normalA, bias: normalBias)
        data[.deuteranomaly] = colorblindTransform(red: CIVector(x: 0.8, y: 0.2, z: 0, w: 0), green: CIVector(x: 0.258, y: 0.742, z: 0, w: 0), blue: CIVector(x: 0, y: 0.142, z: 0.858, w: 0), alpha: normalA, bias: normalBias)
        data[.tritanopia] = colorblindTransform(red: CIVector(x: 0.95, y: 0.05, z: 0, w: 0), green: CIVector(x: 0, y: 0.433, z: 0.567, w: 0), blue: CIVector(x: 0, y: 0.475, z: 0.525, w: 0), alpha: normalA, bias: normalBias)
        data[.tritanomaly] = colorblindTransform(red: CIVector(x: 0.967, y: 0.033, z: 0, w: 0), green: CIVector(x: 0, y: 0.733, z: 0.267, w: 0), blue: CIVector(x: 0, y: 0.183, z: 0.817, w: 0), alpha: normalA, bias: normalBias)
        data[.achromatopsia] = colorblindTransform(red: CIVector(x: 0.299, y: 0.587, z: 0.114, w: 0), green: CIVector(x: 0.299, y: 0.587, z: 0.114, w: 0), blue: CIVector(x: 0.299, y: 0.587, z: 0.114, w: 0), alpha: normalA, bias: normalBias)
        data[.achromatomaly] = colorblindTransform(red: CIVector(x: 0.618, y: 0.32, z: 0.062, w: 0), green: CIVector(x: 0.163, y: 0.775, z: 0.062, w: 0), blue: CIVector(x: 0.163, y: 0.32, z: 0.516, w: 0), alpha: normalA, bias: normalBias)
    }
}
