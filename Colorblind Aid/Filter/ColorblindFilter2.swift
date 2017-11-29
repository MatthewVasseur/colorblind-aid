//
//  ColorblindFilter2.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 11/29/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

//import Foundation
import UIKit

class ColorblindFilter2: CIFilter {
    @objc dynamic var inputImage: CIImage?
    
    @objc dynamic var inputLongVector: CIVector?
    @objc dynamic var inputMedVector: CIVector?
    @objc dynamic var inputShortVector: CIVector?
    
    @objc dynamic var inputRVector: CIVector?
    @objc dynamic var inputGVector: CIVector?
    @objc dynamic var inputBVector: CIVector?
    
    private var colorblindKernel: CIColorKernel = {
        let colorblindShaderPath = Bundle.main.path(forResource: "LMSFilter", ofType: "cikernel")
        
        guard let path = colorblindShaderPath,
            let code = try? String(contentsOfFile: path),
            let kernel = CIColorKernel(source: code) else
        {
            fatalError("Unable to build monochrome shader")
        }
        
        return kernel
    }()
    
    override public var outputImage: CIImage! {
        get {
            if let inputImage = self.inputImage {
                let args = [inputImage,
                            inputRVector!,
                            inputGVector!,
                            inputBVector!]
//                            inputLongVector!,
//                            inputMedVector!,
//                            inputShortVector!]
                    as [Any]
                return colorblindKernel.apply(extent: inputImage.extent, arguments: args)
            } else {
                return nil
            }
        }
    }
}
