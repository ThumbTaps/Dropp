//
//  CheckmarkButton.swift
//  Lissic
//
//  Created by Jeffery Jackson, Jr. on 1/20/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class CheckmarkButton: LissicButton {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
		
		if !self.glyphOnly && self.changesWithTheme {
			if PreferenceManager.shared.theme == .dark {
				
				StyleKit.drawCheckmarkIcon(frame: rect, resizing: self.resizingBehavior, iconColor: StyleKit.darkIconGlyphColor)
			} else {
				
				StyleKit.drawCheckmarkIcon(frame: rect, resizing: self.resizingBehavior, iconColor: StyleKit.lightIconGlyphColor)
			}
		} else {
			
			StyleKit.drawCheckmarkIcon(frame: rect, resizing: self.resizingBehavior, iconColor: self.tintColor)
		}
    }

}
