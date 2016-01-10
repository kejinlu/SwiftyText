//
//  ViewController.swift
//  SwiftyTextDemo
//
//  Created by Luke on 12/11/15.
//  Copyright © 2015 geeklu.com. All rights reserved.
//

import UIKit
import SwiftyText

class BasicViewController: UIViewController, SwiftyLabelDelegate {

    @IBOutlet weak var label: SwiftyLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1)
        
        label.delegate = self
        label.backgroundColor = UIColor(red: 243/255.0, green: 1, blue: 236/255.0, alpha: 1)
        label.text = "Swift is a powerful and intuitive programming language for iOS, OS X, tvOS, and watchOS.  https://developer.apple.com/swift/resources/ . Writing Swift code is interactive and fun, the syntax is concise yet expressive, and apps run lightning-fast. Swift is ready for your next project — or addition into your current app — because Swift code works side-by-side with Objective-C.  "
        label.textContainerInset = UIEdgeInsetsMake(6, 6, 6, 6)
        label.font = UIFont.systemFontOfSize(14)
        label.textColor = UIColor.blackColor()
        label.firstLineHeadIndent = 24
        label.drawsTextAsynchronously = true        

        let link = SwiftyTextLink()
        link.URL = NSURL(string: "https://developer.apple.com/swift/")
        link.attributes = [NSForegroundColorAttributeName:UIColor(red: 0, green: 122/255.0, blue: 1.0, alpha: 1.0),NSUnderlineStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue]
        label.setLink(link, range: NSMakeRange(0, 5))
        
        let imageAttachment = SwiftyTextAttachment()
        imageAttachment.image = UIImage(named: "swift")
        imageAttachment.attachmentTextVerticalAlignment = .Center
        imageAttachment.padding = 10.0
        label.insertAttachment(imageAttachment, atIndex: label.attributedText!.length - 9)
        
        let sliderAttachment = SwiftyTextAttachment()
        let slider = UISlider()
        sliderAttachment.contentView = slider;
        sliderAttachment.padding = 3.0
        sliderAttachment.attachmentTextVerticalAlignment = .Center
        label.insertAttachment(sliderAttachment, atIndex: 8)

        let detector = SwiftyTextDetector.detectorWithType([.URL,.Address])
        detector!.linkGestures = [.Tap, .LongPress]
        if detector != nil {
            label.parser = detector
        }
        label.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK:- SwiftyLabelDelegate
    func swiftyLabel(swiftyLabel: SwiftyLabel, didTapWithTextLink link: SwiftyTextLink, range: NSRange){
        if let URL = link.URL {
            let sheet = UIAlertController(title: "Link", message: URL.absoluteString , preferredStyle: .ActionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) -> Void in
                self.dismissViewControllerAnimated(true, completion: nil)
            })
            sheet.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open in Safari", style: .Default, handler: { (action) -> Void in
                UIApplication.sharedApplication().openURL(URL)
            })
            sheet.addAction(openAction)
            
            self.presentViewController(sheet, animated: true, completion: nil)
        }
    }
    
    func swiftyLabel(swiftyLabel: SwiftyLabel, didLongPressWithTextLink link:SwiftyTextLink, range: NSRange){
        
    }
    
    func swiftyLabelShoudTouch(swiftyLabel: SwiftyLabel) -> Bool {
        return true
    }
}

