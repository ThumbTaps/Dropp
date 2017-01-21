//
//  BackButton.swift
//  Ursus
//
//  Created by Jeffery Jackson on 11/27/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class BackButton: UrsusButton {
	
    var destinationIcon: UIView?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
		
		if !self.glyphOnly && self.changesWithTheme {
			if PreferenceManager.shared.theme == .dark {
				
				StyleKit.drawLeftIcon(frame: CGRect(x: 0, y: 0, width: rect.width * 0.43, height: rect.height), resizing: .aspectFit, iconColor: StyleKit.darkIconGlyphColor)
				StyleKit.drawSearchIcon(frame: CGRect(x: rect.width * 0.43, y: 0, width: rect.width * 0.57, height: rect.height), resizing: .aspectFit, iconColor: StyleKit.darkIconGlyphColor)
			} else {
				
				StyleKit.drawLeftIcon(frame: CGRect(x: 0, y: 0, width: rect.width * 0.43, height: rect.height), resizing: .aspectFit, iconColor: StyleKit.lightIconGlyphColor)
				StyleKit.drawSearchIcon(frame: CGRect(x: rect.width * 0.43, y: 0, width: rect.width * 0.57, height: rect.height), resizing: .aspectFit, iconColor: StyleKit.lightIconGlyphColor)
			}
		} else {
			
			StyleKit.drawLeftIcon(frame: CGRect(x: 0, y: 0, width: rect.width * 0.43, height: rect.height), resizing: .aspectFit, iconColor: self.tintColor)
			StyleKit.drawSearchIcon(frame: CGRect(x: rect.width * 0.43, y: 0, width: rect.width * 0.57, height: rect.height), resizing: .aspectFit, iconColor: self.tintColor)
		}

    }
}
