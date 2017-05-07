//
//  DroppCollectionViewCell.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 1/13/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class DroppCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var actionButton: UIButton?
	
	@IBInspectable var strokeColor: UIColor = ThemeKit.strokeColor {
		didSet {
			self.setNeedsDisplay()
		}
	}
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.selectedBackgroundView = UIView(frame: self.bounds)
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.selectedBackgroundView = UIView(frame: self.bounds)
	}
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		self.selectedBackgroundView?.backgroundColor = self.tintColor.withAlpha(0.4)
		self.setNeedsDisplay()
	}
	override func draw(_ rect: CGRect) {
		
		let path = UIBezierPath()
		path.move(to: CGPoint(x: 0, y: rect.height))
		path.addLine(to: CGPoint(x: rect.width, y: rect.height))
		path.close()
		
		self.strokeColor.set()
		
		path.stroke()
	}
}
