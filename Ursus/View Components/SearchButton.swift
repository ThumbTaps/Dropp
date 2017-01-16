//
//  SearchButton.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/4/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class SearchButton: UrsusButton {

	override func themeDidChange() {
		super.themeDidChange()
		
		if PreferenceManager.shared.themeMode == .dark {
			self.tintColor = StyleKit.darkBackgroundColor
		} else {
			self.tintColor = StyleKit.lightBackgroundColor
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
			StyleKit.drawSearchIcon(frame: rect, resizing: .aspectFit, iconColor: StyleKit.darkPrimaryTextColor.withAlpha(0.2))
		} else {
			if !self.glyphOnly {
				self.layer.backgroundColor = self.tintColor.withAlpha(0.45).cgColor
			} else {
				self.layer.backgroundColor = UIColor.clear.cgColor
			}
			StyleKit.drawSearchIcon(frame: rect, resizing: .aspectFit, iconColor: StyleKit.lightPrimaryTextColor.withAlpha(0.25))
		}

    }

}
