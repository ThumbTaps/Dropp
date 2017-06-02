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
	
	@IBInspectable var shadowed: Bool = false {
		didSet {
			self.setNeedsDisplay()
		}
	}
	
	@IBOutlet weak var imageView: UIImageView!
	
	var shadow: DroppShadowBackdrop?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.imageView.clipsToBounds = true
		self.imageView.layer.cornerRadius = 2 + ((self.imageView.frame.width / 300) * 5)
		self.imageView.contentMode = .scaleAspectFill
		
		if self.shadowed {
			self.shadow = DroppShadowBackdrop(frame: self.bounds, offset: .zero, radius: 8, cornerRadius: self.imageView.layer.cornerRadius, color: ThemeKit.shadowColor)
//			self.shadow?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
			self.insertSubview(self.shadow!, at: 0)
		}
		
		self.hideArtwork()
	}
	override func layoutSubviews() {
		super.layoutSubviews()
		
		self.shadow?.frame = self.bounds
	}
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		self.setNeedsDisplay()
	}
	override func draw(_ rect: CGRect) {
		
		super.draw(rect)
				
//		self.layer.borderWidth = min(rect.width / 50, 4)
	}
	
	
	func showArtwork(_ animated: Bool=false) {
		
		UIViewPropertyAnimator(duration: animated ? ANIMATION_SPEED_MODIFIER*0.5 : 0, curve: .easeOut) {
			self.imageView.alpha = 1
			self.shadow?.alpha = 1
		}.startAnimation()
		
	}
	func hideArtwork(_ animated: Bool=false) {
		
		UIViewPropertyAnimator(duration: animated ? ANIMATION_SPEED_MODIFIER*0.3 : 0, curve: .easeOut) {
			self.imageView.alpha = 0
			self.shadow?.alpha = 0
		}.startAnimation()
		
	}
}
