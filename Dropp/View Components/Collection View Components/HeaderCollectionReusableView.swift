//
//  HeaderCollectionReusableView.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 1/13/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
	
	@IBOutlet weak var textLabel: UILabel!
	@IBInspectable var strokeColor: UIColor = ThemeKit.strokeColor {
		didSet {
			self.setNeedsDisplay()
		}
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
