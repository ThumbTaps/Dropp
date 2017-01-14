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
		
		if PreferenceManager.shared.themeMode == .dark {
            self.layer.backgroundColor = UIColor(white: 0.05, alpha: 0.7).cgColor
			StyleKit.drawSearchIcon(frame: rect, resizing: .aspectFit, iconColor: self.tintColor.withAlpha(0.2))
		} else {
			self.layer.backgroundColor = UIColor(white: 0.95, alpha: 0.45).cgColor
			StyleKit.drawSearchIcon(frame: rect, resizing: .aspectFit, iconColor: self.tintColor.withAlpha(0.25))
		}

    }

}
