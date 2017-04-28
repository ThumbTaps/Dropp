//
//  ArtworkView.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 12/26/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class ArtworkView: UIView {
	
	var theme: Theme? = .light {
		didSet {
			self.setNeedsDisplay()
		}
	}
	
	@IBInspectable var shadowed: Bool = false {
		didSet {
			self.setNeedsDisplay()
		}
	}
	
	@IBOutlet weak var imageView: UIImageView!
	
	private var shadow: DroppShadowBackdrop!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.shadow = DroppShadowBackdrop(frame: self.bounds, offset: CGSize(width: 0, height: 3), radius: self.bounds.width / 10)
		if self.shadowed {
			self.insertSubview(shadow, at: 0)
		}
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.shadow = DroppShadowBackdrop(frame: self.bounds, offset: CGSize(width: 0, height: 3), radius: self.bounds.width / 10)
		if self.shadowed {
			self.insertSubview(shadow, at: 0)
		}
	}
	override func awakeFromNib() {
		super.awakeFromNib()
		
		
		self.imageView?.clipsToBounds = true
		self.imageView?.layer.cornerRadius = self.bounds.width * 0.1
		self.imageView.contentMode = .scaleAspectFill

		self.hideArtwork()
	}
	
	override func draw(_ rect: CGRect) {
		
		super.draw(rect)
		
		self.layer.backgroundColor = ThemeKit.backgroundColor.cgColor
		
//		self.layer.borderWidth = min(rect.width / 50, 4)
		self.layer.cornerRadius = rect.width * 0.1
		self.shadow.alpha = self.theme == .dark ? 0.8 : 0.25
	}
	
	
	func showArtwork(_ animated: Bool=false) {
		
		UIViewPropertyAnimator(duration: animated ? ANIMATION_SPEED_MODIFIER*0.5 : 0, curve: .easeOut) {
			self.imageView.alpha = 1
		}.startAnimation()
		
	}
	func hideArtwork(_ animated: Bool=false) {
		
		UIViewPropertyAnimator(duration: animated ? ANIMATION_SPEED_MODIFIER*0.3 : 0, curve: .easeOut) {
			self.imageView.alpha = 0
		}.startAnimation()
		
	}
}
