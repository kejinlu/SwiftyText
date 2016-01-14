//
//  SwiftyLabel.swift
//  SwiftyLabel
//
//  Created by Luke on 12/1/15.
//  Copyright © 2015 geeklu.com. All rights reserved.
//

import Foundation
import UIKit

public class SwiftyLabel: UIView, NSLayoutManagerDelegate, UIGestureRecognizerDelegate {
    
    // MARK:- Properties
    
    public var font: UIFont? {
        didSet {
            dispatch_sync(self.textQueue) { () -> Void in
                if self.text != nil {
                    if self.font != nil {
                        self.textStorage.addAttribute(NSFontAttributeName, value: self.font!, range: self.textStorage.entireRange())
                    } else {
                        //if set as nil, use default
                        self.textStorage.addAttribute(NSFontAttributeName, value: UIFont.systemFontOfSize(17), range: self.textStorage.entireRange())
                    }
                    
                    self.setNeedsDisplay()
                }
            }
        }
    }
    
    public var textColor: UIColor? {
        didSet {
            dispatch_sync(self.textQueue) { () -> Void in
                if self.text != nil {
                    if self.textColor != nil {
                        self.textStorage.addAttribute(NSForegroundColorAttributeName, value: self.textColor!, range: self.textStorage.entireRange())
                    } else {
                        self.textStorage.addAttribute(NSForegroundColorAttributeName, value: UIColor.blackColor(), range: self.textStorage.entireRange())
                    }
                }
                self.setNeedsDisplay()
            }
        }
    }
    
    public var textAlignment: NSTextAlignment = .Left{
        didSet {
            dispatch_sync(self.textQueue) { () -> Void in
                self.updateTextParaphStyleWithPropertyName("alignment", value: NSNumber(integer: self.textAlignment.rawValue))
            }
        }
    }
    
    public var lineSpacing: CGFloat = 0.0 {
        didSet {
            dispatch_sync(self.textQueue) { () -> Void in
                self.updateTextParaphStyleWithPropertyName("lineSpacing", value: NSNumber(float: Float(self.lineSpacing)))
            }
        }
    }
    
    /** Default value: NSLineBreakMode.ByWordWrapping, The line break mode defines the behavior of the last line of the label.
     */
    public var lineBreakMode: NSLineBreakMode {
        get {
            return self.textContainer.lineBreakMode
        }
        
        set {
            dispatch_sync(self.textQueue) { () -> Void in
                self.textContainer.lineBreakMode = newValue
                self.layoutManager.textContainerChangedGeometry(self.textContainer)
                self.setNeedsDisplay()
            }
        }
    }
    
    public var firstLineHeadIndent: CGFloat = 0.0 {
        didSet {
            dispatch_sync(self.textQueue) { () -> Void in
                self.updateTextParaphStyleWithPropertyName("firstLineHeadIndent", value: NSNumber(float: Float(self.firstLineHeadIndent)))
            }
        }
    }
    
    internal var defaultTextAttributes: [String: AnyObject]? {
        let attributes = NSMutableDictionary()
        attributes[NSFontAttributeName] = self.font ?? UIFont.systemFontOfSize(18)
        attributes[NSForegroundColorAttributeName] = self.textColor ?? UIColor.blackColor()
        let paragraphStyle = NSMutableParagraphStyle()
        if self.textAlignment != paragraphStyle.alignment {
            paragraphStyle.alignment = self.textAlignment
        }
        if self.lineSpacing != paragraphStyle.lineSpacing {
            paragraphStyle.lineSpacing = self.lineSpacing
        }
        if self.firstLineHeadIndent != paragraphStyle.firstLineHeadIndent {
            paragraphStyle.firstLineHeadIndent = self.firstLineHeadIndent
        }
        attributes[NSParagraphStyleAttributeName] = paragraphStyle.copy()
        if attributes.count > 0 {
            return attributes.copy() as? [String : AnyObject]
        } else {
            return nil;
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
            dispatch_sync(self.textQueue) { () -> Void in
                let range = self.textStorage.entireRange()
                self.content = newValue
                if newValue != nil {
                    self.textStorage.replaceCharactersInRange(range, withString: newValue!)
                    let defaultAttributes = self.defaultTextAttributes
                    if defaultAttributes != nil {
                        self.textStorage.addAttributes(defaultAttributes!, range: self.textStorage.entireRange())
                    }

                    self.needsParse = true
                } else {
                    self.textStorage.replaceCharactersInRange(range, withString: "")
                }
                
                self.setNeedsDisplay()
            }
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
            dispatch_sync(self.textQueue) { () -> Void in
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
    }
    
    public var numberOfLines: Int {
        get {
            return self.textContainer.maximumNumberOfLines
        }
        
        set {
            dispatch_sync(self.textQueue) { () -> Void in
                self.textContainer.maximumNumberOfLines = newValue
                self.layoutManager.textContainerChangedGeometry(self.textContainer)
                self.setNeedsDisplay()
            }
        }
    }
    
    internal var textContainer = NSTextContainer()
    public var textContainerInset = UIEdgeInsetsZero{
        didSet {
            dispatch_sync(self.textQueue) { () -> Void in
                self.textContainer.size = UIEdgeInsetsInsetRect(self.bounds, self.textContainerInset).size
                self.layoutManager.textContainerChangedGeometry(self.textContainer)
                self.setNeedsDisplay()
            }
        }
    }
    
    /** The exclusionPaths for internal textContainer, so the exclusionPaths should be relatived to the text container's origin
     */
    public var exclusionPaths: [UIBezierPath] {
        get {
            return self.textContainer.exclusionPaths
        }
        
        set {
            dispatch_sync(self.textQueue) { () -> Void in
                self.textContainer.exclusionPaths = self.exclusionPaths
                self.setNeedsDisplay()
            }
        }
    }
    
    internal var layoutManager = NSLayoutManager()
    internal var textStorage = NSTextStorage()
    
    public var parser: SwiftyTextParser? {
        didSet {
            self.needsParse = true
            self.setNeedsDisplay()
        }
    }
    internal var needsParse: Bool = false
    
    internal var asyncTextLayer: CALayer?
    internal var textQueue = dispatch_queue_create("com.geeklu.swiftylabel-text", DISPATCH_QUEUE_SERIAL)
    public var drawsTextAsynchronously: Bool = false {
        didSet {
            if drawsTextAsynchronously {
                if self.asyncTextLayer == nil {
                    self.asyncTextLayer = CALayer()
                    self.asyncTextLayer?.frame = self.layer.bounds
                }
                self.layer.addSublayer(self.asyncTextLayer!)
            } else {
                if self.asyncTextLayer != nil {
                    self.asyncTextLayer!.removeFromSuperlayer()
                    self.asyncTextLayer = nil
                }
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
    
    public var singleTapRecognizer = SwiftyLabelTapRecognizer()
    public var longPressRecognizer = SwiftyLabelLongPressRecognizer()
    
    public var delegate: SwiftyLabelDelegate?
    
    // MARK:- Init
    
    func commonInit() {
        self.textContainer.size = frame.size
        self.textContainer.lineFragmentPadding = 0.0
        self.layoutManager.addTextContainer(self.textContainer)
        self.textStorage.addLayoutManager(self.layoutManager)
        
        self.contentMode = .Redraw
        self.layoutManager.delegate = self
        
        self.singleTapRecognizer.numberOfTapsRequired = 1
        self.singleTapRecognizer.cancelsTouchesInView = false
        self.singleTapRecognizer.delegate = self
        self.singleTapRecognizer.addTarget(self, action: "handleSingleTap:")
        self.addGestureRecognizer(self.singleTapRecognizer)

        self.longPressRecognizer.cancelsTouchesInView = false
        self.longPressRecognizer.delegate = self
        self.longPressRecognizer.addTarget(self, action: "handleLongPress:")
        self.addGestureRecognizer(self.longPressRecognizer)
        
        self.singleTapRecognizer.requireGestureRecognizerToFail(self.longPressRecognizer)
        
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "voiceOverStatusChanged", name: UIAccessibilityVoiceOverStatusChanged, object: nil)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
        self.backgroundColor = UIColor.whiteColor()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIAccessibilityVoiceOverStatusChanged, object: nil)
    }
    
    // MARK:- storage 
    
    public func setLink(link: SwiftyTextLink?, range: NSRange) {
        dispatch_sync(self.textQueue) { () -> Void in
           self.textStorage.setLink(link, range: range)
        }
    }
    
    public func insertAttachment(attachment: SwiftyTextAttachment, atIndex loc: Int) {
        dispatch_sync(self.textQueue) { () -> Void in
           self.textStorage.insertAttachment(attachment, atIndex: loc)
        }
    }
    /**
     Returns the link attribute at a given position, and by reference the range and the glyph rects of the link.
     
     - parameter location: is relative to SwiftyLabel's bounds origin
     - parameter range: If non-NULL, upon return contains the range of the link returened
     - parameter rects: If non-NULL, upon return contains all the glyph rects of the link
     - returns: The link at location if existed, otherwise nil
     */
    public func linkAtLocation(location: CGPoint, effectiveRange range: NSRangePointer, effectiveGlyphRects rects: UnsafeMutablePointer<[CGRect]>) -> SwiftyTextLink? {
        
        guard self.textStorage.length > 0 else {
            return nil
        }
        
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
        if gestureRecognizer == self.singleTapRecognizer || gestureRecognizer == self.longPressRecognizer {
            let link = touchInfo.link
            if link != nil {
                if (link!.gestures.contains(.Tap) && gestureRecognizer == self.singleTapRecognizer) || (link!.gestures.contains(.LongPress) && gestureRecognizer == self.longPressRecognizer) {
                    return true
                }
            }
            return false
        } else {
            return true
        }
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view == self {
            //TODO:减少次数
            self.touchInfo.configWithTouch(touch)
            if self.touchInfo.link != nil {
                return true
            } else {
                return false
            }
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
            }
        }
    }
    
    internal func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == .Ended {
            if let link = touchInfo.link {
                self.delegate?.swiftyLabel(self, didLongPressWithTextLink: link, range: touchInfo.linkRange!)
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
            dispatch_async(self.textQueue, {
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
                    
                    self.updateAccessibleElements()
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
            
            self.updateAccessibleElements()
        }
    }
    
    
    // MARK:- Size & Layout
    
    /// https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/TextLayout/Tasks/StringHeight.html
    public func proposedSizeWithConstrainedSize(constrainedSize: CGSize) -> CGSize {
        let constrainedSizeWithInsets = constrainedSize.insetsWith(self.textContainerInset)
        
        self.textContainer.size = constrainedSizeWithInsets
        self.layoutManager.glyphRangeForTextContainer(self.textContainer)
        var proposedSize = self.layoutManager.usedRectForTextContainer(self.textContainer).size
        proposedSize.width = ceil(proposedSize.width)
        proposedSize.height = ceil(proposedSize.height)
        proposedSize.width += (self.textContainerInset.left + self.textContainerInset.right)
        proposedSize.height += (self.textContainerInset.top + self.textContainerInset.bottom)
        return proposedSize;
    }
    
    public override func sizeThatFits(size: CGSize) -> CGSize {
        var constrainedSize = size
        constrainedSize.height = CGFloat.max
        return self.proposedSizeWithConstrainedSize(constrainedSize)
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
            for attachement in self.textStorage.viewAttachments() {
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
    
    
    // MARK:- Accessibility
    
    internal func updateAccessibleElements() {
        guard UIAccessibilityIsVoiceOverRunning() else {
            self.accessibilityElements = nil
            return
        }
        
        self.isAccessibilityElement = false
        var elements = [AnyObject]()
        
        
        // Text element itself
        let textElement = UIAccessibilityElement(accessibilityContainer: self)
        textElement.accessibilityValue = self.text
        textElement.accessibilityTraits = UIAccessibilityTraitStaticText
        textElement.accessibilityFrame = UIAccessibilityConvertFrameToScreenCoordinates(self.bounds,self)
        
        let languageID = NSBundle.mainBundle().preferredLocalizations.first
        if languageID == "zh_CN" || languageID == "zh_TW" {
            textElement.accessibilityLabel = "当前是一段文本，内含链接，向右以选择链接"
        } else {
            textElement.accessibilityLabel = "This is a text that contains links, slide right to select link"
        }
        elements.append(textElement)
        
        // link element
        self.textStorage.enumerateAttribute(SwiftyTextLinkAttributeName, inRange: self.textStorage.entireRange(), options:[]) { (value: AnyObject?, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if value != nil && value is SwiftyTextLink {
                let linkElement = UIAccessibilityElement(accessibilityContainer: self)
                
                let glyphRects = self.layoutManager.glyphRectsWithCharacterRange(range, containerInset: self.textContainerInset)
                var screenRects = [CGRect]()
                if glyphRects != nil {
                    for glyphRect in glyphRects! {
                        screenRects.append(UIAccessibilityConvertFrameToScreenCoordinates(glyphRect, self))
                    }
                    
                    linkElement.accessibilityPath = UIBezierPath.bezierPathWithGlyphRects(screenRects, radius: 0)
                    let firstScreenRect = screenRects[0]
                    let firstCenterPoint = CGPointMake(firstScreenRect.midX, firstScreenRect.midY)
                    linkElement.accessibilityActivationPoint = firstCenterPoint
                    linkElement.accessibilityValue = (self.text! as NSString).substringWithRange(range)
                    linkElement.accessibilityTraits = UIAccessibilityTraitLink
                    elements.append(linkElement)
                }
            }
        }
        
        self.accessibilityElements = elements
    }
    
    internal func voiceOverStatusChanged() {
        self.updateAccessibleElements();
    }
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
}


//Default implementations for SwiftyLabelDelegate
public extension SwiftyLabelDelegate {
    func swiftyLabel(swiftyLabel: SwiftyLabel, didTapWithTextLink link: SwiftyTextLink, range: NSRange){}
    func swiftyLabel(swiftyLabel: SwiftyLabel, didLongPressWithTextLink link:SwiftyTextLink, range: NSRange){}
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
