//
//  ModalTransitionController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 5/26/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ModalTransitionController: UIPercentDrivenInteractiveTransition, UIViewControllerAnimatedTransitioning {
	
	var isPresenting = true
	var isInteractive = false
	
	var dismissGestureRecognizer: UIPanGestureRecognizer!
	var modalVC: DroppModalViewController! {
		didSet {
			self.dismissGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.dismissGestureRecognized))
			self.modalVC!.view.addGestureRecognizer(self.dismissGestureRecognizer!)
		}
	}
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return (self.isPresenting ? 0.5 : 0.25) * ANIMATION_SPEED_MODIFIER
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		let fromVC = transitionContext.viewController(forKey: .from)!
		let toVC = transitionContext.viewController(forKey: .to)!
		
		let containerView = transitionContext.containerView
		
		let finalToFrame = CGRect(x: 20, y: 60, width: containerView.frame.width - 40, height: containerView.frame.height - 120)
		
		if self.isPresenting {
			
			toVC.view.frame = finalToFrame
			toVC.view.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height)
			
			containerView.addSubview(toVC.view)
			
			let cornerAnim = CABasicAnimation(keyPath: "cornerRadius")
			cornerAnim.fromValue = 0
			cornerAnim.toValue = 12
			cornerAnim.duration = self.transitionDuration(using: transitionContext)
			cornerAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.8, 0.9, 1.0)
			fromVC.view.layer.add(cornerAnim, forKey: "cornerRadius")
			fromVC.view.layer.cornerRadius = 12
			
			let animation = UIViewPropertyAnimator(duration: self.transitionDuration(using: transitionContext), dampingRatio: 1) {
				
				UIApplication.shared.statusBarStyle = .lightContent
				
				fromVC.view.tintAdjustmentMode = .dimmed
				fromVC.view.alpha = 0.45
				fromVC.view.transform = CGAffineTransform(translationX: 0, y: 24)
				
				toVC.view.transform = .identity
			}
			animation.addCompletion { (position) in
				if position == .end {
					
					toVC.view.transform = .identity
					
					transitionContext.completeTransition(!transitionContext.transitionWasCancelled)					
				}
			}
			animation.startAnimation()
		}
		
		else {
			
			UIApplication.shared.keyWindow?.addSubview(fromVC.view)
			
			let cornerAnim = CABasicAnimation(keyPath: "cornerRadius")
			cornerAnim.fromValue = 12
			cornerAnim.toValue = 0
			cornerAnim.duration = self.transitionDuration(using: transitionContext)
			cornerAnim.timingFunction = CAMediaTimingFunction(controlPoints: 0.2, 0.8, 0.9, 1.0)
			toVC.view.layer.add(cornerAnim, forKey: "cornerRadius")
			toVC.view.layer.cornerRadius = 0
			
			let animation = UIViewPropertyAnimator(duration: self.transitionDuration(using: transitionContext), curve: .easeOut) {
				
				UIApplication.shared.statusBarStyle = ThemeKit.statusBarStyle
				
				toVC.view.tintAdjustmentMode = .normal
				toVC.view.alpha = 1.0
				toVC.view.transform = CGAffineTransform(translationX: 0, y: 0)
				
				fromVC.view.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height)
			}
			animation.addCompletion { (position) in
				if position == .end {
					
					fromVC.view.transform = .identity
					// tell our transitionContext object that we've finished animating
					if transitionContext.transitionWasCancelled {
						
						transitionContext.completeTransition(false)
						
					}
					else {
						
						transitionContext.completeTransition(true)
						
					}
				}
			}
			animation.startAnimation()
		}
	}
	
	func dismissGestureRecognized() {
		
		guard let modalView = modalVC?.view,
			let dismissGestureRecognizer = self.dismissGestureRecognizer else {
				return
		}
		
		let translation = dismissGestureRecognizer.translation(in: modalView)
		var progress = (translation.y / modalView.frame.height)
		progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
		print(progress)
		
		switch dismissGestureRecognizer.state {
		case .began:
			self.isInteractive = true
			self.modalVC?.performSegue(withIdentifier: "modalDismiss", sender: dismissGestureRecognizer)
			
			break
		case .changed:
			
			self.update(progress)
			break
			
		case .ended:
			if dismissGestureRecognizer.velocity(in: modalView).y > 0 {
				self.finish()
			} else {
				self.cancel()
			}
			
			self.isInteractive = false
			break
			
		default:
			self.cancel()
		}
	}	
}
