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
    internal var viewAttachments:[SwiftyTextAttachment] {
        var attachments = [SwiftyTextAttachment]()
        self.enumerateAttribute(NSAttachmentAttributeName, inRange: NSMakeRange(0, self.length), options:[]) { (value: AnyObject?, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if value != nil && value is SwiftyTextAttachment {
                let attachment = value as! SwiftyTextAttachment
                if attachment.contentView != nil {
                    attachments.append(attachment)
                }
            }
        }
        return attachments
    }
    
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
                if link!.attributes != nil {
                    self.addAttributes(link!.attributes!, range: range)
                }
            } else {
                self.removeAttribute(SwiftyTextLinkAttributeName, range: range)
            }
        }
    }
    
    /*
    if attachment's verticalOffset is nil, it will be assigned to the descender of the font of the neighbour
    */
    public func insertAttachment(attachment:SwiftyTextAttachment, atIndex loc:Int) {
        if loc <= self.length {
            attachment.fontDescender = self.neighbourFontDescenderWithRange(NSMakeRange(loc, 0))
            var attachmentAttributedString = NSAttributedString(attachment: attachment)
            //使用空白Attachment曲线解决图片padding的问题
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
}