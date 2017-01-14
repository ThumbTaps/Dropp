//
//  DownButton.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/13/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class DownButton: UrsusButton {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
		super.draw(rect)
		
		if PreferenceManager.shared.themeMode == .dark {
			StyleKit.drawDownIcon(frame: rect, resizing: .aspectFit, iconColor: StyleKit.darkIconGlyphColor)
		} else {
			StyleKit.drawDownIcon(frame: rect, resizing: .aspectFit, iconColor: StyleKit.lightIconGlyphColor)
		}
    }

}
