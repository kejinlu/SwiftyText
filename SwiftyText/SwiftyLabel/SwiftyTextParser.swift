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


public class SwiftyTextSuperParser: SwiftyTextParser{
    
    public var subParsers: [SwiftyTextParser]?
    
    public func parseText(text: NSMutableAttributedString) {
        if subParsers != nil {
            for subParser in self.subParsers! {
                subParser.parseText(text)
            }
        }
    }
}