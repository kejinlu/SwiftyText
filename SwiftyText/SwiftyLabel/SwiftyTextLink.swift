//
//  SwiftyTextLink.swift
//  SwiftyText
//
//  Created by Luke on 12/17/15.
//  Copyright © 2015 geeklu.com. All rights reserved.
//

import Foundation

public let SwiftyTextLinkAttributeName: String = "SwiftyTextLink"

/**
  SwiftyTextLink holds link style and identifier infomation.
 
 Some special link identifier has been list as property such as URL, phoneNumber etc..
 You also can use userInfo to identify you link.
 
 **Properties**:
 - attributes: Attributes which will be applied to the target text
 - highlightedAttributes: Attributeds applied to the text when highlighted.
 
 - highlightLayerRadius,highlightLayerColor: When highlight, there can be a mask layer over the link, these two properties can be setted to style that layer
 
*/
public class SwiftyTextLink: NSObject {
    public var gestures: SwiftyTextLinkGesture = [.Tap]
    
    public var attributes: [String: AnyObject]?
    public var highlightedAttributes: [String: AnyObject]?
    
    public var highlightLayerRadius: CGFloat?
    public var highlightLayerColor: UIColor?
    
    public var URL: NSURL?
    public var date: NSDate?
    public var timeZone: NSTimeZone?
    public var phoneNumber: String?
    public var addressComponents: [String : String]?
    
    public var userInfo: [String: AnyObject]?
}


public struct SwiftyTextLinkGesture: OptionSetType {
    public let rawValue: UInt
    public init(rawValue: UInt){ self.rawValue = rawValue}
    
    public static let None = SwiftyTextLinkGesture(rawValue: 0)
    public static let Tap = SwiftyTextLinkGesture(rawValue: 1)
    public static let LongPress = SwiftyTextLinkGesture(rawValue: 1 << 1)
}
