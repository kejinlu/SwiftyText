//
//  SwiftyLabel.swift
//  SwiftyLabel
//
//  Created by Luke on 12/1/15.
//  Copyright © 2015 geeklu.com. All rights reserved.
//

import Foundation

internal let SwiftyTextDetectorResultAttributeName: String = "SwiftyTextDetectorResult"


public protocol SwiftyLabelDelegate: NSObjectProtocol {
    
    /// Delegate methods for the touch of link
    func swiftyLable(swiftyLabel: SwiftyLabel, shouldTouchWithLink link: SwiftyTextLink, range: NSRange) -> Bool
    func swiftyLabel(swiftyLabel: SwiftyLabel, didTapWithTextLink link: SwiftyTextLink, range: NSRange)
    func swiftyLabel(swiftyLabel: SwiftyLabel, didLongPressWithTextLink link:SwiftyTextLink, range: NSRange)
    
    /// Delegate methods for the touch of label itselft
    func swiftyLabelShoudTouch(swiftyLabel: SwiftyLabel) -> Bool
    func swiftyLabelDidTap(swiftyLabel: SwiftyLabel)
    func swiftyLabelDidLongPress(swiftyLabel: SwiftyLabel)
}

//Default implementations for SwiftyLabelDelegate
public extension SwiftyLabelDelegate {
    func swiftyLable(swiftyLabel: SwiftyLabel, shouldTouchWithLink link: SwiftyTextLink, range: NSRange) -> Bool {
        return true
    }
    func swiftyLabel(swiftyLabel: SwiftyLabel, didTapWithTextLink link: SwiftyTextLink, range: NSRange){}
    func swiftyLabel(swiftyLabel: SwiftyLabel, didLongPressWithTextLink link:SwiftyTextLink, range: NSRange){}
    
    func swiftyLabelShoudTouch(swiftyLabel: SwiftyLabel) -> Bool{
        return false
    }
    func swiftyLabelDidTap(swiftyLabel: SwiftyLabel){}
    func swiftyLabelDidLongPress(swiftyLabel: SwiftyLabel){}
}

public class SwiftyLabel : UIView, NSLayoutManagerDelegate, UIGestureRecognizerDelegate {
    
    // MARK:- Properties
    
    public var font: UIFont? {
        didSet {
            if self.text != nil {
                if font != nil {
                    self.textStorage.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(0, self.textStorage.length))
                } else {
                    //if set as nil, use default
                    self.textStorage.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(17), range: NSMakeRange(0, self.textStorage.length))
                }
            }

        }
    }
    
    public var textColor: UIColor? {
        didSet {
            if self.text != nil {
                if textColor != nil {
                    self.textStorage.addAttribute(NSForegroundColorAttributeName, value: textColor!, range: NSMakeRange(0, self.textStorage.length))
                } else {
                    self.textStorage.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: NSMakeRange(0, self.textStorage.length))
                }
            }
        }
    }
    
    public var textAlignment: NSTextAlignment? {
        didSet {
            self.updateTextParaphStyle()
        }
    }
    
    public var lineSpacing: CGFloat? {
        didSet {
            self.updateTextParaphStyle()
        }
    }
    
    /// Default value: NSLineBreakMode.ByWordWrapping  The line break mode defines the behavior of the last line of the label.
    public var lineBreakMode: NSLineBreakMode {
        get {
            return self.textContainer.lineBreakMode
        }
        
        set {
            self.textContainer.lineBreakMode = newValue
            self.layoutManager.textContainerChangedGeometry(self.textContainer)
            self.setNeedsDisplay()
        }
    }
    
    public var firstLineHeadIndent:CGFloat? {
        didSet {
            self.updateTextParaphStyle()
        }
    }
    
    public var text: String? {
        didSet {
            let range = NSMakeRange(0, self.textStorage.string.characters.count)
            self.textStorage.replaceCharactersInRange(range, withString: text!)
            self.updateTextParaphStyle()
            self.needsProcessDetectors = true
            self.setNeedsDisplay()
        }
    }
    

    ///the underlying attributed string drawn by the label, if set, the label ignores the properties above.
    public var attributedText: NSAttributedString? {
        didSet {
            let range = NSMakeRange(0, self.textStorage.length)
            self.textStorage.replaceCharactersInRange(range, withAttributedString: attributedText!)
            self.needsProcessDetectors = true
            self.setNeedsDisplay()
        }
    }
    
    public var numberOfLines: Int {
        didSet {
            self.textContainer.maximumNumberOfLines = numberOfLines
            self.layoutManager.textContainerChangedGeometry(self.textContainer)
            self.setNeedsDisplay()
        }
    }
    
    public private(set) var textContainer: NSTextContainer
    public var textContainerInset: UIEdgeInsets {
        didSet {
            self.textContainer.size = UIEdgeInsetsInsetRect(self.bounds, textContainerInset).size
            self.layoutManager.textContainerChangedGeometry(self.textContainer)
        }
    }
    
    public private(set) var layoutManager: NSLayoutManager
    public private(set) var textStorage: SwiftyTextStorage
    public private(set) var textDetectors: [SwiftyTextDetector]? = []
    internal var needsProcessDetectors: Bool = false
    
    internal var asyncTextLayer: CALayer?
    internal var asyncTextRenderQueue: dispatch_queue_t?
    public var drawsTextAsynchronously: Bool {
        didSet {
            if drawsTextAsynchronously {
                if self.asyncTextLayer == nil {
                    self.asyncTextLayer = CALayer()
                }
                self.layer.addSublayer(self.asyncTextLayer!)
                self.asyncTextRenderQueue = dispatch_queue_create("com.geeklu.swiftylabel-async", DISPATCH_QUEUE_SERIAL);
            } else {
                if self.asyncTextLayer != nil {
                    self.asyncTextLayer?.removeFromSuperlayer()
                    self.asyncTextLayer = nil
                }
                self.asyncTextRenderQueue = nil;
            }
        }
    }
    
    
    internal var touchMaskLayer: CALayer?
    internal var touchRange: NSRange?
    internal var touchGlyphRects: [CGRect]?
    internal var touchLink: SwiftyTextLink?
    
    //[rangeString: [attributeName: attribute]]
    internal var touchAttributesMap: [String: [String: AnyObject]]?
    
    
    public var delegate: SwiftyLabelDelegate?
    
    // MARK:- Init
    
    override public init(frame: CGRect) {
        self.textContainer = NSTextContainer(size: frame.size)
        self.textContainerInset = UIEdgeInsetsZero
        self.layoutManager = NSLayoutManager()
        self.layoutManager.addTextContainer(self.textContainer)
        self.textStorage = SwiftyTextStorage()
        self.textStorage.addLayoutManager(self.layoutManager)
        self.drawsTextAsynchronously = false;
        self.numberOfLines = 0
        
        super.init(frame: frame)
        self.contentMode = .Redraw
        self.layoutManager.delegate = self
        let textGestureRecognizer = SwiftyLabelGestureRecognizer(target: self, action: "textGestureAction:")
        textGestureRecognizer.delegate = self
        self.addGestureRecognizer(textGestureRecognizer)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// location is relative to SwiftyLabel's bounds origin
    public func linkAtLocation(location: CGPoint, effectiveRange range: NSRangePointer, effectiveGlyphRects: UnsafeMutablePointer<[CGRect]>) -> SwiftyTextLink? {
        var locationInTextContainer = location
        locationInTextContainer.x -= self.textContainerInset.left
        locationInTextContainer.y -= self.textContainerInset.top
        
        let touchedIndex = self.layoutManager.characterIndexForPoint(locationInTextContainer, inTextContainer: self.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        let link:SwiftyTextLink? = self.textStorage.attribute(SwiftyTextLinkAttributeName, atIndex: touchedIndex, longestEffectiveRange: range, inRange: NSMakeRange(0, self.textStorage.length)) as? SwiftyTextLink
        
        if link != nil {
            let glyphRects = self.layoutManager.glyphRectsWithCharacterRange(range.memory, containerInset: self.textContainerInset)
            if glyphRects != nil {
                var isInRect = false
                for glyphRect in glyphRects! {
                    if CGRectContainsPoint(glyphRect, location) {
                        isInRect = true
                        break
                    }
                }
                
                if isInRect {
                    effectiveGlyphRects.memory = glyphRects!
                    return link
                }
            }
        }
        return nil;
    }
    
    // MARK:- GestureRecognizer
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view == self {
            return true
        } else {
            return false
        }
    }
    
    public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        var shouldTouchLink = true
        var shouldTouchLabel = false
        
        if self.delegate != nil {
            shouldTouchLabel = (self.delegate?.swiftyLabelShoudTouch(self))!
        }
        
        let location = gestureRecognizer.locationInView(self)
        var effectiveRange = NSMakeRange(NSNotFound, 0)
        var effectiveGlyphRects = [CGRect]()

        let link = self.linkAtLocation(location, effectiveRange: &effectiveRange, effectiveGlyphRects: &effectiveGlyphRects)
        if link != nil {
            
            if self.delegate != nil {
                shouldTouchLink = (self.delegate?.swiftyLable(self, shouldTouchWithLink: link!, range: effectiveRange))!
            }
            
            if shouldTouchLink {
                self.touchLink = link
                self.touchRange = effectiveRange
                self.touchGlyphRects = effectiveGlyphRects
                
                let shapeLayer = CAShapeLayer()
                shapeLayer.path = UIBezierPath.bezierPathWithGlyphRectValues(self.touchGlyphRects!, radius: (self.touchLink?.highlightedMaskRadius ?? 3.0)).CGPath
                shapeLayer.fillColor = self.touchLink?.highlightedMaskColor?.CGColor ?? UIColor.grayColor().colorWithAlphaComponent(0.3).CGColor
                self.touchMaskLayer = shapeLayer
            }
        }
        
        if shouldTouchLabel && (link == nil || !shouldTouchLink){
            let maskLayer = CALayer()
            maskLayer.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.3).CGColor
            maskLayer.frame = self.layer.bounds
            self.touchMaskLayer = maskLayer
        }
        
        if (link != nil && shouldTouchLink) || shouldTouchLabel {
            return true
        } else {
            return false
        }
    }
    
    internal func textGestureAction(gestureRecognizer: SwiftyLabelGestureRecognizer){
        switch gestureRecognizer.state {
        case .Began:
            if self.touchMaskLayer != nil {
                self.layer.addSublayer(self.touchMaskLayer!)
            }
            if self.touchLink != nil {
                self.setHighlight(true, withRange: self.touchRange!, textLink: self.touchLink!)
            }
            break
        case .Changed:
            if self.touchLink != nil && self.touchMaskLayer != nil {
                let location = gestureRecognizer.locationInView(self)
                var isInRect = false
                for rectValue in self.touchGlyphRects! {
                    if CGRectContainsPoint(rectValue, location) {
                        isInRect = true
                        break
                    }
                }
                if isInRect {
                    if self.touchMaskLayer?.superlayer != self.layer {
                        self.layer.addSublayer(self.touchMaskLayer!)
                        self.setHighlight(true, withRange: self.touchRange!, textLink: self.touchLink!)
                    }
                    
                } else {
                    if self.touchMaskLayer?.superlayer == self.layer {
                        self.touchMaskLayer!.removeFromSuperlayer()
                        self.setHighlight(false, withRange: self.touchRange!, textLink: self.touchLink!)
                    }
                }
            }
            break
        case .Ended:
            
            self.touchMaskLayer?.removeFromSuperlayer()
            if self.touchLink != nil {
                self.setHighlight(false, withRange: self.touchRange!, textLink: self.touchLink!)
            }
            switch gestureRecognizer.result {
            case .Tap:
                if self.touchLink != nil {
                    self.delegate?.swiftyLabel(self, didTapWithTextLink: self.touchLink!, range: self.touchRange!)
                } else {
                    self.delegate?.swiftyLabelDidTap(self)
                }
                break
            case .LongPress:
                if self.touchLink != nil {
                    self.delegate?.swiftyLabel(self, didLongPressWithTextLink: self.touchLink!, range: self.touchRange!)
                } else {
                    self.delegate?.swiftyLabelDidLongPress(self)
                }
                break
            default:
                break
            }

            self.touchLink = nil
            self.touchMaskLayer = nil
            self.touchAttributesMap = nil
            break
        default:
            break
        }
    }
    
    // MARK:- Internal attributed storage operation
    
    public func addTextDetector(detector: SwiftyTextDetector) {
        self.textDetectors?.append(detector)
        self.needsProcessDetectors = true
        self.setNeedsDisplay()
    }
    
    public func removeTextDetector(detector: SwiftyTextDetector) {
        let detectorIndex = self.textDetectors?.indexOf(detector)
        if detectorIndex != nil {
            self.textDetectors?.removeAtIndex(detectorIndex!)
        }
    }
    
    public func processTextDetectors() {
        let text = self.textStorage.string
        for textDetector in self.textDetectors! {
            let checkingResults = textDetector.regularExpression.matchesInString(text, options: NSMatchingOptions(), range: NSMakeRange(0, text.characters.count))
            
            for result in checkingResults.reverse() {
                let checkingRange = result.range
                var resultRange = checkingRange
                
                if checkingRange.location == NSNotFound {
                    continue
                }
                
                let detectorResultAttribute = self.textStorage.attribute(SwiftyTextDetectorResultAttributeName, atIndex: checkingRange.location, longestEffectiveRange: nil, inRange: checkingRange)
                if detectorResultAttribute != nil {
                    continue
                }
                
                if let attributes = textDetector.attributes {
                    self.textStorage.addAttributes(attributes, range: checkingRange)
                }
                
                if let replacementFunc = textDetector.replacementAttributedText {
                    let replacement = replacementFunc(checkingResult: result, matchedAttributedText: self.textStorage.attributedSubstringFromRange(checkingRange), sourceAttributedText: self.textStorage)
                    if replacement != nil {
                        self.textStorage.replaceCharactersInRange(checkingRange, withAttributedString: replacement!)
                        resultRange.length = replacement!.length
                    }
                }
                
                if textDetector.linkable {
                    let link = SwiftyTextLink()
                    link.highlightedAttributes = textDetector.highlightedAttributes
                    
                    if textDetector.touchMaskRadius != nil {
                        link.highlightedMaskRadius = textDetector.touchMaskRadius
                    }
                    if textDetector.touchMaskColor != nil {
                        link.highlightedMaskColor = textDetector.touchMaskColor
                    }
                    
                    if let URL = result.URL {
                        link.URL = URL
                    }
                    
                    if let phoneNumber = result.phoneNumber {
                        link.phoneNumber = phoneNumber
                    }
                    
                    if let date = result.date {
                        link.date = date
                    }
                    
                    if let timeZone = result.timeZone {
                        link.timeZone = timeZone
                    }
                    
                    if let addressComponents = result.addressComponents {
                        link.addressComponents = addressComponents
                    }
                    
                    self.textStorage.addAttribute(SwiftyTextLinkAttributeName, value: link, range: resultRange)
                }
                
                self.textStorage.addAttribute(SwiftyTextDetectorResultAttributeName, value: textDetector, range: resultRange)
            }
        }
    }
    
    internal func setHighlight(highlighted: Bool, withRange range:NSRange, textLink link:SwiftyTextLink) {
        if link.highlightedAttributes != nil {
            if highlighted {
                if self.touchAttributesMap == nil {
                    self.touchAttributesMap = self.textStorage.attributesRangeMapInRange(range)
                }
                self.textStorage.addAttributes(link.highlightedAttributes!, range: range)
                self.setNeedsDisplay()
            } else {
                if self.touchAttributesMap != nil {
                    for attributeName in link.highlightedAttributes!.keys {
                        self.textStorage.removeAttribute(attributeName, range: range)
                    }
                    
                    for (rangeString, attributes) in self.touchAttributesMap! {
                        let subRange = NSRangeFromString(rangeString)
                        self.textStorage.addAttributes(attributes, range: subRange)
                    }
                    self.setNeedsDisplay()
                }
            }
        }
    }
    
    public func updateTextParaphStyle() {
        if self.text != nil {
            let existedParagraphStyle = self.textStorage.attribute(NSParagraphStyleAttributeName, atIndex: 0, longestEffectiveRange: nil, inRange: NSMakeRange(0, self.textStorage.length))
            var mutableParagraphStyle = existedParagraphStyle?.mutableCopy() as? NSMutableParagraphStyle
            if mutableParagraphStyle == nil {
                mutableParagraphStyle = NSMutableParagraphStyle()
            }
            if self.textAlignment != nil {
                mutableParagraphStyle!.alignment = self.textAlignment!
            } else {
                mutableParagraphStyle!.alignment = .Left
            }
            
            if self.lineSpacing != nil {
                mutableParagraphStyle!.lineSpacing = self.lineSpacing!
            }
            
            if self.firstLineHeadIndent != nil {
                mutableParagraphStyle!.firstLineHeadIndent = self.firstLineHeadIndent!
            }
            
            self.textStorage.addAttribute(NSParagraphStyleAttributeName, value: mutableParagraphStyle!.copy(), range: NSMakeRange(0, self.textStorage.length))
        }
    }
    
    // MARK:- Draw
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        self.drawTextWithRect(rect, async: self.drawsTextAsynchronously)
    }
    
    func drawTextWithRect(rect: CGRect, async: Bool) {
        
        if async {
            dispatch_async(self.asyncTextRenderQueue!, {
                if self.needsProcessDetectors {
                    self.processTextDetectors()
                    self.needsProcessDetectors = false
                }
                
                let constrainedSize = rect.size.insetsWith(self.textContainerInset)
                if !CGSizeEqualToSize(self.textContainer.size, constrainedSize) {
                    self.textContainer.size = constrainedSize
                    self.layoutManager.textContainerChangedGeometry(self.textContainer)
                }
                
                let textRect:CGRect = UIEdgeInsetsInsetRect(rect, self.textContainerInset)
                let range:NSRange = self.layoutManager.glyphRangeForTextContainer(self.textContainer)
                let textOrigin:CGPoint = textRect.origin
                UIGraphicsBeginImageContextWithOptions(rect.size, false, self.contentScaleFactor)

                self.layoutManager.drawBackgroundForGlyphRange(range, atPoint: textOrigin)
                self.layoutManager.drawGlyphsForGlyphRange(range, atPoint: textOrigin)
                
                let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    CATransaction.begin()
                    CATransaction.setDisableActions(true) //disable implicit animation
                    self.asyncTextLayer!.contents = image.CGImage
                    CATransaction.commit()
                })
            })
        } else {
            if self.needsProcessDetectors {
                self.processTextDetectors()
                self.needsProcessDetectors = false
            }
            
            let constrainedSize = rect.size.insetsWith(self.textContainerInset)
            if !CGSizeEqualToSize(self.textContainer.size, constrainedSize) {
                self.textContainer.size = constrainedSize
                self.layoutManager.textContainerChangedGeometry(self.textContainer)
            }
            
            let textRect:CGRect = UIEdgeInsetsInsetRect(rect, self.textContainerInset)
            let range:NSRange = self.layoutManager.glyphRangeForTextContainer(self.textContainer)
            let textOrigin:CGPoint = textRect.origin
            self.layoutManager.drawBackgroundForGlyphRange(range, atPoint: textOrigin)
            self.layoutManager.drawGlyphsForGlyphRange(range, atPoint: textOrigin)
        }
    }
    
    
    // MARK:- Size & Layout
    
    /// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/TextLayout/Tasks/StringHeight.html
    public func proposedSizeWithConstrainedSize(constrainedSize: CGSize) -> CGSize {
        let constrainedSizeWithInsets = constrainedSize.insetsWith(self.textContainerInset)
        
        self.textContainer.size = constrainedSizeWithInsets
        self.layoutManager.glyphRangeForTextContainer(self.textContainer)
        var proposedSize = self.layoutManager.usedRectForTextContainer(self.textContainer).size
        proposedSize.width += (self.textContainerInset.left + self.textContainerInset.right)
        proposedSize.height += (self.textContainerInset.top + self.textContainerInset.bottom)
        return proposedSize;
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        return self.proposedSizeWithConstrainedSize(size)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        if self.asyncTextLayer != nil {
            self.asyncTextLayer?.frame = self.layer.bounds
        }
    }
    
    // MARK:- Layout Manager Delegate
    public func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        if (layoutFinishedFlag) {
            for attachement in self.textStorage.viewAttachments {
                if (attachement.contentView != nil) {
                    var frame = attachement.contentViewFrameInTextContainer!;
                    frame.origin.x += self.textContainerInset.left;
                    frame.origin.y += self.textContainerInset.top;
                    attachement.contentView!.frame = frame;
                    self.insertSubview(attachement.contentView!, atIndex: 0)
                }
            }
        }
    }
}

extension CGSize {
    public func insetsWith(insets: UIEdgeInsets) -> CGSize{
        return CGSizeMake(self.width - insets.left - insets.right, self.height - insets.top - insets.bottom)
    }
}

