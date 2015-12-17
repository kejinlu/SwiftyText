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
        
        let label = SwiftyLabel(frame: CGRectMake(0, 20, 300, 200))
        label.backgroundColor = UIColor.whiteColor()
        label.layer.borderColor = UIColor.blackColor().CGColor
        label.layer.borderWidth = 1
        label.text = "http://baike.baidu.com/subview/61075/13876199.htm Swift 是一种新的编程语言，用于编写 iOS 和 OS X 应用。Swift 结合了 C 和 Objective-C 的优点并且不受C兼容性的限制。Swift 采用安全的编程模式并添加了很多新特性，这将使编程更简单，更灵活，也更有趣。Swift 是基于成熟而且倍受喜爱得 Cocoa 和 Cocoa Touch 框架，他的降临将重新定义软件开发。"
        label.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20)
        label.font = UIFont.systemFontOfSize(14)
        label.textColor = UIColor.blackColor()
        label.lineBreakMode = .ByTruncatingHead
        //label.numberOfLines = 4
        label.firstLineHeadIndent = 24
        let link = SwiftyTextLink()
        label.textStorage.setLink(link, range: NSMakeRange(0, 2))
        
        
        label.drawsTextAsynchronously = true
        
        
        let vv = UIView(frame: CGRectMake(0, 0, 40, 40))
        vv.backgroundColor = UIColor.redColor()
        
        let attachment = SwiftyTextAttachment()
        attachment.image = UIImage(named: "SwiftyText")
        attachment.attachmentTextVerticalAlignment = .Bottom
        
        
        label.textStorage.insertAttachment(attachment, atIndex: 0)
        
        do {
            let d = SwiftyTextDetector(name: "Link", regularExpression: try NSDataDetector(types: NSTextCheckingType.Link.rawValue), attributes: [NSForegroundColorAttributeName: UIColor.blueColor()])
            d.highlightedAttributes = [NSForegroundColorAttributeName: UIColor.redColor()]
            d.touchMaskColor = UIColor.yellowColor().colorWithAlphaComponent(0.4)
            d.linkable = true
            //label.addTextDetector(d)
        }
        catch {
        }
        
        self.view.addSubview(label)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

