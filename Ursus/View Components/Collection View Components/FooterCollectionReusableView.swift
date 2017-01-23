//
//  FooterCollectionReusableView.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/10/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class FooterCollectionReusableView: UICollectionReusableView {
	
	@IBInspectable var changesWithTheme: Bool = true {
		didSet {
			if self.changesWithTheme {
				Notification.Name.UrsusThemeDidChange.add(self, selector: #selector(self.themeDidChange))
			} else {
				Notification.Name.UrsusThemeDidChange.remove(self)
			}
		}
	}
	
	@IBOutlet weak var textLabel: UILabel!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		if self.changesWithTheme {
			
			self.themeDidChange()
			Notification.Name.UrsusThemeDidChange.add(self, selector: #selector(self.themeDidChange))
		} else {
			self.tintColorDidChange()
		}
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		if self.changesWithTheme {
			
			self.themeDidChange()
			Notification.Name.UrsusThemeDidChange.add(self, selector: #selector(self.themeDidChange))
		} else {
			self.tintColorDidChange()
		}
	}
	func themeDidChange() {
		
		if PreferenceManager.shared.theme == .dark {
			self.tintColor = StyleKit.darkBackdropOverlayColor
		} else {
			self.tintColor = StyleKit.lightBackdropOverlayColor
		}
	}
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		DispatchQueue.main.async {
			
			if self.tintColor.isDarkColor {
				
				self.textLabel?.textColor = StyleKit.darkTertiaryTextColor
			} else {
				
				self.textLabel?.textColor = StyleKit.lightTertiaryTextColor
			}
			self.setNeedsDisplay()
		}
	}
	override func draw(_ rect: CGRect) {
		
		self.layer.backgroundColor = UIColor.clear.cgColor
		
	}

}
