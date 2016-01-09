//
//  SwiftyLabelLongPressRecognizer.swift
//  SwiftyText
//
//  Created by Luke on 12/28/15.
//  Copyright © 2015 geeklu.com. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

public class SwiftyLabelLongPressRecognizer: UIGestureRecognizer {
    public var minimumPressDuration: CFTimeInterval = 0.7
    public var allowableMovement: CGFloat = 10.0
    internal var initialPoint: CGPoint = CGPointZero
    
    internal var longPressTimer: NSTimer?
    
    internal func isTouchCloseToInitialPoint(touch: UITouch) -> Bool {
        let point = touch.locationInView(self.view)
        let xDistance = self.initialPoint.x - point.x
        let yDistance = self.initialPoint.y - point.y
        
        let squaredDistance = xDistance * xDistance + yDistance * yDistance
        let isClose = squaredDistance <= self.allowableMovement * self.allowableMovement
        return isClose
    }
    
    internal func longPressed(timer: NSTimer) {
        timer.invalidate()
        self.state = .Ended
    }
    
    public override func reset(){
        super.reset()
        
        self.initialPoint = CGPointZero
        self.longPressTimer?.invalidate()
        self.longPressTimer = nil
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        
        guard touches.count == 1 else {
            self.state = .Failed
            return
        }
        
        if let touch = touches.first {
            self.state = .Began
            self.initialPoint = touch.locationInView(self.view)
            self.longPressTimer = NSTimer.scheduledTimerWithTimeInterval(self.minimumPressDuration, target: self, selector:"longPressed:", userInfo: nil, repeats: false)
            
        }
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        if let touch = touches.first{
            if !self.isTouchCloseToInitialPoint(touch){
                self.longPressTimer?.invalidate()
                self.longPressTimer = nil
                self.state = .Failed
            }
        }
        super.touchesMoved(touches, withEvent: event)
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesEnded(touches, withEvent: event)
        self.state = .Failed
    }
    
    override public func touchesCancelled(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesCancelled(touches, withEvent: event)
        self.state = .Cancelled
    }
}