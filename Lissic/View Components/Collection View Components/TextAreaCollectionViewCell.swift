//
//  TextAreaCollectionViewCell.swift
//  Lissic
//
//  Created by Jeffery Jackson, Jr. on 2/12/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class TextAreaCollectionViewCell: LissicCollectionViewCell {
	
	@IBOutlet weak var textView: UITextView!
	@IBOutlet weak var expandButton: DownButton?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.tintColorDidChange()
	}
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		if self.tintColor.isDarkColor {
			self.textView?.textColor = StyleKit.darkPrimaryTextColor
		} else {
			self.textView?.textColor = StyleKit.lightPrimaryTextColor
		}
		self.setNeedsDisplay()
	}

}
