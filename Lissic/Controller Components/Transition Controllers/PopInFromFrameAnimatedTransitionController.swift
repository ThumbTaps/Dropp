//
//  PopInFromFrameAnimatedTransitionController.swift
//  Lissic
//
//  Created by Jeffery Jackson, Jr. on 1/26/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class PopInFromFrameAnimatedTransitionController: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
	
	var presenting = true
	var interactive = false
	
	convenience init(forPresenting presenting: Bool, interactively interactive: Bool) {
		self.init()
		
		self.presenting = presenting
		self.interactive = interactive
	}
	var initialFrame: CGRect = .zero
	var finalFrame: CGRect = .zero
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return self.presenting ? 0.6 : 0.6
	}
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let source = transitionContext.viewController(forKey: .from),
			let destination = transitionContext.viewController(forKey: .to) else {
				return
		}
		
		let duration = self.transitionDuration(using: transitionContext)
		
		if self.presenting {
			
			destination.view.frame = self.initialFrame
			destination.view.clipsToBounds = false
			
			transitionContext.containerView.addSubview(source.view)
			transitionContext.containerView.addSubview(destination.view)
			
			let animator = UIViewPropertyAnimator(duration: ANIMATION_SPEED_MODIFIER*duration, dampingRatio: 0.8, animations: {
				destination.view.frame = self.finalFrame
			})
				
			animator.addCompletion({ (position) in
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
			})
			
			animator.startAnimation()
		}
			
		else {
			
			source.view.clipsToBounds = false
			
			transitionContext.containerView.addSubview(destination.view)
			transitionContext.containerView.addSubview(source.view)
			
			let animator = UIViewPropertyAnimator(duration: ANIMATION_SPEED_MODIFIER*duration, curve: .easeOut, animations: {
				source.view.frame = self.initialFrame
				source.view.alpha = 0
			})
			
			animator.addCompletion({ (position) in
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
			})
			
			animator.startAnimation()
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
