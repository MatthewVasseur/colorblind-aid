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
    @objc dynamic var inputRVector: CIVector?
    /// Transformation vector for Green or Medium
    @objc dynamic var inputGVector: CIVector?
    /// Transformation vector for Blue or Short
    @objc dynamic var inputBVector: CIVector?
    
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
            guard let inputImage = inputImage, let inputRVector = inputRVector, let inputGVector = inputGVector,
                let inputBVector = inputBVector, inputAlgoName != nil else {
                    return nil
            }
            
            let args = [inputImage, inputRVector, inputGVector, inputBVector] as [Any]

            return colorblindKernel().apply(extent: inputImage.extent, arguments: args)
        }
    }
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

