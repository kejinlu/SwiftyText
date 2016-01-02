//
//  SwiftyTextParser.swift
//  SwiftyText
//
//  Created by Luke on 12/23/15.
//  Copyright © 2015 geeklu.com. All rights reserved.
//

import Foundation

public protocol SwiftyTextParser {
    func parseText(attributedText: NSMutableAttributedString)
}

public class SwiftyTextSuperParser: NSObject, SwiftyTextParser {
    
    public init(parsers: [SwiftyTextParser]) {
        self.subParsers = parsers
        super.init()
    }
    
    public var subParsers: [SwiftyTextParser]?
    
    public func parseText(attributedText: NSMutableAttributedString) {
        if subParsers != nil {
            for subParser in self.subParsers! {
                subParser.parseText(attributedText)
            }
        }
    }
}