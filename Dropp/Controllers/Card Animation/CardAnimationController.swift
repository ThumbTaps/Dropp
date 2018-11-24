//
//  CardAnimationController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 11/6/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

class CardAnimationController: NSObject {
    
    let isPresenting: Bool
    let duration: TimeInterval = 0.6
    
    init(isPresenting: Bool) {
        self.isPresenting = isPresenting
        
        super.init()
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

extension CardAnimationController: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        if self.isPresenting {
            self.present(with: transitionContext)
        } else {
            self.dismiss(with: transitionContext)
        }
    }
    
    func present(with transitionContext: UIViewControllerContextTransitioning) {
        guard let bottomViewController = transitionContext.viewController(forKey: .from),
            let topViewController = transitionContext.viewController(forKey: .to) else {
                assertionFailure("Unable to determine transitioning view controllers.")
                return
        }
        
        transitionContext.containerView.addSubview(topViewController.view)
        
        var initialFrame = transitionContext.finalFrame(for: topViewController)
        initialFrame.origin.y = UIApplication.shared.keyWindow?.frame.height ?? 0

        topViewController.view?.frame = initialFrame
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState], animations: {
            
            topViewController.view?.frame = transitionContext.finalFrame(for: topViewController)
            
            bottomViewController.view?.layer.cornerRadius = 12
            bottomViewController.view?.clipsToBounds = true
            bottomViewController.view?.transform = CGAffineTransform.identity.scaledBy(x: 0.98, y: 0.98)
            bottomViewController.view?.frame.origin.y = UIApplication.shared.statusBarFrame.height

        }) { (completed: Bool) in
            transitionContext.completeTransition(completed)
        }
    }
    
    func dismiss(with transitionContext: UIViewControllerContextTransitioning) {
        guard let topViewController = transitionContext.viewController(forKey: .from),
            let bottomViewController = transitionContext.viewController(forKey: .to) else {
                assertionFailure("Unable to determine transitioning view controllers.")
                return
        }
        
        transitionContext.containerView.addSubview(topViewController.view)

        var initialFrame = transitionContext.finalFrame(for: topViewController)
        initialFrame.origin.y = UIApplication.shared.keyWindow?.frame.height ?? 0
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext) / 2, delay: 0, options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState], animations: {
            
            topViewController.view?.frame = initialFrame
            
            bottomViewController.view?.layer.cornerRadius = 0
            bottomViewController.view?.clipsToBounds = false
            bottomViewController.view?.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            bottomViewController.view?.frame.origin.y = 0

        }) { (completed: Bool) in
            topViewController.view.removeFromSuperview()
            transitionContext.completeTransition(completed)
        }
    }
}
