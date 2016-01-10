//
//  SwiftyTextDataDetector.swift
//  SwiftyText
//
//  Created by Luke on 12/3/15.
//  Copyright © 2015 geeklu.com. All rights reserved.
//

import Foundation

internal let SwiftyTextDetectorResultAttributeName: String = "SwiftyTextDetectorResult"

public struct SwiftyTextDetectorType: OptionSetType {
    public let rawValue: UInt
    public init(rawValue: UInt){ self.rawValue = rawValue}
    
    public static let None = SwiftyTextDetectorType(rawValue: 0)
    public static let PhoneNumber = SwiftyTextDetectorType(rawValue: 1)
    public static let URL = SwiftyTextDetectorType(rawValue: 1 << 1)
    public static let Date = SwiftyTextDetectorType(rawValue: 1 << 2)
    public static let Address = SwiftyTextDetectorType(rawValue: 1 << 3)
    public static let All = SwiftyTextDetectorType(rawValue: UInt.max)
}

/**
 SwiftyTextDetector is a special kind of SwiftyTextParser which parse attributed string with regular expression
 */
public class SwiftyTextDetector: NSObject, SwiftyTextParser {
    public var name:String
    public var regularExpression: NSRegularExpression
    public var attributes: [String : AnyObject]?
    public var highlightedAttributes: [String : AnyObject]?

    public var replacementAttributedText:((checkingResult: NSTextCheckingResult, matchedAttributedText: NSAttributedString, sourceAttributedText: NSAttributedString) -> NSAttributedString?)?
    
    /// link attributes
    public var linkable: Bool = false
    public var linkGestures: SwiftyTextLinkGesture = [.Tap]
    
    public var highlightLayerRadius: CGFloat?
    public var highlightLayerColor: UIColor?
    
    public init(name:String, regularExpression: NSRegularExpression, attributes: [String : AnyObject]?) {
        self.name = name
        self.regularExpression = regularExpression
        self.attributes = attributes
        
        super.init()
    }
    
    public func parseText(attributedText: NSMutableAttributedString) {
        let text = attributedText.string
        let checkingResults = self.regularExpression.matchesInString(text, options: NSMatchingOptions(), range: NSMakeRange(0, text.characters.count))
        
        for result in checkingResults.reverse() {
            let checkingRange = result.range
            var resultRange = checkingRange
            
            if checkingRange.location == NSNotFound {
                continue
            }
            
            let detectorResultAttribute = attributedText.attribute(SwiftyTextDetectorResultAttributeName, atIndex: checkingRange.location, longestEffectiveRange: nil, inRange: checkingRange)
            if detectorResultAttribute != nil {
                continue
            }
            
            if let attributes = self.attributes {
                attributedText.addAttributes(attributes, range: checkingRange)
            }
            
            if let replacementFunc = self.replacementAttributedText {
                let replacement = replacementFunc(checkingResult: result, matchedAttributedText: attributedText.attributedSubstringFromRange(checkingRange), sourceAttributedText: attributedText)
                if replacement != nil {
                    attributedText.replaceCharactersInRange(checkingRange, withAttributedString: replacement!)
                    resultRange.length = replacement!.length
                }
            }
            
            if self.linkable {
                let link = SwiftyTextLink()
                link.highlightedAttributes = self.highlightedAttributes
                
                if self.highlightLayerRadius != nil {
                    link.highlightLayerRadius = self.highlightLayerRadius
                }
                if self.highlightLayerColor != nil {
                    link.highlightLayerColor = self.highlightLayerColor
                }
                
                link.gestures = self.linkGestures
                
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
                
                attributedText.addAttribute(SwiftyTextLinkAttributeName, value: link, range: resultRange)
            }
            
            attributedText.addAttribute(SwiftyTextDetectorResultAttributeName, value: self, range: resultRange)
        }

    }

    public class func detectorWithType(type: SwiftyTextDetectorType) ->  SwiftyTextDetector?{
        var checkingTypes = NSTextCheckingType()
        
        if type.contains(.PhoneNumber) {
            checkingTypes = checkingTypes.union(.PhoneNumber)
        }
        if type.contains(.URL) {
            checkingTypes = checkingTypes.union(.Link)
        }
        if type.contains(.Date) {
            checkingTypes = checkingTypes.union(.Date)
        }
        if type.contains(.Address) {
            checkingTypes = checkingTypes.union(.Address)
        }
        do {
            let dataDetector = try NSDataDetector(types: checkingTypes.rawValue)
            let textDetector = SwiftyTextDetector(name: "Link", regularExpression: dataDetector, attributes: [NSForegroundColorAttributeName:UIColor(red: 0, green: 122/255.0, blue: 1.0, alpha: 1.0),NSUnderlineStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue])
            textDetector.linkable = true
            return textDetector
        } catch {
            
        }
        return nil;
    }
}