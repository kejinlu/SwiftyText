//
//  ListViewController.swift
//  SwiftyText
//
//  Created by Luke on 1/5/16.
//  Copyright © 2016 geeklu.com. All rights reserved.
//

import Foundation
import SwiftyText

class ListViewController: UITableViewController, SwiftyLabelDelegate {
    var attributedTexts = [NSAttributedString]()
    override func viewDidLoad() {
        self.tableView.allowsSelection = false
        self.tableView.contentInset = UIEdgeInsetsMake(20.0, 0.0, 0.0, 0.0)
        var i = 0
        while i < 75 {
            let a = NSMutableAttributedString(string: "Writing Swift code is interactive and fun, the syntax is concise yet expressive, and apps run lightning-fast. Swift is ready for your next project — or addition into your current app — because Swift code works side-by-side with Objective-C.")
            let link = SwiftyTextLink()
            link.attributes = [NSForegroundColorAttributeName:UIColor(red: 0, green: 122/255.0, blue: 1.0, alpha: 1.0),NSUnderlineStyleAttributeName:NSUnderlineStyle.StyleSingle.rawValue]
            link.URL = NSURL(string: "https://developer.apple.com/swift/")
            a.setLink(link, range: NSMakeRange(8, 5))
            
            let imageAttachment = SwiftyTextAttachment()
            imageAttachment.image = UIImage(named: "swift")
            imageAttachment.padding = 10.0
            imageAttachment.imageSize = CGSizeMake(40, 40)
            imageAttachment.attachmentTextVerticalAlignment = .Center
            a.insertAttachment(imageAttachment, atIndex: a.length - 9)
            
            self.attributedTexts.append(a)
            i += 1
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.attributedTexts.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "SwiftyTextCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as! SwiftyLabelCell
        let attributedText = self.attributedTexts[indexPath.row]
        cell.swiftyLabel.drawsTextAsynchronously = true
        cell.swiftyLabel.attributedText = attributedText
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let attributedText = self.attributedTexts[indexPath.row]
        let size = attributedText.proposedSizeWithConstrainedSize(CGSize(width: self.tableView.bounds.width, height: CGFloat.max), exclusionPaths: nil, lineBreakMode: nil, maximumNumberOfLines: nil)
        return size.height
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
    }
}