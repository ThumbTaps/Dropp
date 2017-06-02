//
//  DroppModalViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 5/28/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class DroppModalViewController: DroppViewController, UIGestureRecognizerDelegate {
	
	@IBOutlet weak var topSheet: UIView!
	@IBOutlet weak var bottomSheetRevealConstraint: NSLayoutConstraint?

	@IBOutlet weak var closeButton: CloseButton!
	
	var animationController: UIViewControllerAnimatedTransitioning?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		self.view.layer.cornerRadius = 12
		self.view.layer.masksToBounds = true
		
		self.topSheet.layer.cornerRadius = self.view.layer.cornerRadius
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func adjustToTheme() {
		super.adjustToTheme()
		
		self.view.backgroundColor = ThemeKit.backdropOverlayColor
		self.topSheet.backgroundColor = ThemeKit.backgroundColor

		self.closeButton.tintColor = ThemeKit.tertiaryTextColor
	}
	
	@IBAction func toggleTopSheetReveal(_ sender: Any) {
		
		guard let bottomSheetVisible = self.bottomSheetRevealConstraint?.isActive else {
			return
		}
		if bottomSheetVisible  {
			self.bottomSheetRevealConstraint?.isActive = false
		} else {
			self.bottomSheetRevealConstraint?.isActive = true
		}
		
		UIViewPropertyAnimator(duration: 0.6 * ANIMATION_SPEED_MODIFIER, dampingRatio: 0.8) {
			self.view.layoutIfNeeded()
			}.startAnimation()
	}
}
