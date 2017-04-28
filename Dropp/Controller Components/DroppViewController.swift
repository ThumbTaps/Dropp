//
//  DroppViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 12/1/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class DroppViewController: UIViewController {
	
	var navController: DroppNavigationController? {
		return self.parent as? DroppNavigationController
	}
	
	@IBInspectable var headerHeight: CGFloat = 120
	@IBInspectable var headerLabelSize: CGFloat = 30
	
	@IBOutlet weak var collectionView: UICollectionView?
	
	@IBOutlet weak var buttonView: UIView?
	
	@IBOutlet weak var footerView: UIView?
	
	var shouldShowFooter: Bool {
		return true
	}
	
	var backButton: DroppButton? {
		return nil
	}
		
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.view.layer.cornerRadius = 12
		
        // Do any additional setup after loading the view.
		self.collectionView?.indicatorStyle = ThemeKit.indicatorStyle
		self.collectionView?.backgroundColor = ThemeKit.backdropOverlayColor
		
		// start listening for new releases updates
		PreferenceManager.shared.didUpdateReleasesNotification.add(self, selector: #selector(self.didUpdateReleases))
		
		if let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
			layout.sectionHeadersPinToVisibleBounds = true
		}
		
		let topInset = self.headerHeight + (self.shouldShowFooter ? (self.footerView?.frame.height ?? self.navController?.footerBackButton.frame.height ?? 0) - 10 : 0)
		self.collectionView?.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
	
	
	
	
	// MARK: - Notifications
	func didUpdateReleases() {
		
		// show banner if not on new releases view somehow... eheh
		
	}
	func themeDidChange() {
		self.collectionView?.indicatorStyle = ThemeKit.indicatorStyle
		self.collectionView?.backgroundColor = ThemeKit.backdropOverlayColor
		self.collectionView?.reloadData()
	}
	func didShowFooter() {
		let topInset = self.headerHeight + (self.shouldShowFooter ? (self.footerView?.frame.height ?? self.navController?.footerBackButton.frame.height ?? 0) - 10 : 0)
		UIViewPropertyAnimator(duration: 0.4 * ANIMATION_SPEED_MODIFIER, dampingRatio: 0.7) {
			self.collectionView?.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
		}.startAnimation()
	}
	func didHideFooter() {
		let topInset = self.headerHeight
		UIViewPropertyAnimator(duration: 0.4 * ANIMATION_SPEED_MODIFIER, dampingRatio: 0.7) {
			self.collectionView?.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
			}.startAnimation()
	}
}


extension UIView {
	
	func enableParallax() {
		let amount = 50
		
		let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
		horizontal.minimumRelativeValue = -amount
		horizontal.maximumRelativeValue = amount
		
		let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
		vertical.minimumRelativeValue = -amount
		vertical.maximumRelativeValue = amount
		
		self.motionEffects = [horizontal, vertical]
	}
	func disableParallax() {
		self.motionEffects.forEach({ self.removeMotionEffect($0) })
	}
}
