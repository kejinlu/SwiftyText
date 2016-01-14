//
//  NSMutableAttributedString+SwiftyText.swift
//  SwiftyText
//
//  Created by Luke on 1/14/16.
//  Copyright © 2016 geeklu.com. All rights reserved.
//

import Foundation

extension NSMutableAttributedString {
    
    public var font: UIFont? {
        get {
            var effectiveRange = NSMakeRange(NSNotFound, 0)
            let attribute = self.attribute(NSFontAttributeName, atIndex: 0, longestEffectiveRange: &effectiveRange, inRange: self.entireRange())
            if NSEqualRanges(self.entireRange(), effectiveRange) {
                let fontAttribute = attribute as? UIFont
                return fontAttribute
            } else {
                return nil
            }
            
        }
        set {
            self.setFont(newValue, range: self.entireRange())
        }
    }
    
    public var foregroundColor: UIColor? {
        get {
            var effectiveRange = NSMakeRange(NSNotFound, 0)
            let attribute = self.attribute(NSForegroundColorAttributeName, atIndex: 0, longestEffectiveRange: &effectiveRange, inRange: self.entireRange())
            if NSEqualRanges(self.entireRange(), effectiveRange) {
                let foregroundColorAttribute = attribute as? UIColor
                return foregroundColorAttribute
            } else {
                return nil
            }
        }
        set {
            self.setForegroundColor(newValue, range: self.entireRange())
        }
    }
    
    public func setFont(font: UIFont?, range:NSRange) {
        if self.containsRange(range) {
            if font != nil {
                self.addAttribute(NSFontAttributeName, value: font!, range: range)
            } else {
                self.removeAttribute(NSFontAttributeName, range: range)
            }
        }
    }
    
    public func setForegroundColor(foregroundColor: UIColor?, range:NSRange) {
        if self.containsRange(range) {
            if foregroundColor != nil {
                self.addAttribute(NSForegroundColorAttributeName, value: foregroundColor!, range: range)
            } else {
                self.removeAttribute(NSForegroundColorAttributeName, range: range)
            }
        }
    }
    
    public func setLink(link: SwiftyTextLink?, range:NSRange) {
        if self.containsRange(range) {
            if link != nil {
                self.addAttribute(SwiftyTextLinkAttributeName, value: link!, range: range)
                if link!.attributes != nil {
                    self.addAttributes(link!.attributes!, range: range)
                }
            } else {
                self.removeAttribute(SwiftyTextLinkAttributeName, range: range)
            }
        }
    }
    
    public func insertAttachment(attachment:SwiftyTextAttachment, atIndex loc:Int) {
        if loc <= self.length {
            attachment.fontDescender = self.neighbourFontDescenderWithRange(NSMakeRange(loc, 0))
            var attachmentAttributedString = NSAttributedString(attachment: attachment)
            //Use blank attachment for real image attachment padding
            if attachment.image != nil &&
                attachment.contentView == nil &&
                attachment.padding > 0 {
                    let paddingAttachment = SwiftyTextBlankAttachment()
                    paddingAttachment.width = attachment.padding
                    let paddingAttributedString = NSAttributedString(attachment: paddingAttachment)
                    
                    let mutableAttributedString = NSMutableAttributedString()
                    mutableAttributedString.appendAttributedString(paddingAttributedString)
                    mutableAttributedString.appendAttributedString(attachmentAttributedString)
                    mutableAttributedString.appendAttributedString(paddingAttributedString)
                    attachmentAttributedString = mutableAttributedString.copy() as! NSAttributedString
            }
            self.insertAttributedString(attachmentAttributedString, atIndex: loc)
        }
    }
}