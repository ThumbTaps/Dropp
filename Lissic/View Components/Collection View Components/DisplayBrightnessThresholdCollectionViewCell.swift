//
//  DisplayBrightnessThresholdCollectionViewCell.swift
//  Lissic
//
//  Created by Jeffery Jackson, Jr. on 1/20/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class DisplayBrightnessThresholdCollectionViewCell: LissicCollectionViewCell {
	
	@IBOutlet weak var minIcon: DisplayBrightnessMinButton!
	@IBOutlet weak var maxIcon: DisplayBrightnessMaxButton!
	@IBOutlet weak var slider: UISlider!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.tintColorDidChange()
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.tintColorDidChange()
	}
	override func awakeFromNib() {
		super.awakeFromNib()
		self.tintColorDidChange()
	}
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		DispatchQueue.main.async {
			
			if self.tintColor.isDarkColor {
				self.slider?.minimumTrackTintColor = StyleKit.darkTintColor
			} else {
				self.slider?.minimumTrackTintColor = StyleKit.lightTintColor
			}
			self.setNeedsDisplay()
		}
	}
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
