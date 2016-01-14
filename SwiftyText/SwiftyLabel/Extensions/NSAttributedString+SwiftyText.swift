//
//  NSAttributedString+SwiftyText.swift
//  SwiftyText
//
//  Created by Luke on 1/14/16.
//  Copyright © 2016 geeklu.com. All rights reserved.
//

import Foundation

extension NSAttributedString {
    public func containsRange(range: NSRange) -> Bool {
        var contains = false
        let entireRange = self.entireRange()
        if range.location >= entireRange.location && NSMaxRange(range) <= NSMaxRange(entireRange) {
            contains = true
        }
        return contains
    }
    
    public func entireRange() -> NSRange {
        let range = NSMakeRange(0, self.length)
        return range
    }
    
    public func proposedSizeWithConstrainedSize(constrainedSize: CGSize, exclusionPaths: [UIBezierPath]?, lineBreakMode: NSLineBreakMode?, maximumNumberOfLines: Int?) -> CGSize {
        let textContainer = NSTextContainer(size: constrainedSize)
        textContainer.lineFragmentPadding = 0.0
        if exclusionPaths != nil {
            textContainer.exclusionPaths = exclusionPaths!
        }
        if lineBreakMode != nil {
            textContainer.lineBreakMode = lineBreakMode!
        }
        if maximumNumberOfLines != nil {
            textContainer.maximumNumberOfLines = maximumNumberOfLines!
        }
        
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        
        let textStorage = NSTextStorage(attributedString: self)
        textStorage.addLayoutManager(layoutManager)
        
        layoutManager.glyphRangeForTextContainer(textContainer)
        var proposedSize = layoutManager.usedRectForTextContainer(textContainer).size
        
        proposedSize.width = ceil(proposedSize.width)
        proposedSize.height = ceil(proposedSize.height)
        return proposedSize
    }
    
    public func neighbourFontDescenderWithRange(range: NSRange) -> CGFloat {
        var fontDescender: CGFloat = 0.0;
        var neighbourAttributs: [String: AnyObject]? = nil;
        if range.location >= 1 {
            neighbourAttributs = self.attributesAtIndex(range.location - 1, effectiveRange: nil)
        } else if (NSMaxRange(range) < self.length) {
            neighbourAttributs = self.attributesAtIndex(NSMaxRange(range) , effectiveRange: nil)
        }
        
        if neighbourAttributs != nil {
            if let neighbourAttachment = neighbourAttributs![NSAttachmentAttributeName] as? SwiftyTextAttachment {
                fontDescender = neighbourAttachment.fontDescender;
            } else if neighbourAttributs![NSFontAttributeName] != nil {
                if let neighbourFont = neighbourAttributs![NSFontAttributeName] as? UIFont{
                    fontDescender = neighbourFont.descender;
                }
            }
        }
        return fontDescender;
    }
    
    internal func viewAttachments() -> [SwiftyTextAttachment] {
        var attachments = [SwiftyTextAttachment]()
        self.enumerateAttribute(NSAttachmentAttributeName, inRange: self.entireRange(), options:[]) { (value: AnyObject?, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if value != nil && value is SwiftyTextAttachment {
                let attachment = value as! SwiftyTextAttachment
                if attachment.contentView != nil {
                    attachments.append(attachment)
                }
            }
        }
        return attachments
    }
    
    internal func attributesRangeMapInRange(textRange: NSRange) -> [String: [String: AnyObject]]? {
        
        var attributesRangeMap:[String: [String: AnyObject]]? = [String: [String: AnyObject]]()
        self.enumerateAttributesInRange(textRange, options: NSAttributedStringEnumerationOptions()) { (attrs, range, stop) -> Void in
            let rangeString = NSStringFromRange(range)
            attributesRangeMap![rangeString] = attrs
        }
        return attributesRangeMap
    }
}