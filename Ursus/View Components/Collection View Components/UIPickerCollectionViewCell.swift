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
	@IBOutlet weak var pickerButton: UIPickerCollectionViewCellButton!
	@IBOutlet weak var rightTextLabel: UILabel!

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
				self.rightTextLabel?.textColor = StyleKit.lightPrimaryTextColor
			}
			
			self.setNeedsDisplay()
			self.setNeedsLayout()
		}
	}
	
}


class UIPickerCollectionViewCellButton: UrsusButton {
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		self.layer.cornerRadius = 4
	}
}
