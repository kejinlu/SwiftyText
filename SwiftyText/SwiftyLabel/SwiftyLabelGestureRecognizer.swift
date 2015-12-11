//
//  SwiftyLabelGestureRecognizer.swift
//  SwiftyLabel
//
//  Created by Luke on 12/1/15.
//  Copyright © 2015 geeklu.com. All rights reserved.
//

import Foundation
import UIKit.UIGestureRecognizerSubclass

enum SwiftyLabelGestureRecognizerResult: Int {
    case Unknow = 0
    case Tap
    case LongPress
}

class SwiftyLabelGestureRecognizer: UIGestureRecognizer {
    internal var minimumPressDuration: CFTimeInterval?
    internal var allowableMovement: CGFloat = 0.0
    internal var initialPoint: CGPoint
    
    internal var result: SwiftyLabelGestureRecognizerResult
    
    internal var longPressTimer: NSTimer?
    internal var isLongPressInterrupt = false
    
    override internal init(target: AnyObject?, action: Selector) {
        
        self.minimumPressDuration = 0.7
        self.allowableMovement = 10
        self.initialPoint = CGPointZero
        
        self.result = SwiftyLabelGestureRecognizerResult.Unknow
        
        super.init(target: target, action: action)
    }
    
    internal override func reset(){
        super.reset()
        
        self.result = .Unknow
        self.initialPoint = CGPointZero
        self.longPressTimer?.invalidate()
        self.longPressTimer = nil

        self.isLongPressInterrupt = false
    }
    
    internal func longPressed(timer: NSTimer){
        timer.invalidate()
        self.result = .LongPress
        self.state = .Ended
    }
    
    internal func isTouchCloseToInitialPoint(touch: UITouch) -> Bool{
        let point = touch.locationInView(self.view)
        let xDistance = self.initialPoint.x - point.x
        let yDistance = self.initialPoint.y - point.y
        
        let squaredDistance = xDistance * xDistance + yDistance * yDistance
        let isClose = squaredDistance <= self.allowableMovement * self.allowableMovement
        return isClose
    }
    
    internal override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        if let touch = touches.first {
            self.initialPoint = touch.locationInView(self.view)
            self.state = .Began
            self.longPressTimer = NSTimer.scheduledTimerWithTimeInterval(self.minimumPressDuration!, target: self, selector:"longPressed:", userInfo: nil, repeats: false)
            
        }
        super.touchesBegan(touches, withEvent: event)
    }
    
    internal override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        if let touch = touches.first{
            if !self.isLongPressInterrupt && !self.isTouchCloseToInitialPoint(touch){
                self.isLongPressInterrupt = true
                self.longPressTimer?.invalidate()
                self.longPressTimer = nil
            }
        }
        
        super.touchesMoved(touches, withEvent: event)
    }
    
    internal override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent) {
        self.result = .Tap
        self.state = .Ended
        super.touchesEnded(touches, withEvent: event)
    }
    
}
