//
//  UIBezierPathExtensions.swift
//  SwiftyText
//
//  Created by Luke on 12/3/15.
//  Copyright © 2015 geeklu.com. All rights reserved.
//

import Foundation

extension UIBezierPath{
    class func bezierPathWithGlyphRectValues(rectValues: [NSValue], radius: CGFloat) -> UIBezierPath{
        let path = UIBezierPath()
        
        let rectCount = rectValues.count
        
        for var i = 0; i < rectCount; i++ {
            var previousRectValue:NSValue? = nil
            var nextRectValue:NSValue? = nil
            if i > 0 {
                previousRectValue = rectValues[i-1]
            }
            if i < rectCount - 1 {
                nextRectValue = rectValues[i+1]
            }
            
            var rectCorners = UIRectCorner()
            
            let currentRectValue = rectValues[i]
            let currentRect = currentRectValue.CGRectValue()
            
            let currentRectMinX = CGRectGetMinX(currentRect)
            let currentRectMaxX = CGRectGetMaxX(currentRect)
            
            if previousRectValue != nil {
                let previousRect = previousRectValue!.CGRectValue()
                let previousRectMinX = CGRectGetMinX(previousRect)
                let previousRectMaxX = CGRectGetMaxX(previousRect)
                
                if currentRectMinX < previousRectMinX ||
                    currentRectMinX > previousRectMaxX {
                    rectCorners = rectCorners.union(.TopLeft)
                }
                if currentRectMaxX < previousRectMinX ||
                    currentRectMaxX > previousRectMaxX {
                    rectCorners = rectCorners.union(.TopRight)
                }
            } else {
                rectCorners = rectCorners.union([.TopLeft, .TopRight])
            }
            
            if nextRectValue != nil {
                let nextRect = nextRectValue!.CGRectValue()
                let nextRectMinX = CGRectGetMinX(nextRect)
                let nextRectMaxX = CGRectGetMaxX(nextRect)
                
                if currentRectMinX < nextRectMinX ||
                    currentRectMinX > nextRectMaxX{
                    rectCorners = rectCorners.union(.BottomLeft)
                }
                if currentRectMaxX < nextRectMinX ||
                    currentRectMaxX > nextRectMaxX {
                    rectCorners = rectCorners.union(.BottomRight)
                }
            } else {
                rectCorners = rectCorners.union([.BottomLeft, .BottomRight])
            }
            
            let currentRectPath = UIBezierPath(roundedRect: currentRect, byRoundingCorners: rectCorners, cornerRadii: CGSizeMake(radius, radius))
            path.appendPath(currentRectPath)
        }
        return path
    }
}