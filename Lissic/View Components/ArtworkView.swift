//
//  ArtworkArtView.swift
//  Lissic
//
//  Created by Jeffery Jackson, Jr. on 12/26/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class ArtworkArtView: UIView {
	
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
	@IBInspectable var shadowed: Bool = false {
		didSet {
			self.setNeedsDisplay()
		}
	}
	
	@IBOutlet weak var imageView: UIImageView!
	
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
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.imageView?.clipsToBounds = true
		self.imageView?.layer.cornerRadius = self.bounds.width / 24

		self.hideArtwork()
	}
	func themeDidChange() {
		if PreferenceManager.shared.theme == .dark {
			self.tintColor = StyleKit.darkBackgroundColor
		} else {
			self.tintColor = StyleKit.lightBackgroundColor
		}
	}
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		self.setNeedsDisplay()
	}
	
	override func draw(_ rect: CGRect) {
		
		if self.tintColor.isDarkColor {
			StyleKit.drawDarkPlaceholderReleaseArtwork(frame: rect, resizing: .aspectFit)
			self.layer.borderColor = StyleKit.darkStrokeColor.cgColor
		} else {
			StyleKit.drawLightPlaceholderReleaseArtwork(frame: rect, resizing: .aspectFit)
			self.layer.borderColor = StyleKit.lightStrokeColor.cgColor
		}
		
		if self.shadowed {
			self.layer.shadowPath = CGPath(roundedRect: rect, cornerWidth: rect.width / 24, cornerHeight: rect.width / 24, transform: nil)
			self.layer.shadowColor = UIColor.black.cgColor
			self.layer.shadowRadius = rect.width / 10
			self.layer.shadowOffset = CGSize(width: 0, height: 3)
			self.layer.shadowOpacity = self.tintColor.isDarkColor ? 0.8 : 0.25
		}
		
		self.layer.backgroundColor = UIColor.clear.cgColor
		self.layer.borderWidth = min(rect.width / 70, 3)
		self.layer.cornerRadius = rect.width / 24
	}
	
	
	func showArtwork(_ animated: Bool=false) {
		
		UIView.animate(withDuration: animated ? ANIMATION_SPEED_MODIFIER*0.5 : 0, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.85, options: .curveEaseOut, animations: {
			self.imageView.alpha = 1
			self.imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
		})
		
	}
	func hideArtwork(_ animated: Bool=false) {
		
		UIView.animate(withDuration: animated ? ANIMATION_SPEED_MODIFIER*0.3 : 0, delay: 0, options: .curveEaseOut, animations: {
			self.imageView.alpha = 0
			self.imageView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
		})
		
	}
}
