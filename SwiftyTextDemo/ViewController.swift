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
        label.text = "https://en.wikipedia.org/wiki/Dream_of_the_Red_Chamber 原来女娲氏炼石补天之时，于大荒山无稽崖练成高经十二丈，方经二十四丈顽石三万六千五百零一块．娲皇氏只用了三万六千五百块，只单单剩了一块未用，便弃在此山青埂峰下．谁知此石自经煅炼之后，灵性已通，因见众石俱得补天，独自己无材不堪入选，遂自怨自叹，日夜悲号惭愧"
        label.textContainerInset = UIEdgeInsetsMake(20, 20, 20, 20)
        label.font = UIFont.systemFontOfSize(20)
        label.textColor = UIColor.blackColor()
        label.lineBreakMode = .ByTruncatingHead
        //label.numberOfLines = 4
        label.firstLineHeadIndent = 24
        let link = SwiftyTextLink()
        label.textStorage.addAttribute(SwiftyTextLinkAttributeName, value: link, range: NSMakeRange(0, 2))
        
        
        label.drawsTextAsynchronously = true
        
        
        let vv = UIView(frame: CGRectMake(0, 0, 40, 40))
        vv.backgroundColor = UIColor.redColor()
        
        let attachment = SwiftyTextAttachment()
        attachment.image = UIImage(named: "test")
        attachment.attachmentTextVerticalAlignment = .Bottom
        
        
        label.textStorage.insertAttachment(attachment, atIndex: 0)
        
        let attachment1 = SwiftyTextAttachment()
        attachment1.image = UIImage(named: "test")
        attachment1.attachmentTextVerticalAlignment = .Top
        
        label.textStorage.insertAttachment(attachment, atIndex: 2)
        
        do {
            let d = SwiftyTextDetector(name: "Link", regularExpression: try NSDataDetector(types: NSTextCheckingType.Link.rawValue), attributes: [NSForegroundColorAttributeName: UIColor.blueColor()])
            d.highlightedAttributes = [NSForegroundColorAttributeName: UIColor.redColor()]
            d.touchMaskColor = UIColor.yellowColor().colorWithAlphaComponent(0.4)
            d.touchable = true
            label.addTextDetector(d)
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

