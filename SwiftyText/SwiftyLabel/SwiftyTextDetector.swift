//
//  SwiftyTextDataDetector.swift
//  SwiftyText
//
//  Created by Luke on 12/3/15.
//  Copyright © 2015 geeklu.com. All rights reserved.
//

import Foundation

public class SwiftyTextDetector: NSObject {
    public var name:String
    public var regularExpression: NSRegularExpression
    public var attributes: [String : AnyObject]?
    public var highlightedAttributes: [String : AnyObject]?

    public var replacementAttributedText:((checkingResult: NSTextCheckingResult, matchedAttributedText: NSAttributedString, sourceAttributedText: NSAttributedString) -> NSAttributedString?)?
    
    /// touch attributes
    public var linkable: Bool = false
    public var touchMaskRadius: CGFloat?
    public var touchMaskColor: UIColor?
    
    public init(name:String, regularExpression: NSRegularExpression, attributes: [String : AnyObject]?) {
        self.name = name
        self.regularExpression = regularExpression
        self.attributes = attributes
        
        super.init()
    }
    
    
}