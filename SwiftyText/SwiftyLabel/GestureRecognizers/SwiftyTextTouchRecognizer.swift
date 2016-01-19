//
//  SwiftyTextTouchRecognizer.swift
//  SwiftyText
//
//  Created by Luke on 1/15/16.
//  Copyright © 2016 geeklu.com. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

class SwiftyTextTouchRecognizer: UIGestureRecognizer {
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        self.state = .Began
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        self.state = .Changed
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        self.state = .Ended
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        self.state = .Cancelled
    }
}