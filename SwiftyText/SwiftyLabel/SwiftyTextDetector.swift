//
//  SwiftyTextDataDetector.swift
//  SwiftyText
//
//  Created by Luke on 12/3/15.
//  Copyright © 2015 geeklu.com. All rights reserved.
//

import Foundation

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

public class SwiftyTextDetector: NSObject {
    public var name:String
    public var regularExpression: NSRegularExpression
    public var attributes: [String : AnyObject]?
    public var highlightedAttributes: [String : AnyObject]?

    public var replacementAttributedText:((checkingResult: NSTextCheckingResult, matchedAttributedText: NSAttributedString, sourceAttributedText: NSAttributedString) -> NSAttributedString?)?
    
    /// touch attributes
    public var linkable: Bool = false
    public var highlightLayerRadius: CGFloat?
    public var highlightLayerColor: UIColor?
    
    public init(name:String, regularExpression: NSRegularExpression, attributes: [String : AnyObject]?) {
        self.name = name
        self.regularExpression = regularExpression
        self.attributes = attributes
        
        super.init()
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