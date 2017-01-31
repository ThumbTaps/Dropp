//
//  RevealBehindAnimatedTransitionController.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/18/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class RevealBehindAnimatedTransitionController: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {

	private var presenting = true
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return self.presenting ? 0.8 : 0.7
	}
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let source = transitionContext.viewController(forKey: .from),
			let destination = transitionContext.viewController(forKey: .to) else {
				return
		}
		let duration = self.transitionDuration(using: transitionContext)
		
		
		if self.presenting {
			
			let darkeningOverlay = UIView(frame: destination.view.bounds)
			darkeningOverlay.backgroundColor = UIColor.black
			darkeningOverlay.alpha = 0
			darkeningOverlay.isUserInteractionEnabled = false
			destination.view.addSubview(darkeningOverlay)
			
			let shadowView = UrsusShadowBackdrop(frame: destination.view.bounds, offset: CGSize(width: 0, height: -5), radius: 20)
			shadowView.layer.cornerRadius = 12
			destination.view.addSubview(shadowView)
			
			source.view.layer.masksToBounds = true
			source.view.layer.cornerRadius = shadowView.layer.cornerRadius
			
			transitionContext.containerView.addSubview(destination.view)
			transitionContext.containerView.addSubview(source.view)
			
			UIView.animate(withDuration: duration * 0.2, delay: 0, options: .curveEaseOut, animations: {
				
				source.view.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
				shadowView.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
				darkeningOverlay.alpha = 0.05
			}, completion: { (completed) in
				
				UIView.animate(withDuration: duration * 0.8, delay: 0, usingSpringWithDamping: UIAccessibilityIsReduceMotionEnabled() ? 1 : 0.8, initialSpringVelocity: UIAccessibilityIsReduceMotionEnabled() ? 0 : 0.8, options: .curveEaseInOut, animations: {
					source.view.frame = source.view.frame.offsetBy(dx: 0, dy: destination.view.frame.height - 90)
					shadowView.frame = shadowView.frame.offsetBy(dx: 0, dy: destination.view.frame.height - 90)
				}, completion: { (completed) in
					
					transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
				})
			})
		}
			
			
		else {
			
			transitionContext.containerView.addSubview(source.view)
			transitionContext.containerView.addSubview(destination.view)
			
			UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: UIAccessibilityIsReduceMotionEnabled() ? 1 : 0.8, initialSpringVelocity: UIAccessibilityIsReduceMotionEnabled() ? 0 : 0.3, options: .curveEaseOut, animations: {
				destination.view.transform = CGAffineTransform(scaleX: 1, y: 1)
				destination.view.frame = transitionContext.finalFrame(for: destination)
			}, completion: { (completed) in
				
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
				if !transitionContext.transitionWasCancelled {
					destination.view.layer.masksToBounds = false
					destination.view.layer.cornerRadius = 0
					
					UIApplication.shared.keyWindow?.addSubview(destination.view)
				}
			})
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
