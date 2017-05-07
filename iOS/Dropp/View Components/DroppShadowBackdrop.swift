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
	
	@IBInspectable var offset: CGSize = CGSize(width: 0, height: 0) {
		didSet {
			self.setNeedsDisplay()
		}
	}
	@IBInspectable var radius: CGFloat = 10 {
		didSet {
			self.setNeedsDisplay()
		}
	}
	@IBInspectable var cornerRadius: CGFloat = 0 {
		didSet {
			self.setNeedsDisplay()
		}
	}
	@IBInspectable var shadowColor: UIColor = UIColor.black {
		didSet {
			self.setNeedsDisplay()
		}
	}
	
	convenience init(frame: CGRect, offset: CGSize, radius: CGFloat, cornerRadius: CGFloat, color: UIColor) {
		self.init(frame: frame)
		
		self.offset = offset
		self.radius = radius
		self.cornerRadius = cornerRadius
		self.shadowColor = color
		self.backgroundColor = UIColor.clear
	}
	
	// Only override draw() if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
		// Drawing code
		
		self.layer.backgroundColor = UIColor.clear.cgColor
		self.layer.cornerRadius = self.cornerRadius
		self.layer.shadowPath = CGPath(roundedRect: rect, cornerWidth: 0, cornerHeight: 0, transform: nil)
		self.layer.shadowColor = self.shadowColor.cgColor
		self.layer.shadowOffset = self.offset
		self.layer.shadowRadius = self.radius
		self.layer.shadowOpacity = 1
		
	}
	
}
