//
//  SettingsCollectionViewCell.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/19/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class SettingsCollectionViewCell: UrsusCollectionViewCell {
	
	@IBOutlet weak var textLabel: UILabel?
	@IBOutlet weak var accessoryView: UIView?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.tintColorDidChange()
	}
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		DispatchQueue.main.async {
			
			if self.tintColor.isDarkColor {
				self.textLabel?.textColor = StyleKit.darkPrimaryTextColor
				self.accessoryView?.tintColor = StyleKit.darkTintColor
			} else {
				self.textLabel?.textColor = StyleKit.lightPrimaryTextColor
				self.accessoryView?.tintColor = StyleKit.lightTintColor
			}
			
			if self.accessoryView != nil {
				
				if self.accessoryView!.isKind(of: UISwitch.self) {
					(self.accessoryView as! UISwitch).onTintColor = self.accessoryView?.tintColor
				}
			}
			
			self.setNeedsDisplay()
		}
	}

}
