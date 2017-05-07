//
//  FooterCollectionReusableView.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 1/10/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class FooterCollectionReusableView: UICollectionReusableView {
	
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
