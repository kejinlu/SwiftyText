//
//  SwiftyTextStorage.swift
//  SwiftyLabel
//
//  Created by Luke on 12/1/15.
//  Copyright © 2015 geeklu.com. All rights reserved.
//

import Foundation
import UIKit

public class SwiftyTextStorage: NSTextStorage {
    
    internal var storage: NSMutableAttributedString
    
    public override init(string str: String, attributes attrs: [String : AnyObject]?) {
        self.storage = NSMutableAttributedString(string: str, attributes: attrs)
        super.init()
    }
    
    convenience override init() {
        self.init(string: "", attributes: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        self.storage = NSMutableAttributedString(string: "", attributes: nil)
        super.init(coder: aDecoder)
    }
    
        
    // NSMutableAttributedString&NSAttributedString primitives
    
    public override var string: String {
        return self.storage.string
    }
    
    public override func attributesAtIndex(location: Int, effectiveRange range: NSRangePointer) -> [String : AnyObject]{
        return self.storage.attributesAtIndex(location, effectiveRange: range)
    }
    
    public override func replaceCharactersInRange(range: NSRange, withString str: String){
        self.beginEditing()
        self.storage.replaceCharactersInRange(range, withString: str)
        self.edited([.EditedAttributes, .EditedCharacters], range: range, changeInLength: str.characters.count - range.length)
        self.endEditing()
        
    }
    
    public override func setAttributes(attrs: [String : AnyObject]?, range: NSRange){
        self.beginEditing()
        self.storage.setAttributes(attrs, range: range)
        self.edited([.EditedAttributes], range: range, changeInLength: 0)
        self.endEditing()
    }
}



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
        if self.isValidRange(range) {
            if font != nil {
                self.addAttribute(NSFontAttributeName, value: font!, range: range)
            } else {
                self.removeAttribute(NSFontAttributeName, range: range)
            }
        }
    }
    
    public func setForegroundColor(foregroundColor: UIColor?, range:NSRange) {
        if self.isValidRange(range) {
            if foregroundColor != nil {
                self.addAttribute(NSForegroundColorAttributeName, value: foregroundColor!, range: range)
            } else {
                self.removeAttribute(NSForegroundColorAttributeName, range: range)
            }
        }
    }
    
    public func setLink(link: SwiftyTextLink?, range:NSRange) {
        if self.isValidRange(range) {
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


extension NSAttributedString {
    public func isValidRange(range: NSRange) -> Bool {
        var isValid = false
        let fullRange = NSMakeRange(0, self.length)
        if range.location >= fullRange.location && NSMaxRange(range) <= NSMaxRange(fullRange) {
            isValid = true
        }
        return isValid
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
        
        let textStorage = SwiftyTextStorage()
        textStorage.replaceCharactersInRange(textStorage.entireRange(), withAttributedString: self)
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