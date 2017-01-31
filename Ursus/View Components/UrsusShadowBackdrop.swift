//
//  UrsusShadowBackdrop.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/18/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class UrsusShadowBackdrop: UIView {
	
	@IBInspectable var changesWithTheme: Bool = true
	var offset: CGSize = CGSize(width: 0, height: 0)
	var radius: CGFloat = 10
	
	convenience init(frame: CGRect, offset: CGSize, radius: CGFloat) {
		self.init(frame: frame)
		
		self.offset = offset
		self.radius = radius
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.backgroundColor = UIColor.clear
		if self.changesWithTheme {
			PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		self.backgroundColor = UIColor.clear
		if self.changesWithTheme {
			PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
		}
	}
	
	func themeDidChange() {
		
		self.setNeedsDisplay()
	}

	// Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code

		self.layer.shadowPath = CGPath(roundedRect: rect, cornerWidth: 0, cornerHeight: 0, transform: nil)
		self.layer.shadowColor = UIColor.black.cgColor
		self.layer.shadowOffset = self.offset
		self.layer.shadowRadius = self.radius
		self.layer.borderWidth = 1
		
		if PreferenceManager.shared.theme == .dark {
			self.layer.borderColor = StyleKit.darkStrokeColor.cgColor
			self.layer.shadowOpacity = 0.75
		} else {
			self.layer.borderColor = StyleKit.lightStrokeColor.cgColor
			self.layer.shadowOpacity = 0.3
		}

    }

}
