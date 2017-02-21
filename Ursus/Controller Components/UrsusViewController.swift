//
//  UrsusViewController.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 12/1/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class UrsusViewController: UIViewController {
	
    @IBOutlet weak var backdrop: FrostedBackdrop?

//    @IBOutlet weak var backButton: LeftButton?
//    @IBOutlet weak var backButtonHidingConstraint: NSLayoutConstraint?
//    @IBOutlet weak var backButtonVisibleLeadingConstraint: NSLayoutConstraint?
//    @IBOutlet weak var backButtonVisibleTrailingConstraint: NSLayoutConstraint?
	@IBOutlet weak var topScrollFadeView: ScrollFadeView?
	@IBOutlet weak var bottomScrollFadeView: ScrollFadeView?
	@IBOutlet weak var navigationTitle: UILabel?
	@IBOutlet weak var navigationTitleHidingConstraint: NSLayoutConstraint?
	@IBOutlet weak var navigationTitleRestingConstraint: NSLayoutConstraint?
	@IBOutlet weak var collectionView: UICollectionView?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        // Do any additional setup after loading the view.
		
		// start listening for theme change
		PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
		
		// start listening for new releases updates
		PreferenceManager.shared.didUpdateReleasesNotification.add(self, selector: #selector(self.didUpdateNewReleases))

		self.collectionView?.contentInset = UIEdgeInsets(top: (self.topScrollFadeView?.frame.height ?? 120) - 40, left: 0, bottom: (self.bottomScrollFadeView?.frame.height ?? 120) - 40, right: 0)

		// This can't be a direct call to self.themeDidChange because it will trigger on other view controllers that may want to animate in certain properties
		DispatchQueue.main.async {
			
			if PreferenceManager.shared.theme == .dark {
				UIApplication.shared.statusBarStyle = .lightContent
				self.view.tintColor = StyleKit.darkTintColor
				self.collectionView?.indicatorStyle = .white
				self.topScrollFadeView?.tintColor = StyleKit.darkBackdropOverlayColor
				self.bottomScrollFadeView?.tintColor = StyleKit.darkBackdropOverlayColor
				self.navigationTitle?.textColor = StyleKit.darkPrimaryTextColor
			} else {
				UIApplication.shared.statusBarStyle = .default
				self.view.tintColor = StyleKit.lightTintColor
				self.collectionView?.indicatorStyle = .default
				self.topScrollFadeView?.tintColor = StyleKit.lightBackdropOverlayColor
				self.bottomScrollFadeView?.tintColor = StyleKit.lightBackdropOverlayColor
				self.navigationTitle?.textColor = StyleKit.lightPrimaryTextColor
			}
			
		}
		
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		guard self.navigationTitle != nil, navigationTitleHidingConstraint != nil, navigationTitleRestingConstraint != nil else {
			return
		}
		
		DispatchQueue.main.async {
			// move navigation title in
			(self.backdrop?.overlay ?? self.view).removeConstraint(self.navigationTitleHidingConstraint!)
			(self.backdrop?.overlay ?? self.view).addConstraint(self.navigationTitleRestingConstraint!)
		
			UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
				(self.backdrop?.overlay ?? self.view).layoutIfNeeded()
			})
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
	
	
	
	
	// MARK: - Notifications
	func themeDidChange() {
		
		DispatchQueue.main.async {
			
			if PreferenceManager.shared.theme == .dark {
				UIApplication.shared.statusBarStyle = .lightContent
				self.view.tintColor = StyleKit.darkTintColor
				self.view.backgroundColor = StyleKit.darkBackgroundColor
				self.collectionView?.indicatorStyle = .white
				self.topScrollFadeView?.tintColor = StyleKit.darkBackdropOverlayColor
				self.bottomScrollFadeView?.tintColor = StyleKit.darkBackdropOverlayColor
				self.navigationTitle?.textColor = StyleKit.darkPrimaryTextColor
			} else {
				UIApplication.shared.statusBarStyle = .default
				self.view.tintColor = StyleKit.lightTintColor
				self.view.backgroundColor = StyleKit.lightBackgroundColor
				self.collectionView?.indicatorStyle = .default
				self.topScrollFadeView?.tintColor = StyleKit.lightBackdropOverlayColor
				self.bottomScrollFadeView?.tintColor = StyleKit.lightBackdropOverlayColor
				self.navigationTitle?.textColor = StyleKit.lightPrimaryTextColor
			}
			
		}
	}
	func didUpdateNewReleases() {
		
		// show banner if not on new releases view somehow... eheh
		
	}
	
	
	
	
	
	
	@IBAction func prepareForUnwind(for segue: UIStoryboardSegue) {
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
