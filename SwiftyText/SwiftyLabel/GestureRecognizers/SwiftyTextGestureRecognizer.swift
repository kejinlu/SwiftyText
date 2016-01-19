//
//  SwiftyTextGestureRecognizer.swift
//  SwiftyText
//
//  Created by Luke on 1/19/16.
//  Copyright © 2016 geeklu.com. All rights reserved.
//

import Foundation
import UIKit

class SwiftyTextGestureRecognizer: UIGestureRecognizer {
    var link: SwiftyTextLink?
    var linkRange: NSRange?
    var linkGlyphRects: [CGRect]?
}

