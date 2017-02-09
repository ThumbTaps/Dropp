//
//  SlideDownAnimatedTransitionController.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 2/2/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class SlideDownAnimatedTransitionController: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
	
	private var presenting = true
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return self.presenting ? 0.8 : 0.5
	}
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let source = transitionContext.viewController(forKey: .from),
			let destination = transitionContext.viewController(forKey: .to) else {
				return
		}
		
		let duration = self.transitionDuration(using: transitionContext)
		
		if self.presenting {
			
			destination.view.transform = CGAffineTransform(translationX: 0, y: -source.view.bounds.height)
			
			transitionContext.containerView.addSubview(destination.view)
			
			DispatchQueue.main.async {
				
				UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*duration, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.6, options: .curveEaseOut, animations: {
					
					destination.view.transform = CGAffineTransform(translationX: 0, y: 0)
					
				}, completion: { (completed) in
					
					transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
				})
			}
		}
			
		else {
			
			transitionContext.containerView.addSubview(source.view)
			
			DispatchQueue.main.async {
				
				UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*duration, delay: 0, options: .curveEaseInOut, animations: {
					
					source.view.transform = CGAffineTransform(translationX: 0, y: -destination.view.bounds.height)
					
				}, completion: { (completed) in
					
					transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
				})
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
