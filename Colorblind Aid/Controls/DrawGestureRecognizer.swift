//
//  DrawGestureRecognizer.swift
//  Colorblind Aid
//
//  Created by Matthew Vasseur on 11/7/17.
//  Copyright © 2017 CompanyName. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

class DrawGestureRecognizer: UIGestureRecognizer {
    // MARK: - Properties
    var origin: CGPoint?
    var rect: CGRect?
    
    override var numberOfTouches: Int {
        return 1
    }
    
    // MARK: - Initializer
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
    }
    
    // MARK: - Touch Handlers
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get the touch (should only be one)
        if touches.count != 1 {
            self.state = .failed
        }
        guard let touch = touches.first else {
            return
        }
        
        // Initialize origin, and rect
        origin = touch.location(in: self.view)
        rect = CGRect(origin: origin!, size: CGSize())
        
        // Update state
        state = .began
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        // Get the touch (should only be one)
        guard let touch = touches.first else {
            return
        }
        
        // Update rect
        let location = touch.location(in: self.view)
        rect = CGRect(from: origin!, to: location)
        
        // Update state
        state = .changed
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        // Get the touch (should only be one)
        guard let touch = touches.first else {
            return
        }
        
        // Update rect
        let location = touch.location(in: self.view)
        rect = CGRect(from: origin!, to: location)
        
        // Clear origin
        origin = nil
        
        // Update state
        state = .ended
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Clear everything
        origin = nil
        rect = nil
        
        // Update state
        state = .cancelled
    }
    
    override func reset() {
        // Clear everything
        origin = nil
        rect = nil
    }
}
