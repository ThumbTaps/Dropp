//
//  LissicBlurView.swift
//  Lissic
//
//  Created by Jeffery Jackson, Jr. on 1/18/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class LissicBlurView: UIVisualEffectView {
	
	@IBInspectable var changesWithTheme: Bool = true {
		didSet {
			if self.changesWithTheme {
				PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
				self.themeDidChange()
			} else {
				PreferenceManager.shared.themeDidChangeNotification.remove(self)
			}
		}
	}
	
	override init(effect: UIVisualEffect?) {
		super.init(effect: effect)
		
		if self.changesWithTheme {
			PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
		}
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)

		if self.changesWithTheme {
			PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
		}
	}
	
	func themeDidChange() {
		
		if PreferenceManager.shared.theme == .dark {
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
