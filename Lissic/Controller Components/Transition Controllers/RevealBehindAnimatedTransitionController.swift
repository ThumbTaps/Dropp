//
//  RevealBehindAnimatedTransitionController.swift
//  Lissic
//
//  Created by Jeffery Jackson, Jr. on 1/18/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class RevealBehindAnimatedTransitionController: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
	
	var presenting = true
	var interactive = false
	
	convenience init(forPresenting presenting: Bool, interactively interactive: Bool) {
		self.init()
		
		self.presenting = presenting
		self.interactive = interactive
	}
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		var duration = 0.0
		if self.presenting {
			if self.interactive {
				duration = 0.35
			} else {
				duration = 0.8
			}
		} else {
			if self.interactive {
				duration = 0.4
			} else {
				duration = 0.7
			}
		}
		
		return duration * ANIMATION_SPEED_MODIFIER
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
			
			source.view.layer.masksToBounds = true
			source.view.layer.cornerRadius = 12
			
			transitionContext.containerView.addSubview(destination.view)
			transitionContext.containerView.addSubview(source.view)
			
			let popBackAnimator = UIViewPropertyAnimator(duration: duration*0.2, curve: .easeOut, animations: {
				
				source.view.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
				darkeningOverlay.alpha = 0.1
			})
			
			let slideDownAnimator = UIViewPropertyAnimator(duration: duration*0.8, dampingRatio: UIAccessibilityIsReduceMotionEnabled() ? 1 : 0.8, animations: {
				
				source.view.frame = source.view.frame.offsetBy(dx: 0, dy: destination.view.frame.height - 90)
			})
			slideDownAnimator.addCompletion({ (position) in
				
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
				if transitionContext.transitionWasCancelled {
					
					source.view.layer.masksToBounds = false
					source.view.layer.cornerRadius = 0
					
					UIApplication.shared.keyWindow?.addSubview(source.view)
				} else {
					
					// UIApplication.shared.keyWindow?.addSubview(destination.view)
				}
			})
			
			if self.interactive {
				slideDownAnimator.startAnimation()
				
			} else {
				popBackAnimator.addCompletion({ (position) in
					slideDownAnimator.startAnimation()
				})
				popBackAnimator.startAnimation()
			}
			
		}
			
			
		else {
			
			transitionContext.containerView.addSubview(source.view)
			transitionContext.containerView.addSubview(destination.view)
			
			var slideUpAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: UIAccessibilityIsReduceMotionEnabled() ? 1 : 0.8)
			
			if self.interactive {
				slideUpAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear)
			}
			
			slideUpAnimator.addAnimations {

				destination.view.transform = CGAffineTransform(scaleX: 1, y: 1)
				destination.view.frame = transitionContext.finalFrame(for: destination)
				destination.view.layoutIfNeeded()
			}
			slideUpAnimator.addCompletion({ (position) in
				
				transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
				if !transitionContext.transitionWasCancelled {
										
					destination.view.layer.masksToBounds = false
					destination.view.layer.cornerRadius = 0
					
					UIApplication.shared.keyWindow?.addSubview(destination.view)
				}
				
			})
			slideUpAnimator.startAnimation()
		}
		
	}
	func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return self.interactive ? self : nil
	}
	func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		return self.interactive ? self : nil
	}
}
