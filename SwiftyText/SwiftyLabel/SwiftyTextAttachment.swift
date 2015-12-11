//
//  SwiftyTextAttachment.swift
//  SwiftyLabel
//
//  Created by Luke on 12/1/15.
//  Copyright © 2015 geeklu.com. All rights reserved.
//

import Foundation

public enum TBTextAttachmentTextVerticalAlignment: Int {
    case Bottom = 0
    case Center
    case Top
    case Scale
}

public class SwiftyTextAttachment: NSTextAttachment {
    public var contentView: UIView?
    public private(set) var contentViewFrameInTextContainer:CGRect?
    public var contentViewPadding: CGFloat = 0.0
    
    public var attachmentTextVerticalAlignment: TBTextAttachmentTextVerticalAlignment = .Bottom
    
    public var verticalOffset:CGFloat? = nil //default is nil
    
    public var userInfo:[String: AnyObject?]?
    
    public override func attachmentBoundsForTextContainer(textContainer: NSTextContainer?, proposedLineFragment lineFrag: CGRect, glyphPosition position: CGPoint, characterIndex charIndex: Int) -> CGRect {
        var attachmentBounds = CGRectZero
        
        if !CGRectEqualToRect(CGRectZero, self.bounds) {
            attachmentBounds = self.bounds
            
            if self.contentView != nil {
                var lineFragmentPadding:CGFloat = 0.0
                if textContainer != nil {
                    lineFragmentPadding = textContainer!.lineFragmentPadding
                }
                contentViewFrameInTextContainer = CGRectMake(position.x  + self.contentViewPadding + lineFragmentPadding, position.y, attachmentBounds.size.width, attachmentBounds.size.height);
                attachmentBounds.size.width += (self.contentViewPadding * 2);
            }
            return attachmentBounds
        }
        
        if self.image != nil || self.contentView != nil {
            var attachmentSize = CGSizeZero
            if self.image != nil {
                attachmentSize = self.image!.size
            } else {
                attachmentSize = self.contentView!.frame.size
            }
            
            switch self.attachmentTextVerticalAlignment {
            case .Bottom :
                attachmentBounds = CGRectMake(0, 0, attachmentSize.width, attachmentSize.height)
                break
            case .Center :
                let y = (CGRectGetHeight(lineFrag) - attachmentSize.height)/2;
                attachmentBounds = CGRectMake(0, y + self.verticalOffset!, attachmentSize.width, attachmentSize.height)
                break
            case .Top :
                attachmentBounds = CGRectMake(0, CGRectGetHeight(lineFrag) - attachmentSize.height + self.verticalOffset!, attachmentSize.width, attachmentSize.height);
                break
            case .Scale :
                let scale = CGRectGetHeight(lineFrag)/attachmentSize.height;
                attachmentBounds = CGRectMake(0, self.verticalOffset!, attachmentSize.width * scale, attachmentSize.height * scale);
                if (self.contentView != nil) {
                    var contnetViewFrame = self.contentView!.frame;
                    contnetViewFrame.size = attachmentBounds.size;
                    contentViewFrameInTextContainer = contnetViewFrame;
                }
                break
            }
            
            if (self.contentView != nil) {
                attachmentBounds.size.width += (self.contentViewPadding * 2);
                var contentViewFrame = self.contentView!.frame;
                var lineFragmentPadding:CGFloat = 0.0
                if textContainer != nil {
                    lineFragmentPadding = textContainer!.lineFragmentPadding
                }
                contentViewFrame.origin.x = position.x  + self.contentViewPadding + lineFragmentPadding
                contentViewFrame.origin.y = position.y;
                contentViewFrameInTextContainer = contentViewFrame;
            }
        } else {
            attachmentBounds = super.attachmentBoundsForTextContainer(textContainer, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex);
        }
        
        return attachmentBounds
    }
}