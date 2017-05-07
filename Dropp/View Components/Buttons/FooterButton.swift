//
//  FooterButton.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 4/26/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class FooterButton: UIView {
	
	var selectedBackgroundView: UIView?
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		if self.selectedBackgroundView == nil {
			
			self.selectedBackgroundView = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height+10))
			self.selectedBackgroundView?.backgroundColor = self.tintColor.withAlpha(0.4)
			self.selectedBackgroundView?.isHidden = true
			self.selectedBackgroundView?.alpha = 0
			self.insertSubview(self.selectedBackgroundView!, at: 0)
			
		}
	}
	
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		self.selectedBackgroundView?.backgroundColor = self.tintColor.withAlpha(0.4)
	}
	/*
	// Only override draw() if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
	// Drawing code
	}
	*/
	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		let marginForError: CGFloat = 10
		let relativeFrame = self.bounds
		let hitTestEdgeInsets = UIEdgeInsetsMake(-marginForError, -marginForError, -marginForError, -marginForError)
		let hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets)
		return hitFrame.contains(point)
	}
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesBegan(touches, with: event)
		
		self.selectedBackgroundView?.isHidden = false
		UIViewPropertyAnimator(duration: 0.2 * ANIMATION_SPEED_MODIFIER, curve: .linear, animations: {
			self.selectedBackgroundView?.alpha = 1
		}).startAnimation()
		
	}
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesMoved(touches, with: event)
		
		if let touchLocation = touches.first?.location(in: self) {
			
			if !self.point(inside: touchLocation, with: event) {
				self.touchesCancelled(touches, with: event)
			}
		}
		
	}
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		let animation = UIViewPropertyAnimator(duration: 0.3 * ANIMATION_SPEED_MODIFIER, curve: .linear, animations: {
			self.selectedBackgroundView?.alpha = 0
		})
		
		animation.addCompletion({ (position) in
			if position == .end {
				self.selectedBackgroundView?.isHidden = true
			}
		})
		
		animation.startAnimation()
		
		super.touchesEnded(touches, with: event)
	}
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		self.touchesEnded(touches, with: event)
		super.touchesCancelled(touches, with: event)
	}
}
