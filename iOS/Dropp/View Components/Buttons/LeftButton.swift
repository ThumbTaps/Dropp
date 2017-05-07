//
//  LeftButton.swift
//  Dropp
//
//  Created by Jeffery Jackson on 11/27/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class LeftButton: DroppButton {
	
	// Only override draw() if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
		// Drawing code
		
		super.draw(rect)
		
		StyleKit.drawLeftIcon(frame: self.iconRect, resizing: self.resizingBehavior, iconColor: self.iconOnly ? self.tintColor : self.titleColor(for: .normal)!)
	}
	
}
