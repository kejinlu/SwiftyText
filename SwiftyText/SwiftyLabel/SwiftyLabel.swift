//
//  SwiftyLabel.swift
//  SwiftyLabel
//
//  Created by Luke on 12/1/15.
//  Copyright © 2015 geeklu.com. All rights reserved.
//

import Foundation

public class SwiftyLabel: UIView, NSLayoutManagerDelegate, UIGestureRecognizerDelegate {
    
    // MARK:- Properties
    
    public var font: UIFont? {
        didSet {
            if self.text != nil {
                if font != nil {
                    self.textStorage.addAttribute(NSFontAttributeName, value: font!, range: self.textStorage.entireRange())
                } else {
                    //if set as nil, use default
                    self.textStorage.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(17), range: self.textStorage.entireRange())
                }
            }
        }
    }
    
    public var textColor: UIColor? {
        didSet {
            if self.text != nil {
                if textColor != nil {
                    self.textStorage.addAttribute(NSForegroundColorAttributeName, value: textColor!, range: self.textStorage.entireRange())
                } else {
                    self.textStorage.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: self.textStorage.entireRange())
                }
            }
        }
    }
    
    public var textAlignment: NSTextAlignment = .Left{
        didSet {
            self.updateTextParaphStyleWithPropertyName("alignment", value: NSNumber(integer: textAlignment.rawValue))
        }
    }
    
    public var lineSpacing: CGFloat = 0.0 {
        didSet {
            self.updateTextParaphStyleWithPropertyName("lineSpacing", value: NSNumber(float: Float(lineSpacing)))
        }
    }
    
    /** Default value: NSLineBreakMode.ByWordWrapping, The line break mode defines the behavior of the last line of the label.
     */
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
    
    public var firstLineHeadIndent:CGFloat = 0.0 {
        didSet {
            self.updateTextParaphStyleWithPropertyName("firstLineHeadIndent", value: NSNumber(float: Float(firstLineHeadIndent)))
        }
    }
    
    /** Hold the content for the text or attributedText property
     */
    internal var content: AnyObject?
    
    public var text: String? {
        get {
            if self.content != nil {
                return self.textStorage.string
            } else {
                return nil
            }
        }
        
        set {
            let range = self.textStorage.entireRange()
            self.content = newValue
            if newValue != nil {
                self.textStorage.replaceCharactersInRange(range, withString: newValue!)
                self.updateTextParaphStyle()
                self.needsParse = true
            } else {
                self.textStorage.replaceCharactersInRange(range, withString: "")
            }

            self.setNeedsDisplay()
        }
    }
    
    /**the underlying attributed string drawn by the label, 
     if set, the label ignores the properties above.
     In addition, assigning a new a value updates the values in the font, textColor, and other style-related properties so that they reflect the style information starting at location 0 in the attributed string.
     */
    public var attributedText: NSAttributedString? {
        get {
            if self.content != nil {
                let range = self.textStorage.entireRange()
                return self.textStorage.attributedSubstringFromRange(range)
            } else {
                return nil
            }
        }
        
        set {
            self.content = newValue
            let range = self.textStorage.entireRange()
            if newValue != nil {
                self.textStorage.replaceCharactersInRange(range, withAttributedString: newValue!)
                self.needsParse = true
            } else {
                self.textStorage.replaceCharactersInRange(range, withString: "")
            }

            self.setNeedsDisplay()
        }
    }
    
    public var numberOfLines: Int {
        get {
            return self.textContainer.maximumNumberOfLines
        }
        
        set {
            self.textContainer.maximumNumberOfLines = newValue
            self.layoutManager.textContainerChangedGeometry(self.textContainer)
            self.setNeedsDisplay()
        }
    }
    
    internal var textContainer = NSTextContainer()
    public var textContainerInset = UIEdgeInsetsZero{
        didSet {
            self.textContainer.size = UIEdgeInsetsInsetRect(self.bounds, textContainerInset).size
            self.layoutManager.textContainerChangedGeometry(self.textContainer)
            self.setNeedsDisplay()
        }
    }
    
    /** The exclusionPaths for internal textContainer, so the exclusionPaths should be relatived to the text container's origin
     */
    public var exclusionPaths: [UIBezierPath] {
        get {
            return self.textContainer.exclusionPaths
        }
        
        set {
            self.textContainer.exclusionPaths = exclusionPaths
            self.setNeedsDisplay()
        }
    }
    
    internal var layoutManager = NSLayoutManager()
    internal var textStorage = SwiftyTextStorage()
    
    public var parser: SwiftyTextParser? {
        didSet {
            self.needsParse = true
            self.setNeedsDisplay()
        }
    }
    internal var needsParse: Bool = false
    
    internal var asyncTextLayer: CALayer?
    internal var asyncTextRenderQueue: dispatch_queue_t?
    public var drawsTextAsynchronously: Bool = false {
        didSet {
            if drawsTextAsynchronously {
                if self.asyncTextLayer == nil {
                    self.asyncTextLayer = CALayer()
                    self.asyncTextLayer?.frame = self.layer.bounds
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
            self.setNeedsDisplay()
        }
    }
    
    /**
     When the touch is enabled on SwiftyLabel itself, you can set the highlightLayerColor for the label when touch.
     
     - important: highlightLayerColor should apply the alpha component.
     */
    public var highlightLayerColor: UIColor?;
    
    internal var touchHighlightLayer: CALayer?
    internal var touchInfo = SwiftyLabelTouchInfo()
    
    //[rangeString: [attributeName: attribute]]
    internal var touchAttributesMap: [String: [String: AnyObject]]?
    
    public var supportedGestures: SwiftyLabelGesture = [.None]
    internal var singleTapRecognizer = SwiftyLabelTapRecognizer()
    internal var doubleTapRecognizer = SwiftyLabelTapRecognizer()
    internal var longPressRecognizer = SwiftyLabelLongPressRecognizer()
    
    public var delegate: SwiftyLabelDelegate?
    
    // MARK:- Init
    
    func commonInit() {
        self.textContainer.size = frame.size
        self.layoutManager.addTextContainer(self.textContainer)
        self.textStorage.addLayoutManager(self.layoutManager)
        
        self.contentMode = .Redraw
        self.layoutManager.delegate = self
        
        self.singleTapRecognizer.numberOfTapsRequired = 1
        self.singleTapRecognizer.cancelsTouchesInView = false
        self.singleTapRecognizer.delegate = self
        self.singleTapRecognizer.addTarget(self, action: "handleSingleTap:")
        self.addGestureRecognizer(self.singleTapRecognizer)
        
        self.doubleTapRecognizer.numberOfTapsRequired = 2
        self.doubleTapRecognizer.cancelsTouchesInView = false
        self.doubleTapRecognizer.delegate = self;
        self.doubleTapRecognizer.addTarget(self, action: "handleDoubleTap:")
        self.addGestureRecognizer(self.doubleTapRecognizer)
        
        self.longPressRecognizer.cancelsTouchesInView = false
        self.longPressRecognizer.delegate = self
        self.longPressRecognizer.addTarget(self, action: "handleLongPress:")
        self.addGestureRecognizer(self.longPressRecognizer)
        
        self.singleTapRecognizer.requireGestureRecognizerToFail(self.doubleTapRecognizer)
        self.singleTapRecognizer.requireGestureRecognizerToFail(self.longPressRecognizer)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    // MARK:- storage 
    
    public func setLink(link: SwiftyTextLink?, range: NSRange) {
        self.textStorage.setLink(link, range: range)
    }
    
    public func insertAttachment(attachment: SwiftyTextAttachment, atIndex loc: Int) {
        self.textStorage.insertAttachment(attachment, atIndex: loc)
    }
    /**
     Returns the link attribute at a given position, and by reference the range and the glyph rects of the link.
     
     - parameter location: is relative to SwiftyLabel's bounds origin
     - parameter range: If non-NULL, upon return contains the range of the link returened
     - parameter rects: If non-NULL, upon return contains all the glyph rects of the link
     - returns: The link at location if existed, otherwise nil
     */
    public func linkAtLocation(location: CGPoint, effectiveRange range: NSRangePointer, effectiveGlyphRects rects: UnsafeMutablePointer<[CGRect]>) -> SwiftyTextLink? {
        var locationInTextContainer = location
        locationInTextContainer.x -= self.textContainerInset.left
        locationInTextContainer.y -= self.textContainerInset.top
        
        let touchedIndex = self.layoutManager.characterIndexForPoint(locationInTextContainer, inTextContainer: self.textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        let link:SwiftyTextLink? = self.textStorage.attribute(SwiftyTextLinkAttributeName, atIndex: touchedIndex, longestEffectiveRange: range, inRange: NSMakeRange(0, self.textStorage.length)) as? SwiftyTextLink
        
        if link != nil {
            let glyphRects = self.layoutManager.glyphRectsWithCharacterRange(range.memory, containerInset: self.textContainerInset)
            if glyphRects != nil {
                if location.isInRects(glyphRects!) {
                    rects.memory = glyphRects!
                    return link
                }
            }
        }
        return nil;
    }
    
    // MARK:- Touch Events
    func resetTouch(){
        self.touchHighlightLayer?.removeFromSuperlayer()
        
        
        if touchInfo.link?.highlightedAttributes != nil {
            self.setHighlight(false, withRange: touchInfo.linkRange!, textLink: touchInfo.link!)
        }
        self.touchHighlightLayer = nil
        self.touchAttributesMap = nil
        
        touchInfo.reset()
    }
    
    public override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard touches.count == 1 else {
            super.touchesBegan(touches, withEvent: event)
            return
        }
        if let link = touchInfo.link {
            
            let shapeLayer = CAShapeLayer()
            shapeLayer.path = UIBezierPath.bezierPathWithGlyphRects(touchInfo.linkGlyphRects!, radius: (link.highlightLayerRadius ?? 3.0)).CGPath
            shapeLayer.fillColor = link.highlightLayerColor?.CGColor ?? UIColor.grayColor().colorWithAlphaComponent(0.3).CGColor
            self.touchHighlightLayer = shapeLayer
            
            if link.highlightedAttributes != nil {
                self.setHighlight(true, withRange: touchInfo.linkRange!, textLink: link)
            }
        }
        
        if let highlightLayer = self.touchHighlightLayer {
            self.layer.addSublayer(highlightLayer)
        }
        
        super.touchesBegan(touches, withEvent: event)
    }
    
    public override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard touches.count == 1 else {
            super.touchesMoved(touches, withEvent: event)
            return
        }
        if touchInfo.link != nil && self.touchHighlightLayer != nil {
            let touch = touches.first
            let location = touch!.locationInView(self)
            if location.isInRects(touchInfo.linkGlyphRects!) {
                if self.touchHighlightLayer?.superlayer != self.layer {
                    self.layer.addSublayer(self.touchHighlightLayer!)
                    if touchInfo.link?.highlightedAttributes != nil {
                        self.setHighlight(true, withRange: touchInfo.linkRange!, textLink: touchInfo.link!)
                    }
                }
                
            } else {
                if self.touchHighlightLayer?.superlayer == self.layer {
                    self.touchHighlightLayer!.removeFromSuperlayer()
                    if touchInfo.link?.highlightedAttributes != nil {
                        self.setHighlight(false, withRange: touchInfo.linkRange!, textLink: touchInfo.link!)
                    }
                }
            }
        }
        
        super.touchesMoved(touches, withEvent: event)
    }
    
    public override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard touches.count == 1 else {
            super.touchesEnded(touches, withEvent: event)
            return
        }
        
        self.resetTouch()
        super.touchesEnded(touches, withEvent: event)
    }
    
    public override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        guard touches?.count == 1 else {
            super.touchesCancelled(touches, withEvent: event)
            return
        }
        self.resetTouch()
        super.touchesCancelled(touches, withEvent: event)
    }
    

    // MARK:- GestureRecognizer Delegate
    public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        let link = touchInfo.link
        if link != nil {
            if (link!.gestures.contains(.Tap) && gestureRecognizer == self.singleTapRecognizer) || (link!.gestures.contains(.LongPress) && gestureRecognizer == self.longPressRecognizer) {
                return true
            }
        } else {
            if (self.supportedGestures.contains(.Tap) && gestureRecognizer == self.singleTapRecognizer) || (self.supportedGestures.contains(.LongPress) && gestureRecognizer == self.longPressRecognizer) || (self.supportedGestures.contains(.DoubleTap) && gestureRecognizer == self.doubleTapRecognizer) {
                return true
            }
        }
        return false
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view == self {
            self.touchInfo.configWithTouch(touch)
            return true
        } else {
            return false
        }
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
 
    // MARK:- GestureRecognizer Actions
    internal func handleSingleTap(gestureRecognizer: UITapGestureRecognizer){
        if gestureRecognizer.state == .Ended {
            if let link = touchInfo.link {
                let location = gestureRecognizer.locationInView(self)
                if location.isInRects(touchInfo.linkGlyphRects!) {
                    self.delegate?.swiftyLabel(self, didTapWithTextLink: link, range: touchInfo.linkRange!)
                }
            } else {
                self.delegate?.swiftyLabelDidTap(self)
            }
        }
    }
    
    internal func handleDoubleTap(gestureRecognizer: UITapGestureRecognizer){
        if gestureRecognizer.state == .Ended {
            self.delegate?.swiftyLabelDidDoubleTap(self)
        }
    }
    
    internal func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .Ended {
            if let link = touchInfo.link {
                self.delegate?.swiftyLabel(self, didLongPressWithTextLink: link, range: touchInfo.linkRange!)
            } else {
                self.delegate?.swiftyLabelDidLongPress(self)
            }
        }
    }
    
    // MARK:- Internal attributed storage operation
    
    internal func updateTextParaphStyle() {
        self.updateTextParaphStyleWithPropertyName("alignment", value: NSNumber(integer: self.textAlignment.rawValue))
        self.updateTextParaphStyleWithPropertyName("lineSpacing", value: NSNumber(float: Float(lineSpacing)))
        self.updateTextParaphStyleWithPropertyName("firstLineHeadIndent", value: NSNumber(float: Float(firstLineHeadIndent)))
    }
    
    internal func updateTextParaphStyleWithPropertyName(name: String, value: AnyObject) {
        if self.text != nil {
            let existedParagraphStyle = self.textStorage.attribute(NSParagraphStyleAttributeName, atIndex: 0, longestEffectiveRange: nil, inRange: NSMakeRange(0, self.textStorage.length))
            var mutableParagraphStyle = existedParagraphStyle?.mutableCopy() as? NSMutableParagraphStyle
            if mutableParagraphStyle == nil {
                mutableParagraphStyle = NSMutableParagraphStyle()
            }
            
            mutableParagraphStyle?.setValue(value, forKey: name)
            self.textStorage.addAttribute(NSParagraphStyleAttributeName, value: mutableParagraphStyle!.copy(), range: self.textStorage.entireRange())
            self.setNeedsDisplay()
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
    

    
    // MARK:- Draw
    
    override public func drawRect(rect: CGRect) {
        super.drawRect(rect)
        self.drawTextWithRect(rect, async: self.drawsTextAsynchronously)
    }
    
    func drawTextWithRect(rect: CGRect, async: Bool) {
        
        if async {
            dispatch_async(self.asyncTextRenderQueue!, {
                if self.needsParse {
                    self.parser?.parseText(self.textStorage)
                    self.needsParse = false
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
            if self.needsParse {
                self.parser?.parseText(self.textStorage)
                self.needsParse = false
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
        CATransaction.begin()
        CATransaction.setDisableActions(true) //disable implicit animation
        self.asyncTextLayer?.frame = self.layer.bounds
        CATransaction.commit()
    }
    
    // MARK:- Layout Manager Delegate
    public func layoutManager(layoutManager: NSLayoutManager, didCompleteLayoutForTextContainer textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        if (layoutFinishedFlag) {
            for attachement in self.textStorage.viewAttachments {
                if (attachement.contentView != nil) {
                    var frame = attachement.contentViewFrameInTextContainer!;
                    frame.origin.x += self.textContainerInset.left;
                    frame.origin.y += self.textContainerInset.top;
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        attachement.contentView!.removeFromSuperview()
                        attachement.contentView!.frame = frame;
                        self.insertSubview(attachement.contentView!, atIndex: 0)
                    })
                }
            }
        }
    }
}



/**
 The gesture supported by SwiftyLabel itself
 */
public struct SwiftyLabelGesture: OptionSetType {
    public let rawValue: UInt
    public init(rawValue: UInt){ self.rawValue = rawValue}
    
    public static let None = SwiftyLabelGesture(rawValue: 0)
    public static let Tap = SwiftyLabelGesture(rawValue: 1)
    public static let LongPress = SwiftyLabelGesture(rawValue: 1 << 1)
    public static let DoubleTap = SwiftyLabelGesture(rawValue: 1 << 2)
}



struct SwiftyLabelTouchInfo{
    var touch: UITouch?
    
    var link: SwiftyTextLink?
    var linkRange: NSRange?
    var linkGlyphRects: [CGRect]?
    
    mutating func configWithTouch(aTouch: UITouch) {
        self.touch = aTouch
        
        let label = aTouch.view as? SwiftyLabel
        let location = aTouch.locationInView(label)
        var effectiveRange = NSMakeRange(NSNotFound, 0)
        var effectiveGlyphRects = [CGRect]()
        
        let touchLink = label?.linkAtLocation(location, effectiveRange: &effectiveRange, effectiveGlyphRects: &effectiveGlyphRects)
        if touchLink != nil {
            self.link = touchLink
            self.linkRange = effectiveRange
            self.linkGlyphRects = effectiveGlyphRects
        }
    }
    
    mutating func reset(){
        self.touch = nil
        self.link = nil
        self.linkRange = nil
        self.linkGlyphRects = nil
    }
}



public protocol SwiftyLabelDelegate: NSObjectProtocol {
    
    /// Delegate methods for the touch of link
    func swiftyLabel(swiftyLabel: SwiftyLabel, didTapWithTextLink link: SwiftyTextLink, range: NSRange)
    func swiftyLabel(swiftyLabel: SwiftyLabel, didLongPressWithTextLink link:SwiftyTextLink, range: NSRange)
    
    /// Delegate methods for the touch of label itselft
    func swiftyLabelDidTap(swiftyLabel: SwiftyLabel)
    func swiftyLabelDidLongPress(swiftyLabel: SwiftyLabel)
    func swiftyLabelDidDoubleTap(SwiftyLabel: SwiftyLabel)
}



//Default implementations for SwiftyLabelDelegate
public extension SwiftyLabelDelegate {
    func swiftyLabel(swiftyLabel: SwiftyLabel, didTapWithTextLink link: SwiftyTextLink, range: NSRange){}
    func swiftyLabel(swiftyLabel: SwiftyLabel, didLongPressWithTextLink link:SwiftyTextLink, range: NSRange){}
    
    func swiftyLabelDidTap(swiftyLabel: SwiftyLabel){}
    func swiftyLabelDidLongPress(swiftyLabel: SwiftyLabel){}
    func swiftyLabelDidDoubleTap(swiftyLabel: SwiftyLabel){}
}



extension CGSize {
    public func insetsWith(insets: UIEdgeInsets) -> CGSize{
        return CGSizeMake(self.width - insets.left - insets.right, self.height - insets.top - insets.bottom)
    }
}



extension CGPoint {
    public func isInRects(rects: [CGRect]) -> Bool{
        for rect in rects {
            if CGRectContainsPoint(rect, self) {
                return true
            }
        }
        return false
    }
}
