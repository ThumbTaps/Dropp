//
//  ThemeModeCollectionViewCell.swift
//  Lissic
//
//  Created by Jeffery Jackson, Jr. on 1/15/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class ThemeModeCollectionViewCell: LissicCollectionViewCell, UIGestureRecognizerDelegate {
	
	@IBOutlet weak var autoOption: SettingsThemeModeOption!
	@IBOutlet weak var lightOption: SettingsThemeModeOption!
	@IBOutlet weak var darkOption: SettingsThemeModeOption!
	
	var delegate: ThemeModeCollectionViewCellDelegate?
	
	var tapGestureRecognizer: UITapGestureRecognizer!
	
	override func awakeFromNib() {
		super.awakeFromNib()

		self.lightOption?.theme = .light
		self.darkOption?.theme = .dark
		
		self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.tapRecognized))
		self.addGestureRecognizer(self.tapGestureRecognizer)
	}
	
	func tapRecognized() {
		let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
		
		var selectedThemeMode: Theme?
		if self.autoOption.frame.contains(self.tapGestureRecognizer.location(in: self)) {
			self.autoOption.selected = true
			self.lightOption.selected = false
			self.darkOption.selected = false
			feedbackGenerator.impactOccurred()
			self.delegate?.didSelectTheme(theme: selectedThemeMode)
		} else if self.lightOption.frame.contains(self.tapGestureRecognizer.location(in: self)) {
			self.autoOption.selected = false
			self.lightOption.selected = true
			self.darkOption.selected = false
			selectedThemeMode = .light
			feedbackGenerator.impactOccurred()
			self.delegate?.didSelectTheme(theme: selectedThemeMode)
		} else if self.darkOption.frame.contains(self.tapGestureRecognizer.location(in: self)) {
			self.autoOption.selected = false
			self.lightOption.selected = false
			self.darkOption.selected = true
			selectedThemeMode = .dark
			feedbackGenerator.impactOccurred()
			self.delegate?.didSelectTheme(theme: selectedThemeMode)
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


protocol ThemeModeCollectionViewCellDelegate {
	func didSelectTheme(theme: Theme?)
}


@IBDesignable
class SettingsThemeModeOption: UIView {
	
	var theme: Theme?
	
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var selectedOverlay: UIView!
	@IBInspectable var selected: Bool = false {
		didSet {
			if self.selected {
				UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
					self.selectedOverlay.transform = CGAffineTransform(scaleX: 1, y: 1)
					self.selectedOverlay.alpha = 1
				})
			} else {
				UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*0.25, delay: 0, options: .curveEaseOut, animations: {
					self.selectedOverlay.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
					self.selectedOverlay.alpha = 0
				})
			}
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
		self.themeDeterminerDidChange()
		PreferenceManager.shared.themeDeterminerDidChangeNotification.add(self, selector: #selector(self.themeDeterminerDidChange))
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
		self.themeDeterminerDidChange()
		PreferenceManager.shared.themeDeterminerDidChangeNotification.add(self, selector: #selector(self.themeDeterminerDidChange))
	}
	
	func themeDeterminerDidChange() {
		
		if PreferenceManager.shared.themeDeterminer == .displayBrightness {
			// start monitoring brightness
			Notification.Name.UIScreenBrightnessDidChange.add(self, selector: #selector(self.themeDidChange))
		} else if PreferenceManager.shared.themeDeterminer == .twilight {
			// TODO: Set trigger for sunset or sunrise time?
		}
	}
	func themeDidChange() {
		
		DispatchQueue.main.async {
			
			if self.theme == .dark {
				self.label.backgroundColor = StyleKit.darkBackdropOverlayColor
				self.label.textColor = StyleKit.darkPrimaryTextColor
			} else if self.theme == .light {
				self.label.backgroundColor = StyleKit.lightBackdropOverlayColor
				self.label.textColor = StyleKit.lightPrimaryTextColor
			} else {
				if PreferenceManager.shared.determineTheme() == .dark {
					self.label.backgroundColor = StyleKit.darkBackdropOverlayColor
					self.label.textColor = StyleKit.darkPrimaryTextColor
				} else {
					self.label.backgroundColor = StyleKit.lightBackdropOverlayColor
					self.label.textColor = StyleKit.lightPrimaryTextColor
				}
			}
		}

		self.setNeedsDisplay()
	}
	override func awakeFromNib() {
		super.awakeFromNib()
		
		if self.selected {
			UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
				self.selectedOverlay.transform = CGAffineTransform(scaleX: 1, y: 1)
				self.selectedOverlay.alpha = 1
			})
		} else {
			UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*0.25, delay: 0, options: .curveEaseOut, animations: {
				self.selectedOverlay.transform = CGAffineTransform(scaleX: 1.4, y: 1.4)
				self.selectedOverlay.alpha = 0
			})
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
		
		if self.theme == .dark {
			StyleKit.drawDarkBackdrop(frame: rect, resizing: .aspectFit)
			self.layer.backgroundColor = StyleKit.darkBackgroundColor.cgColor
			self.layer.borderColor = StyleKit.darkStrokeColor.cgColor
		} else if self.theme == .light {
			StyleKit.drawLightBackdrop(frame: rect, resizing: .aspectFit)
			self.layer.backgroundColor = StyleKit.lightBackgroundColor.cgColor
			self.layer.borderColor = StyleKit.lightStrokeColor.cgColor
		} else {
			if PreferenceManager.shared.determineTheme() == .dark {
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
		PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
		
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.themeDidChange()
		PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
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
