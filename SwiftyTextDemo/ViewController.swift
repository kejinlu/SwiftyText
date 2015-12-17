//
//  ViewController.swift
//  SwiftyTextDemo
//
//  Created by Luke on 12/11/15.
//  Copyright © 2015 geeklu.com. All rights reserved.
//

import UIKit
import SwiftyText

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let label = SwiftyLabel(frame: CGRectMake(10, 20, 300, 400))
        label.backgroundColor = UIColor.yellowColor().colorWithAlphaComponent(0.1)
        label.layer.borderColor = UIColor.grayColor().colorWithAlphaComponent(0.4).CGColor
        label.layer.borderWidth = 1.0
        label.text = "Swift is a powerful and intuitive programming language for iOS, OS X, tvOS, and watchOS.  https://developer.apple.com/swift/resources/ . Writing Swift code is interactive and fun, the syntax is concise yet expressive, and apps run lightning-fast. Swift is ready for your next project — or addition into your current app — because Swift code works side-by-side with Objective-C.  "
        label.textContainerInset = UIEdgeInsetsMake(6, 6, 6, 6)
        label.font = UIFont.systemFontOfSize(14)
        label.textColor = UIColor.blackColor()
        label.lineBreakMode = .ByTruncatingHead
        
        label.firstLineHeadIndent = 24
        let link = SwiftyTextLink()
        link.URL = NSURL(string: "https://developer.apple.com/swift/")
        link.attributes = [NSForegroundColorAttributeName:UIColor(red: 0, green: 122/255.0, blue: 1.0, alpha: 1.0),NSUnderlineStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue]
        label.textStorage.setLink(link, range: NSMakeRange(0, 5))
        
        
        label.drawsTextAsynchronously = true
        
        
        let vv = UIView(frame: CGRectMake(0, 0, 40, 40))
        vv.backgroundColor = UIColor.redColor()
        
        let imageAttachment = SwiftyTextAttachment()
        imageAttachment.image = UIImage(named: "logo")
        imageAttachment.attachmentTextVerticalAlignment = .Top
        label.textStorage.insertAttachment(imageAttachment, atIndex: label.textStorage.length)
        
        let sliderAttachment = SwiftyTextAttachment()
        let slider = UISlider()
        sliderAttachment.contentView = slider;
        sliderAttachment.contentViewPadding = 3.0
        sliderAttachment.attachmentTextVerticalAlignment = .Center
        label.textStorage.insertAttachment(sliderAttachment, atIndex: 8)

        let detector = SwiftyTextDetector.detectorWithType([.URL,.Address])
        if detector != nil {
            label.addTextDetector(detector!)
        }
        
        self.view.addSubview(label)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

