//
//  SwiftyLabelCell.swift
//  SwiftyText
//
//  Created by Luke on 1/5/16.
//  Copyright © 2016 geeklu.com. All rights reserved.
//

import Foundation
import UIKit
import SwiftyText

class SwiftyLabelCell: UITableViewCell {
    @IBOutlet weak var swiftyLabel: SwiftyLabel!
    override func prepareForReuse() {
        super.prepareForReuse()
        self.swiftyLabel.drawsTextAsynchronously = true
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.swiftyLabel.frame = self.contentView.bounds
    }
}

