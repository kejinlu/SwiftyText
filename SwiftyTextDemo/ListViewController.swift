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
            self.attributedTexts.append(NSAttributedString(string: "哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈哈"))
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
        cell.swiftyLabel.attributedText = attributedText
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath) as! SwiftyLabelCell
        //let size = cell.swiftyLabel.proposedSizeWithConstrainedSize(CGSizeMake(cell.contentView.bounds.width, CGFloat.max))
        return 60
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
    }
}