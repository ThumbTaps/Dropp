//
//  ShareButton.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 4/30/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ShareButton: DroppButton {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
		super.draw(rect)
		
		StyleKit.drawShareIcon(frame: self.iconRect, resizing: self.resizingBehavior, iconColor: self.iconOnly ? self.tintColor : self.titleColor(for: .normal)!)
    }

}
