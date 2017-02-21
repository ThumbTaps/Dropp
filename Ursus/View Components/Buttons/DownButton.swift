//
//  DownButton.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/13/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class DownButton: UrsusButton {

	override func themeDidChange() {
		super.themeDidChange()
		
		if PreferenceManager.shared.theme == .dark {
			self.tintColor = StyleKit.darkPrimaryTextColor
		} else {
			self.tintColor = StyleKit.lightPrimaryTextColor
		}
	}
	
	// Only override draw() if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
		// Drawing code
		
		super.draw(rect)
		
		if self.tintColor.isDarkColor {
			if !self.glyphOnly {
				self.layer.backgroundColor = self.tintColor.withAlpha(0.7).cgColor
			} else {
				self.layer.backgroundColor = UIColor.clear.cgColor
			}
			StyleKit.drawDownIcon(frame: rect, resizing: self.resizingBehavior, iconColor: self.tintColor)
		} else {
			if !self.glyphOnly {
				self.layer.backgroundColor = self.tintColor.withAlpha(0.45).cgColor
			} else {
				self.layer.backgroundColor = UIColor.clear.cgColor
			}
			StyleKit.drawDownIcon(frame: rect, resizing: self.resizingBehavior, iconColor: self.tintColor)
		}
		
	}

}
