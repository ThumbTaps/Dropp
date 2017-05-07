//
//  FrostedBackdrop.swift
//  Dropp
//
//  Created by Jeffery Jackson on 11/16/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class DroppBackdrop: UIView {
	
	// Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
		// Drawing code
				
		self.layer.backgroundColor = UIColor.blue.cgColor
		ThemeKit.drawBackdrop(frame: CGRect(x: 0, y: rect.height - rect.width, width: rect.width, height: rect.width), resizing: .aspectFit)
	}
	
}
