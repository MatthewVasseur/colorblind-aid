//
//  ColorblindFilter.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 11/29/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import Foundation
import UIKit

class ColorblindFilter: CIFilter {
    @objc dynamic var inputImage: CIImage?

    /// Transformation vector for Red or Long
    @objc dynamic var inputVector0: CIVector?
    /// Transformation vector for Green or Medium
    @objc dynamic var inputVector1: CIVector?
    /// Transformation vector for Blue or Short
    @objc dynamic var inputVector2: CIVector?
    
    /// Name of algorithm to use (either LMSFilter or RGBFilter)
    @objc dynamic var inputAlgoName: String?
    
    private func colorblindKernel() -> CIColorKernel {
        let colorblindShaderPath = Bundle.main.path(forResource: inputAlgoName, ofType: "cikernel")
        
        guard let path = colorblindShaderPath, let code = try? String(contentsOfFile: path),
            let kernel = CIColorKernel(source: code) else {
                fatalError("Unable to build colorblind shader")
        }
        
        return kernel
    }
    
    override public var outputImage: CIImage? {
        get {
            guard let inputImage = inputImage, let inputVector0 = inputVector0, let inputVector1 = inputVector1,
                let inputVector2 = inputVector2, inputAlgoName != nil else {
                    return nil
            }
            
            let args = [inputImage, inputVector0, inputVector1, inputVector2] as [Any]

            return colorblindKernel().apply(extent: inputImage.extent, arguments: args)
        }
    }
    
//    override var attributes: [String: Any] {
//        return [kCIAttributeFilterDisplayName: "Colorblind Filter",
//            "inputImage": [kCIAttributeIdentity: 0,
//                           kCIAttributeClass: "CIImage",
//                           kCIAttributeDisplayName: "Image",
//                           kCIAttributeType: kCIAttributeTypeImage],
//            
//            "inputVector0": [kCIAttributeIdentity: 0,
//                            kCIAttributeClass: "CIVector",
//                            kCIAttributeDisplayName: "Vector One",
//                            kCIAttributeDefault: CIVector(x: 1.0, y: 0.0, z: 0.0)],
//            
//            "inputVector1": [kCIAttributeIdentity: 0,
//                            kCIAttributeClass: "CIVector",
//                            kCIAttributeDisplayName: "Vector Two",
//                            kCIAttributeDefault: CIVector(x: 0.0, y: 1.0, z: 0.0)],
//            
//            "inputVector2": [kCIAttributeIdentity: 0,
//                            kCIAttributeClass: "CIVector",
//                            kCIAttributeDisplayName: "Vector Three",
//                            kCIAttributeDefault: CIVector(x: 0.0, y: 0.0, z: 1.0)],
//            
//            "inputAlgoName": [kCIAttributeIdentity: 0,
//                             kCIAttributeClass: "String",
//                             kCIAttributeDisplayName: "Algorithm Name"]
//        ]
//    }
}

// MARK: - CIFilterConstructor
class ColorblindFilterVendor: NSObject, CIFilterConstructor {
    
    func filter(withName name: String) -> CIFilter? {
        if name == "ColorblindFilter" {
            return ColorblindFilter()
        } else {
            return nil
        }
    }
    
    static func register() {
        CIFilter.registerName("ColorblindFilter", constructor: ColorblindFilterVendor(), classAttributes: [
            kCIAttributeFilterCategories: [kCICategoryColorAdjustment]
            ])
    }
}

