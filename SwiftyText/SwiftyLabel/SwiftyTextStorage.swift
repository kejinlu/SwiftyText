//
//  SwiftyTextStorage.swift
//  SwiftyLabel
//
//  Created by Luke on 12/1/15.
//  Copyright © 2015 geeklu.com. All rights reserved.
//

import Foundation
import UIKit

public class SwiftyTextStorage : NSTextStorage{
    internal var storage: NSMutableAttributedString
    internal var viewAttachments:[SwiftyTextAttachment] = []
    
    // MARK:- Init
    public override init(string str: String, attributes attrs: [String : AnyObject]?){
        self.storage = NSMutableAttributedString(string: str, attributes: attrs)
        super.init()
    }
    
    convenience override init(){
        self.init(string: "", attributes: nil)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- Private method
    private func isValidRange(range: NSRange) -> Bool {
        var isValid = false
        let fullRange = NSMakeRange(0, self.length)
        if range.location >= fullRange.location && NSMaxRange(range) <= NSMaxRange(fullRange) {
            isValid = true
        }
        return isValid
    }
    
    // MARK:- Convenience attribute setting method
    
    public func setFont(font: UIFont?, range:NSRange){
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
            } else {
                self.removeAttribute(SwiftyTextLinkAttributeName, range: range)
            }
        }
    }
    
    /*
    if attachment's verticalOffset is nil, it will be assigned to the descender of the font of the neighbour
    */
    public func insertAttachment(attachment:SwiftyTextAttachment?, atIndex loc:Int) {
        if loc <= self.length {
            if attachment != nil {
                if attachment?.contentView != nil &&
                    !self.viewAttachments.contains(attachment!){
                    self.viewAttachments.append(attachment!)
                }
                
                if attachment?.verticalOffset == nil {
                    var neighbourFont: UIFont? = nil
                    if loc < self.length {
                        neighbourFont = self.attribute(NSFontAttributeName, atIndex: loc, effectiveRange: nil) as? UIFont
                    } else if loc - 1 >= 0 {
                        neighbourFont = self.attribute(NSFontAttributeName, atIndex: loc - 1, effectiveRange: nil) as? UIFont
                    }
                    
                    if neighbourFont != nil {
                        attachment?.verticalOffset = neighbourFont!.descender
                    }
                }
                
                let attachmentAttributedString = NSAttributedString(attachment: attachment!)
                self.insertAttributedString(attachmentAttributedString, atIndex: loc)
            }
        }
    }
    
    // MARK:- NSMutableAttributedString&NSAttributedString primitives
    
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


extension SwiftyTextStorage {
    public func attributesRangeMapInRange(textRange: NSRange) -> [String: [String: AnyObject]]?{
        
        var attributesRangeMap:[String: [String: AnyObject]]? = [String: [String: AnyObject]]()
        self.enumerateAttributesInRange(textRange, options: NSAttributedStringEnumerationOptions()) { (attrs, range, stop) -> Void in
            let rangeString = NSStringFromRange(range)
            attributesRangeMap![rangeString] = attrs
        }
        return attributesRangeMap
    }
}