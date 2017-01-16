//
//  CountIndicator.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/14/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class UrsusCountIndicator: UrsusButton {
		
	override func themeDidChange() {
		super.themeDidChange()
		
		if PreferenceManager.shared.themeMode == .dark {
			self.tintColor = StyleKit.darkTertiaryTextColor
		} else {
			self.tintColor = StyleKit.lightTertiaryTextColor
		}
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		self.layer.backgroundColor = self.tintColor.cgColor
	}

}
