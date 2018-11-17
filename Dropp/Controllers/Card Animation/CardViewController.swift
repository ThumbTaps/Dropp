//
//  CardViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 11/6/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {

    @IBOutlet weak var closeButton: DroppButton!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: Bundle!)  {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        commonInit()
    }
    
    func commonInit() {
        self.modalPresentationCapturesStatusBarAppearance = true
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
}

extension CardViewController: UIViewControllerTransitioningDelegate {
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if presented == self {
            return CardPresentationController(presentedViewController: presented, presenting: presenting)
        }
        return nil
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if presented == self {
            return CardAnimationController(isPresenting: true)
        } else {
            return nil
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if dismissed == self {
            return CardAnimationController(isPresenting: false)
        } else {
            return nil
        }
    }
}
