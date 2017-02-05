//
//  BlurAndOverlayAnimatedTransitionController.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/17/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class BlurAndOverlayAnimatedTransitionController: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
	
	private var presenting = true
	
	var blurView: UrsusBlurView?
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return self.presenting ? 0.4 : 0.3
	}
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let source = transitionContext.viewController(forKey: .from),
			let destination = transitionContext.viewController(forKey: .to) else {
				return
		}
		
		let duration = self.transitionDuration(using: transitionContext)
		
		if self.presenting {
			self.blurView = UrsusBlurView(frame: source.view.bounds)
			transitionContext.containerView.addSubview(self.blurView!)
			transitionContext.containerView.addSubview(destination.view)
			
			UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
				if self.blurView?.changesWithTheme ?? false {
					self.blurView?.themeDidChange()
				}
			}) { (completed) in
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
			}
		}
		
			
		else {
			self.blurView = UrsusBlurView(frame: destination.view.bounds)
			if PreferenceManager.shared.theme == .dark {
				self.blurView?.effect = UIBlurEffect(style: .dark)
			} else {
				self.blurView?.effect = UIBlurEffect(style: .light)
			}
			transitionContext.containerView.addSubview(destination.view.snapshotView(afterScreenUpdates: true)!)
			transitionContext.containerView.addSubview(self.blurView!)
			
			UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
				self.blurView?.effect = nil
			}) { (completed) in
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
			}
		}

	}
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return self
	}
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		self.presenting = false
		return self
	}
}
