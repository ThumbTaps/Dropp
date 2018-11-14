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
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let fromView = fromVC?.view
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        let toView = toVC?.view
        
        let containerView = transitionContext.containerView
        
        if isPresenting {
            containerView.addSubview(toView!)
        }
        
        let bottomVC = isPresenting ? fromVC : toVC
        let bottomPresentingView = bottomVC?.view
        
        let topVC = isPresenting ? toVC : fromVC
        let topPresentedView = topVC?.view
        
        var initialFrame = transitionContext.finalFrame(for: topVC!)
        initialFrame.origin.y = bottomPresentingView?.frame.height ?? 0
        if self.isPresenting {
            topPresentedView?.frame = initialFrame
        }
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [.curveEaseOut, .allowUserInteraction, .beginFromCurrentState], animations: {
            topPresentedView?.frame = self.isPresenting ? transitionContext.finalFrame(for: topVC!) : initialFrame
            
            bottomPresentingView?.layer.cornerRadius = self.isPresenting ? 12 : 0
            bottomPresentingView?.clipsToBounds = self.isPresenting
            let scalingFactor : CGFloat = self.isPresenting ? 0.98 : 1.0
            bottomPresentingView?.transform = CGAffineTransform.identity.scaledBy(x: scalingFactor, y: scalingFactor)
            bottomPresentingView?.frame.origin.y = self.isPresenting ? UIApplication.shared.statusBarFrame.height : 0
        }) { (completed: Bool) in
            if !self.isPresenting {
                fromView?.removeFromSuperview()
            }
            transitionContext.completeTransition(completed)
        }
    }
}
