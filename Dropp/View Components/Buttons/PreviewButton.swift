//
//  PreviewButton.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 5/8/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class PreviewButton: UIView {
	
	@IBOutlet weak var playButton: PlayButton!
	@IBOutlet weak var stopButton: StopButton!
	
	var playing: Bool = false
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.setPlaying(false, animated: false)
	}
	
	func setPlaying(_ playing: Bool, animated: Bool?=false) {
		if playing {
			
			self.stopButton.isHidden = false
			self.stopButton.transform = CGAffineTransform(scaleX: 2, y: 2)
			self.stopButton.alpha = 0
			
			let animation = UIViewPropertyAnimator(duration: (animated! ? 0.8 : 0) * ANIMATION_SPEED_MODIFIER, dampingRatio: 0.7, animations: {
				self.playButton.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
				self.playButton.alpha = 0
				self.stopButton.transform = CGAffineTransform(scaleX: 1, y: 1)
				self.stopButton.alpha = 1
			})
			
			animation.addCompletion({ (position) in
				if position == .end {
					self.playButton.isHidden = true
				}
			})
			
			animation.startAnimation()
			
		} else {
			
			self.playButton.isHidden = false
			self.playButton.transform = CGAffineTransform(scaleX: 2, y: 2)
			self.playButton.alpha = 0
			
			let animation = UIViewPropertyAnimator(duration: (animated! ? 0.8 : 0) * ANIMATION_SPEED_MODIFIER, dampingRatio: 0.7, animations: {
				self.playButton.transform = CGAffineTransform(scaleX: 1, y: 1)
				self.playButton.alpha = 1
				self.stopButton.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
				self.stopButton.alpha = 0
			})
			
			animation.addCompletion({ (position) in
				if position == .end {
					self.stopButton.isHidden = true
				}
			})
			
			animation.startAnimation()
			
		}
		
		self.playing = playing
	}
	
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		self.setNeedsDisplay()
	}
	// Only override draw() if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
	// Drawing code
		
		self.playButton.tintColor = self.tintColor
		self.stopButton.tintColor = self.tintColor
		
		
	}
	
}
