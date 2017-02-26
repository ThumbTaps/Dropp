//
//  SettingsCollectionViewCell.swift
//  Lissic
//
//  Created by Jeffery Jackson, Jr. on 1/19/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class SettingsCollectionViewCell: LissicCollectionViewCell {
	
	@IBOutlet weak var textLabel: UILabel?
	@IBOutlet weak var accessoryView: UIView?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.tintColorDidChange()
	}
	override func themeDidChange() {
		super.themeDidChange()
		
		DispatchQueue.main.async {
			
			if PreferenceManager.shared.theme == .dark {
				(self.accessoryView as? UISwitch)?.tintColor = StyleKit.darkTintColor
			} else {
				(self.accessoryView as? UISwitch)?.tintColor = StyleKit.lightTintColor
			}
			(self.accessoryView as? UISwitch)?.onTintColor = (self.accessoryView as? UISwitch)?.tintColor
		}
	}
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		DispatchQueue.main.async {
			
			if self.tintColor.isDarkColor {
				self.textLabel?.textColor = StyleKit.darkPrimaryTextColor
			} else {
				self.textLabel?.textColor = StyleKit.lightPrimaryTextColor
			}
			
			self.setNeedsDisplay()
		}
	}

}
