//
//  NSLayoutExtensions.swift
//  SwiftyText
//
//  Created by Luke on 12/3/15.
//  Copyright © 2015 geeklu.com. All rights reserved.
//

import Foundation

extension NSLayoutManager {
    func glyphRectsWithCharacterRange(range: NSRange, containerInset inset:UIEdgeInsets) -> [CGRect]? {
        
        let glyphRangeForCharacters = self.glyphRangeForCharacterRange(range, actualCharacterRange: nil)
        var touchGlyphRects:[CGRect] = []
    
        self.enumerateLineFragmentsForGlyphRange(glyphRangeForCharacters, usingBlock: { (lineRect: CGRect, usedRect: CGRect, textContainer: NSTextContainer, glyphRange: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            
            let currentLineGlyphRange = NSIntersectionRange(glyphRangeForCharacters, glyphRange)
            let glyphRect = self.boundingRectForGlyphRange(currentLineGlyphRange, inTextContainer: textContainer)
            var glyphRectInContainerView = glyphRect
            glyphRectInContainerView.origin.x += inset.left
            glyphRectInContainerView.origin.y += inset.top
            
            glyphRectInContainerView = CGRectInset(glyphRectInContainerView, -2, 0)
            touchGlyphRects.append(glyphRectInContainerView)
        })
        
        if touchGlyphRects.count > 0 {
            return touchGlyphRects
        }
        return nil
        
    }
}