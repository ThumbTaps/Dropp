//
//  DroppStoryboardSegue.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 12/1/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class DroppStoryboardSegue: UIStoryboardSegue, UIViewControllerTransitioningDelegate {
	
	var isInteractive = false
	
    override func perform() {
		
		guard let parent = self.source.parent as? DroppNavigationController else {
			
			self.source.transitioningDelegate = self
			self.destination.modalPresentationStyle = .custom
			self.source.dismiss(animated: true, completion: nil)
			
			return
		}
		
		if self.destination.isKind(of: DroppModalViewController.self) {
			self.destination.transitioningDelegate = self
			self.destination.modalPresentationStyle = .custom
			parent.present(self.destination, animated: true)
		} else {
			if let destinationAsChild = self.destination as? DroppChildViewController {
				parent.push(destinationAsChild)
			}
		}
    }
	
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let animationController = ModalTransitionController()
		animationController.modalVC = presented as? DroppModalViewController
		return animationController
	}
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		let animationController = ModalTransitionController()
		animationController.isPresenting = false
		animationController.modalVC = dismissed as? DroppModalViewController
		return animationController
	}
	func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		if self.source.isKind(of: DroppModalViewController.self) {
			return UIPercentDrivenInteractiveTransition()
		}
		
		return nil
	}
	func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
		if self.source.isKind(of: DroppModalViewController.self) {
			return UIPercentDrivenInteractiveTransition()
		}
		
		return nil
	}
}
