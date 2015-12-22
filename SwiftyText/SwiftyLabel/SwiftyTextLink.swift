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
 
 - highlightLayerRadius,highlightLayerColor: When highlight, there can be a mask layer over the link, these two properties can be setted to custom that layer
 
*/
public class SwiftyTextLink: NSObject {
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
