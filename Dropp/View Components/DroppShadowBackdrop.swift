//
//  DroppShadowBackdrop.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 1/18/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class DroppShadowBackdrop: UIView {
	
	@IBInspectable var offset: CGSize = CGSize(width: 0, height: 0)
	@IBInspectable var radius: CGFloat = 10
	@IBInspectable var opacity: CGFloat = 0.15
	
	convenience init(frame: CGRect, offset: CGSize, radius: CGFloat) {
		self.init(frame: frame)
		
		self.offset = offset
		self.radius = radius
	}
	
	// Only override draw() if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
		// Drawing code
		
		self.layer.cornerRadius = 12
		self.layer.shadowPath = CGPath(roundedRect: rect, cornerWidth: 0, cornerHeight: 0, transform: nil)
		self.layer.shadowColor = UIColor.black.cgColor
		self.layer.shadowOffset = self.offset
		self.layer.shadowRadius = self.radius
		self.layer.borderWidth = 1
		self.layer.borderColor = UIColor.black.withAlpha(self.opacity).cgColor
		self.layer.shadowOpacity = Float(self.opacity)
		
	}
	
}
