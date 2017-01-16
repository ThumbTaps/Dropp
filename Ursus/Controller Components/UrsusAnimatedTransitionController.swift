//
//  UrsusAnimatedTransitionController.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/16/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class UrsusAnimatedTransitionController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var originFrame = CGRect.zero
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let source = transitionContext.viewController(forKey: .from),
            let containerView = transitionContext.containerView as? UIView,
            let destination = transitionContext.viewController(forKey: .to) else {
                return
        }
        
        // 2
        let initialFrame = originFrame
        let finalFrame = transitionContext.finalFrame(for: destination)
        
        // 3
        let snapshot = destination.view.snapshotView(afterScreenUpdates: true)
        snapshot?.frame = initialFrame
        snapshot?.layer.cornerRadius = 12
        snapshot?.layer.masksToBounds = true

        containerView.addSubview(destination.view)
        containerView.addSubview(snapshot!)
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveEaseOut, animations: { 
            snapshot?.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height - 60)
        }) { (completed) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
