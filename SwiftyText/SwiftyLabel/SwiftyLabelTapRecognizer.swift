//
//  SwiftyLabelTapRecognizer.swift
//  SwiftyText
//
//  Created by Luke on 12/28/15.
//  Copyright © 2015 geeklu.com. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

class SwiftyLabelTapRecognizer: UIGestureRecognizer {
    internal var numberOfTapsRequired: Int = 1
    internal var timeoutTimer: NSTimer?
    
    override func reset() {
        timeoutTimer?.invalidate()
        timeoutTimer = nil
    }
    
    internal func handleTimeout(timer: NSTimer){
        timer.invalidate()
        self.state = .Cancelled
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        guard touches.count == 1 else {
            self.state = .Failed
            return
        }
        self.state = .Began
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        self.state = .Changed
    }
    
    internal override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        if let touch = touches.first {
            if self.numberOfTapsRequired == 1 {
                if touch.tapCount == 1 || touch.tapCount == 0 {
                    self.state = .Ended
                }
            } else {
                if touch.tapCount < numberOfTapsRequired {
                    if timeoutTimer != nil {
                        timeoutTimer?.invalidate()
                    }
                    timeoutTimer = NSTimer.scheduledTimerWithTimeInterval(0.27, target: self, selector: "handleTimeout:", userInfo: nil, repeats: false)
                }else if touch.tapCount == numberOfTapsRequired {
                    if timeoutTimer != nil {
                        timeoutTimer?.invalidate()
                    }
                    self.state = .Ended
                }
            }
        }
        
        super.touchesEnded(touches, withEvent: event)
    }
    
    override func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesCancelled(touches, withEvent: event)
        self.state = .Cancelled
    }
}