//
//  CountIndicator.swift
//  Lissic
//
//  Created by Jeffery Jackson, Jr. on 1/14/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class LissicCountIndicator: LissicButton {
	
	@IBInspectable var tinted: Bool = true {
		didSet {
			self.themeDidChange()
		}
	}
	
	override func themeDidChange() {
		super.themeDidChange()
		
		if PreferenceManager.shared.theme == .dark {
			self.tintColor = self.tinted ? StyleKit.darkTintColor : StyleKit.darkTertiaryTextColor
		} else {
			self.tintColor = self.tinted ? StyleKit.lightTintColor : StyleKit.lightTertiaryTextColor
		}
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		self.layer.backgroundColor = self.tintColor.cgColor
	}

}
