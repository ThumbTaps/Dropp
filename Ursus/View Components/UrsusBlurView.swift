//
//  UrsusBlurView.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/18/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class UrsusBlurView: UIVisualEffectView {
	
	@IBInspectable var changesWithTheme: Bool = true
	
	
	override init(effect: UIVisualEffect?) {
		super.init(effect: effect)
		
		if self.changesWithTheme {
			Notification.Name.UrsusThemeDidChange.add(self, selector: #selector(self.themeDidChange))
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		if self.changesWithTheme {
			Notification.Name.UrsusThemeDidChange.add(self, selector: #selector(self.themeDidChange))
		}
	}
	
	func themeDidChange() {
		
		if PreferenceManager.shared.themeMode == .dark {
			self.effect = UIBlurEffect(style: .dark)
		} else {
			self.effect = UIBlurEffect(style: .light)
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
