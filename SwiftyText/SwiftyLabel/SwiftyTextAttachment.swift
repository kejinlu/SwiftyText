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
    
    /** The layout padding at the beginning and end of the view or image attachment
     */
    public var padding: CGFloat = 0.0
    
    /** Image size setting for the image attachment when use Bottom, Center or Top Vertical Alignment
     */
    public var imageSize: CGSize = CGSizeZero
    
    public var attachmentTextVerticalAlignment: TBTextAttachmentTextVerticalAlignment = .Bottom
    
    public var verticalOffset: CGFloat = 0
    public var fontDescender: CGFloat = 0
    
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
                contentViewFrameInTextContainer = CGRectMake(position.x  + self.padding + lineFragmentPadding, position.y, attachmentBounds.size.width, attachmentBounds.size.height);
                attachmentBounds.size.width += (self.padding * 2);
            }
            return attachmentBounds
        }
        
        let totalOffset = self.verticalOffset + self.fontDescender
        
        if self.image != nil || self.contentView != nil {
            var attachmentSize = CGSizeZero
            if self.image != nil {
                if CGSizeEqualToSize(CGSizeZero, self.imageSize) {
                    attachmentSize = self.image!.size
                } else {
                    attachmentSize = self.imageSize
                }
            } else {
                attachmentSize = self.contentView!.frame.size
            }
            
            switch self.attachmentTextVerticalAlignment {
            case .Bottom :
                attachmentBounds = CGRectMake(0, 0, attachmentSize.width, attachmentSize.height)
                break
            case .Center :
                let y = (CGRectGetHeight(lineFrag) - attachmentSize.height)/2;
                attachmentBounds = CGRectMake(0, y + totalOffset, attachmentSize.width, attachmentSize.height)
                break
            case .Top :
                attachmentBounds = CGRectMake(0, CGRectGetHeight(lineFrag) - attachmentSize.height + totalOffset, attachmentSize.width, attachmentSize.height);
                break
            case .Scale :
                let scale = CGRectGetHeight(lineFrag)/attachmentSize.height;
                attachmentBounds = CGRectMake(0, totalOffset, attachmentSize.width * scale, attachmentSize.height * scale);
                if (self.contentView != nil) {
                    var contnetViewFrame = self.contentView!.frame;
                    contnetViewFrame.size = attachmentBounds.size;
                    self.contentViewFrameInTextContainer = contnetViewFrame;
                }
                break
            }
            
            if (self.contentView != nil) {
                attachmentBounds.size.width += (self.padding * 2);
                var contentViewFrame = self.contentView!.frame;
                var lineFragmentPadding:CGFloat = 0.0
                if textContainer != nil {
                    lineFragmentPadding = textContainer!.lineFragmentPadding
                }
                contentViewFrame.origin.x = position.x  + self.padding + lineFragmentPadding
                contentViewFrame.origin.y = position.y;
                self.contentViewFrameInTextContainer = contentViewFrame;
            }
        } else {
            attachmentBounds = super.attachmentBoundsForTextContainer(textContainer, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex);
        }
        
        return attachmentBounds
    }
}


/**
 Blank placeholder usded for image padding
 */
public class SwiftyTextBlankAttachment: NSTextAttachment {
    public var width: CGFloat {
        get{
            return CGRectGetWidth(bounds)
        }
        
        set {
            bounds.size.width = newValue
            bounds.size.height = 1
        }
    }
}