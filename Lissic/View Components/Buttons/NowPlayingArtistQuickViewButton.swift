//
//  NowPlayingArtistQuickViewButton.swift
//  Lissic
//
//  Created by Jeffery Jackson, Jr. on 2/23/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class NowPlayingArtistQuickViewButton: ArtworkArtView {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
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
		
		DispatchQueue.main.async {
			
			UIViewPropertyAnimator(duration: 0.4 * ANIMATION_SPEED_MODIFIER, dampingRatio: 0.5) {
				self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
			}.startAnimation()
		}
		
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
		
		DispatchQueue.main.async {
			
			UIViewPropertyAnimator(duration: 0.5 * ANIMATION_SPEED_MODIFIER, dampingRatio: 0.6) {
				self.transform = CGAffineTransform(scaleX: 1, y: 1)
			}.startAnimation()
		}
		
		super.touchesEnded(touches, with: event)
	}
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
		self.touchesEnded(touches, with: event)
	}

}
