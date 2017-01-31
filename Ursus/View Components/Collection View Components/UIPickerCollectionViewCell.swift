//
//  UIPickerCollectionViewCell.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/22/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class UIPickerCollectionViewCell: UrsusCollectionViewCell {
	
	@IBOutlet weak var leftTextLabel: UILabel!
	@IBOutlet weak var pickerButton: UrsusButton!
	@IBOutlet weak var rightTextLabel: UILabel!

	override func layoutSubviews() {
		super.layoutSubviews()
		self.pickerButton?.layer.cornerRadius = 6
	}
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.tintColorDidChange()
	}
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		DispatchQueue.main.async {
			
			if self.tintColor.isDarkColor {
				self.leftTextLabel?.textColor = StyleKit.darkPrimaryTextColor
				self.rightTextLabel?.textColor = StyleKit.darkPrimaryTextColor
			} else {
				self.leftTextLabel?.textColor = StyleKit.lightPrimaryTextColor
				self.rightTextLabel?.tintColor = StyleKit.lightPrimaryTextColor
			}
			
			self.setNeedsDisplay()
		}
	}
	
}
