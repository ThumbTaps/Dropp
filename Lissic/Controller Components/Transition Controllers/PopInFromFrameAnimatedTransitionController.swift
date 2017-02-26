//
//  PopInFromFrameAnimatedTransitionController.swift
//  Lissic
//
//  Created by Jeffery Jackson, Jr. on 1/26/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class PopInFromFrameAnimatedTransitionController: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
	
	private var presenting = true
	var initialFrame: CGRect = .zero
	var finalFrame: CGRect = .zero
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return self.presenting ? 0.8 : 0.1
	}
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let source = transitionContext.viewController(forKey: .from),
			let destination = transitionContext.viewController(forKey: .to) else {
				return
		}
		
		let duration = self.transitionDuration(using: transitionContext)
		
		if self.presenting {
			
			destination.view.alpha = 0
			destination.view.frame = self.initialFrame
			destination.view.clipsToBounds = false
			
			transitionContext.containerView.addSubview(source.view)
			transitionContext.containerView.addSubview(destination.view)
			
			UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*duration*0.4, delay: 0, options: .curveEaseOut, animations: {
				
				destination.view.frame = self.finalFrame
				destination.view.alpha = 1
				
			}, completion: { (completed) in
				
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
					
			})
		}
			
		else {
			
			source.view.clipsToBounds = false
			
			transitionContext.containerView.addSubview(destination.view)
			transitionContext.containerView.addSubview(source.view)
			
			UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*duration, delay: 0, options: .curveEaseOut, animations: {
				
				source.view.frame = self.initialFrame
				source.view.alpha = 0
				
			}, completion: { (completed) in
				
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
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
