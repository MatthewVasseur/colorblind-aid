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
    
    private var colorblindKernel: CIColorKernel = {
        let colorblindShaderPath = Bundle.main.path(forResource: "ColorblindFilter", ofType: "cikernel")
        
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
                let args = [inputImage as AnyObject]
                return colorblindKernel.apply(extent: inputImage.extent, arguments: args)
            } else {
                return nil
            }
        }
    }
    
    //let kernels = CIKernel.makeKernels(source:
    //    "kernel vec4 swapRG(sampler image) { " +
    //        "  vec4 t = sample(image, samplerCoord(image)); float r = t.r; t.r = 0; t.g = 0; return t;" +
    //    "}")!
    //let myKernel = kernels[0]
    

    //    override public var outputImage: CIImage! {
    //        get {
    //            if let inputImage = self.inputImage {
    //                let args = [inputImage as AnyObject]
    //                return myKernel.apply(extent: inputImage.extent, roiCallback: callback, arguments: args)
    //            } else {
    //                return nil
    //            }
    //        }
    //    }
    //    override var outputImage: CIImage? {
    //        let src = CISampler(image: self.inputImage!)
    //        //return self.apply(myKernel, arguments: [src], options: nil)
    //
    //
    //        return myKernel.apply(extent: (inputImage?.extent)!, roiCallback: callback, arguments: [src])
    //
    //    }
}
