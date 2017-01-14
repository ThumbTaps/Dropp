//
//  FooterCollectionReusableView.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/10/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class FooterCollectionReusableView: UICollectionReusableView {
	
	@IBOutlet weak var textLabel: UILabel!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.themeDidChange()
		Notification.Name.UrsusThemeDidChange.add(self, selector: #selector(self.themeDidChange))
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.themeDidChange()
		Notification.Name.UrsusThemeDidChange.add(self, selector: #selector(self.themeDidChange))
	}
	func themeDidChange() {
		self.setNeedsDisplay()
		
		if PreferenceManager.shared.themeMode == .dark {
			self.textLabel?.textColor = StyleKit.darkTertiaryTextColor
		} else {
			self.textLabel?.textColor = StyleKit.lightTertiaryTextColor
		}
	}
	override func draw(_ rect: CGRect) {
		
		if PreferenceManager.shared.themeMode == .dark {
			self.layer.backgroundColor = StyleKit.darkBackdropOverlayColor.withAlpha(0.2).cgColor
		} else {
			self.layer.backgroundColor = StyleKit.lightBackdropOverlayColor.cgColor
		}
		
	}

}
