//
//  ThemeModeCollectionViewCell.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/15/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class ThemeModeCollectionViewCell: UrsusCollectionViewCell, UIGestureRecognizerDelegate {
	
	@IBOutlet weak var autoOption: SettingsThemeModeOption!
	@IBOutlet weak var lightOption: SettingsThemeModeOption!
	@IBOutlet weak var darkOption: SettingsThemeModeOption!
	
	var tapGestureRecognizer: UITapGestureRecognizer!
	
	override func awakeFromNib() {
		super.awakeFromNib()

		self.lightOption?.themeMode = .light
		self.darkOption?.themeMode = .dark
		
		self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognized))
		self.addGestureRecognizer(self.tapGestureRecognizer)
		self.tapGestureRecognizer.delegate = self
		self.tapGestureRecognizer.numberOfTapsRequired = 1
		self.tapGestureRecognizer.numberOfTouchesRequired = 1
	}
	
	func tapRecognized() {
		let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
		if self.autoOption.frame.contains(self.tapGestureRecognizer.location(in: self)) {
			self.autoOption.selected = true
			self.lightOption.selected = false
			self.darkOption.selected = false
			PreferenceManager.shared.autoThemeMode = true
		} else if self.lightOption.frame.contains(self.tapGestureRecognizer.location(in: self)) {
			self.autoOption.selected = false
			self.lightOption.selected = true
			self.darkOption.selected = false
			PreferenceManager.shared.autoThemeMode = false
			PreferenceManager.shared.themeMode = .light
		} else if self.darkOption.frame.contains(self.tapGestureRecognizer.location(in: self)) {
			self.autoOption.selected = false
			self.lightOption.selected = false
			self.darkOption.selected = true
			PreferenceManager.shared.autoThemeMode = false
			PreferenceManager.shared.themeMode = .dark
		}
		
		feedbackGenerator.impactOccurred()
	}
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}


@IBDesignable
class SettingsThemeModeOption: UIView {
	
	var themeMode: ThemeMode?
	
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var selectedOverlay: UIView!
	@IBInspectable var selected: Bool = false {
		didSet {
			if self.selected {
				UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
					self.selectedOverlay.transform = CGAffineTransform(scaleX: 1, y: 1)
					self.selectedOverlay.alpha = 1
				})
			} else {
				UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
					self.selectedOverlay.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
					self.selectedOverlay.alpha = 0
				})
			}
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		Notification.Name.UrsusThemeDidChange.add(self, selector: #selector(self.themeDidChange))
		self.themeModeDeterminerDidChange()
		Notification.Name.UrsusThemeModeDeterminerDidChange.add(self, selector: #selector(self.themeModeDeterminerDidChange))
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		Notification.Name.UrsusThemeDidChange.add(self, selector: #selector(self.themeDidChange))
		self.themeModeDeterminerDidChange()
		Notification.Name.UrsusThemeModeDeterminerDidChange.add(self, selector: #selector(self.themeModeDeterminerDidChange))
	}
	
	func themeModeDeterminerDidChange() {
		
		if PreferenceManager.shared.themeModeDeterminer == .displayBrightness {
			// start monitoring brightness
			Notification.Name.UIScreenBrightnessDidChange.add(self, selector: #selector(self.themeDidChange))
		} else if PreferenceManager.shared.themeModeDeterminer == .twilight {
			// TODO: Set trigger for sunset or sunrise time?
		}
	}
	func themeDidChange() {
		
		if self.themeMode == .dark {
			self.label.backgroundColor = StyleKit.darkBackdropOverlayColor
			self.label.textColor = StyleKit.darkPrimaryTextColor
		} else if self.themeMode == .light {
			self.label.backgroundColor = StyleKit.lightBackdropOverlayColor
			self.label.textColor = StyleKit.lightPrimaryTextColor
		} else {
			if PreferenceManager.shared.determineThemeMode() == .dark {
				self.label.backgroundColor = StyleKit.darkBackdropOverlayColor
				self.label.textColor = StyleKit.darkPrimaryTextColor
			} else {
				self.label.backgroundColor = StyleKit.lightBackdropOverlayColor
				self.label.textColor = StyleKit.lightPrimaryTextColor
			}
		}

		self.setNeedsDisplay()
	}
	override func awakeFromNib() {
		super.awakeFromNib()
		
		if self.selected {
			self.selectedOverlay.transform = CGAffineTransform(scaleX: 1, y: 1)
			self.selectedOverlay.alpha = 1
		} else {
			self.selectedOverlay.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
			self.selectedOverlay.alpha = 0
		}
		
		self.themeDidChange()
	}
	
	// Only override draw() if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
		// Drawing code
		
		self.layer.masksToBounds = true
		self.layer.cornerRadius = rect.height / 15
		self.layer.borderWidth = 1
		
		if self.themeMode == .dark {
			StyleKit.drawDarkBackdrop(frame: rect, resizing: .aspectFit)
			self.layer.backgroundColor = StyleKit.darkBackgroundColor.cgColor
			self.layer.borderColor = StyleKit.darkStrokeColor.cgColor
		} else if self.themeMode == .light {
			StyleKit.drawLightBackdrop(frame: rect, resizing: .aspectFit)
			self.layer.backgroundColor = StyleKit.lightBackgroundColor.cgColor
			self.layer.borderColor = StyleKit.lightStrokeColor.cgColor
		} else {
			if PreferenceManager.shared.determineThemeMode() == .dark {
				StyleKit.drawDarkBackdrop(frame: rect, resizing: .aspectFit)
				self.layer.backgroundColor = StyleKit.darkBackgroundColor.cgColor
				self.layer.borderColor = StyleKit.darkStrokeColor.cgColor
			} else {
				StyleKit.drawLightBackdrop(frame: rect, resizing: .aspectFit)
				self.layer.backgroundColor = StyleKit.lightBackgroundColor.cgColor
				self.layer.borderColor = StyleKit.lightStrokeColor.cgColor
			}
		}
		
	}
	
	
}


@IBDesignable
class SettingsThemeModeOptionSelectedOverlay: UIView {
	
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
		if PreferenceManager.shared.themeMode == .dark {
			self.tintColor = StyleKit.darkBackdropOverlayColor
		} else {
			self.tintColor = StyleKit.lightBackdropOverlayColor
		}
	}
	override func tintColorDidChange() {
		super.tintColorDidChange()
		self.setNeedsDisplay()
	}
	
	override func draw(_ rect: CGRect) {
		
		self.layer.cornerRadius = rect.height / 15
		
		if self.tintColor.isDarkColor {
			StyleKit.drawCheckmarkIcon(frame: rect, resizing: .aspectFit, iconColor: StyleKit.darkTintColor)
		} else {
			StyleKit.drawCheckmarkIcon(frame: rect, resizing: .aspectFit, iconColor: StyleKit.lightTintColor)
		}
		self.layer.backgroundColor = self.tintColor.cgColor
	}
}
