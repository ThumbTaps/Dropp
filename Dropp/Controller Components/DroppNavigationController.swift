//
//  DroppNavigationController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 4/17/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class DroppNavigationController: UIViewController {
	
	@IBOutlet weak var backdrop: DroppBackdrop!
	
	@IBOutlet weak var headerView: UIVisualEffectView!
	@IBOutlet private weak var headerViewHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var headerLabel: UILabel!
	
	@IBOutlet weak var buttonViewContainer: UIView!
	
	@IBOutlet weak var childViewContainer: DroppBackdrop!
	@IBOutlet private weak var childViewContainerBottomConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var footerViewContainer: UIView!
	@IBOutlet weak var footerViewHeightConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var footerBackButton: FooterBackButton!
	
	@IBOutlet weak var shadowBackdrop: DroppShadowBackdrop!
	
	var currentViewController: DroppViewController?
	var lastViewController: DroppViewController? {
		guard self.childViewControllers.count > 1, let lastViewController = self.childViewControllers[self.childViewControllers.index(before: self.childViewControllers.count-1)] as? DroppViewController else {
			return nil
		}
		
		return lastViewController
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange(_:)))
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.view.layer.cornerRadius = 12
		self.view.layer.masksToBounds = true
		self.childViewContainer.layer.cornerRadius = 12
		self.childViewContainer.layer.cornerRadius = 12
		
		self.adjustToTheme()
	}
	
	func themeDidChange(_ notification: Notification) {
		self.adjustToTheme()
	}
	func adjustToTheme(preparingFor viewController: DroppViewController?=nil) {
		
		if !(viewController?.shouldIgnoreThemeChanges ?? self.currentViewController?.shouldIgnoreThemeChanges ?? false) {
			
			DispatchQueue.main.async {
				
				UIApplication.shared.statusBarStyle = ThemeKit.statusBarStyle
				self.view.tintColor = ThemeKit.tintColor
				
				self.headerView.effect = UIBlurEffect(style: ThemeKit.blurEffectStyle)
				self.headerLabel.textColor = ThemeKit.primaryTextColor
				
				self.footerViewContainer.backgroundColor = ThemeKit.backgroundColor
				self.footerBackButton.destinationTitle.textColor = ThemeKit.tintColor
				
				self.childViewContainer.backgroundColor = ThemeKit.backgroundColor
				self.shadowBackdrop.shadowColor = ThemeKit.shadowColor
				
//				(viewController ?? self.currentViewController)?.adjustToTheme()
			}
		}
	}
	
	private func addChildView(_ childView: UIView?) {
		guard let childView = childView else {
			return
		}
		
		DispatchQueue.main.async {
			self.childViewContainer.addSubview(childView)
			self.childViewContainer.addConstraints([
				NSLayoutConstraint(item: childView, attribute: .top, relatedBy: .equal, toItem: self.childViewContainer, attribute: .top, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: childView, attribute: .left, relatedBy: .equal, toItem: self.childViewContainer, attribute: .left, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: childView, attribute: .bottom, relatedBy: .equal, toItem: self.childViewContainer, attribute: .bottom, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: childView, attribute: .right, relatedBy: .equal, toItem: self.childViewContainer, attribute: .right, multiplier: 1, constant: 0)
				])
			self.childViewContainer.layoutIfNeeded()
		}
	}
	private func addButtonView(_ buttonView: UIView?) {
		guard let buttonView = buttonView else {
			return
		}
		
		DispatchQueue.main.async {
			self.buttonViewContainer?.addSubview(buttonView)
			self.buttonViewContainer.addConstraints([
				NSLayoutConstraint(item: buttonView, attribute: .centerX, relatedBy: .equal, toItem: self.buttonViewContainer, attribute: .centerX, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: buttonView, attribute: .centerY, relatedBy: .equal, toItem: self.buttonViewContainer, attribute: .centerY, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: buttonView, attribute: .width, relatedBy: .equal, toItem: self.buttonViewContainer, attribute: .width, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: buttonView, attribute: .height, relatedBy: .equal, toItem: self.buttonViewContainer, attribute: .height, multiplier: 1, constant: 0)
				])
			self.buttonViewContainer.layoutIfNeeded()
		}
	}
	private func addFooterView(_ footerView: UIView?) {
		guard let footerView = footerView else {
			return
		}
		
		DispatchQueue.main.async {
			self.footerViewContainer?.addSubview(footerView)
			self.footerViewContainer.addConstraints([
				NSLayoutConstraint(item: footerView, attribute: .top, relatedBy: .equal, toItem: self.footerViewContainer, attribute: .top, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: footerView, attribute: .left, relatedBy: .equal, toItem: self.footerViewContainer, attribute: .left, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: footerView, attribute: .bottom, relatedBy: .equal, toItem: self.footerViewContainer, attribute: .bottom, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: footerView, attribute: .right, relatedBy: .equal, toItem: self.footerViewContainer, attribute: .right, multiplier: 1, constant: 0)
				])
			self.footerViewContainer.layoutIfNeeded()
		}
	}
	public func showFooter(_ animated: Bool=false) {
		
		DispatchQueue.main.async {
			
			self.childViewContainerBottomConstraint.constant = -(self.footerViewHeightConstraint.constant-10)
			UIViewPropertyAnimator(duration: (animated ? 0.5 : 0) * ANIMATION_SPEED_MODIFIER, dampingRatio: 0.7) {
				self.view.layoutIfNeeded()
				}.startAnimation()
			self.currentViewController?.didShowFooter()
		}
	}
	public func hideFooter(_ animated: Bool=false, completion: (() -> Void)?=nil) {
		DispatchQueue.main.async {
			self.childViewContainerBottomConstraint.constant = 0
			UIViewPropertyAnimator(duration: (animated ? 0.5 : 0) * ANIMATION_SPEED_MODIFIER, dampingRatio: 0.7) {
				self.view.layoutIfNeeded()
				}.startAnimation()
			self.currentViewController?.didHideFooter()
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Navigation
	func push(_ destinationViewController: DroppViewController, animated: Bool=true, popped: Bool=false) {
		
		// disable interaction
		self.view.isUserInteractionEnabled = false
		
		DispatchQueue.main.async {
			
			// add new view controller if it isn't already present (transition is an unwind)
			if !self.childViewControllers.contains(destinationViewController) {
				self.addChildViewController(destinationViewController)
			}
			
			if popped {
				// let the old view controller know it is about to move
				self.currentViewController?.willMove(toParentViewController: nil)
			}
			
			// add new view controller view
			self.addChildView(destinationViewController.view)
			
			// add the button view of the new view controller
			self.addButtonView(destinationViewController.buttonView)
			
			// determine header height delta
			let headerHeightDelta = (destinationViewController.headerHeight + 20) - self.headerViewHeightConstraint.constant
			
			var footerBackButtonSnapshot: UIView?
			
			if let footerView = destinationViewController.footerView {
				
				// add the footer view of the new view controller
				self.addFooterView(footerView)
				
				// prepare footer view for transition in
				footerView.transform = CGAffineTransform(translationX: 0, y: headerHeightDelta >= 0 ? -self.footerViewHeightConstraint.constant : self.footerViewHeightConstraint.constant)
				footerView.alpha = 0
				
			} else {
				
				if self.currentViewController?.footerView == nil {
					
					// take snapshot of footer back button
					footerBackButtonSnapshot = self.footerBackButton.snapshotView(afterScreenUpdates: true)
					self.addFooterView(footerBackButtonSnapshot)
				}
				
				// prepare footer back button for transition in
				self.footerBackButton.transform = CGAffineTransform(translationX: 0, y: headerHeightDelta >= 0 ? -self.footerViewHeightConstraint.constant : self.footerViewHeightConstraint.constant)
				self.footerBackButton.alpha = 0
				
				// adjust footer view back button
				var previousVC: DroppViewController? = self.lastViewController
				if popped {
					if let lastVC = self.lastViewController {
						if let lastVCIndex = self.childViewControllers.index(of: lastVC) {
							if let previousViewController = self.childViewControllers[lastVCIndex-1] as? DroppViewController {
								previousVC = previousViewController
							}
						}
						
					}
				}
				
				if let indicator = previousVC?.indicator {
					self.footerBackButton.setDestinationIndicator(indicator)
					self.footerBackButton.showDestinationIndicator()
				} else {
					self.footerBackButton.hideDestinationIndicator()
				}
				self.footerBackButton.destinationTitle.text = previousVC?.title
				
			}
			
			// prepare new view controller for transition
			destinationViewController.view.transform = CGAffineTransform(translationX: 0, y: headerHeightDelta >= 0 ? -self.buttonViewContainer.frame.height : self.buttonViewContainer.frame.height)
			destinationViewController.buttonView?.transform = CGAffineTransform(translationX: 0, y: headerHeightDelta >= 0 ? -self.buttonViewContainer.frame.height : self.buttonViewContainer.frame.height)
			destinationViewController.view.alpha = 0
			destinationViewController.buttonView?.alpha = 0
			
			
			// animate
			self.headerViewHeightConstraint.constant = destinationViewController.headerHeight + 20
			self.footerViewHeightConstraint.constant = (destinationViewController.footerView?.frame.height ?? 60) + 10
			self.childViewContainerBottomConstraint.constant = -(self.footerViewHeightConstraint.constant - 10)
			let animation = UIViewPropertyAnimator(duration: (animated ? 0.6 : 0) * ANIMATION_SPEED_MODIFIER, dampingRatio: 0.7) {
				
				self.adjustToTheme(preparingFor: destinationViewController)
				
				// adjust header height
				self.headerView.layoutIfNeeded()
				self.headerView.contentView.layoutIfNeeded()
				
				// adjust header label
				self.headerLabel.font = UIFont(name: self.headerLabel.font.fontName, size: destinationViewController.headerLabelSize)
				self.headerLabel.text = destinationViewController.title
				
				// move out old view
				self.currentViewController?.view.transform = CGAffineTransform(translationX: 0, y: headerHeightDelta >= 0 ? self.buttonViewContainer.frame.height : -self.buttonViewContainer.frame.height)
				self.currentViewController?.view.alpha = 0
				
				// move out old button view
				self.currentViewController?.buttonView?.transform = CGAffineTransform(translationX: 0, y: headerHeightDelta >= 0 ? self.buttonViewContainer.frame.height : -self.buttonViewContainer.frame.height)
				self.currentViewController?.buttonView?.alpha = 0
				
				// move out old button view
				self.currentViewController?.footerView?.transform = CGAffineTransform(translationX: 0, y: -self.footerViewHeightConstraint.constant)
				self.currentViewController?.footerView?.alpha = 0
				
				// move in new view
				destinationViewController.view.transform = CGAffineTransform(translationX: 0, y: 0)
				destinationViewController.view.alpha = 1
				
				// move in new button view
				destinationViewController.buttonView?.transform = CGAffineTransform(translationX: 0, y: 0)
				destinationViewController.buttonView?.alpha = 1
				
				// if footer back button snapshot has been taken, then there is no footer view to reveal
				if footerBackButtonSnapshot == nil, let footerView = destinationViewController.footerView {
					
					self.footerBackButton.transform = CGAffineTransform(translationX: 0, y: headerHeightDelta >= 0 ? self.footerViewHeightConstraint.constant : -self.footerViewHeightConstraint.constant)
					self.footerBackButton.alpha = 0
					
					// move in new footer view
					footerView.transform = CGAffineTransform(translationX: 0, y: 0)
					footerView.alpha = 1
					
				} else {
					footerBackButtonSnapshot?.transform = CGAffineTransform(translationX: 0, y: headerHeightDelta >= 0 ? self.footerViewHeightConstraint.constant : -self.footerViewHeightConstraint.constant)
					footerBackButtonSnapshot?.alpha = 0
					
					self.footerBackButton.transform = CGAffineTransform(translationX: 0, y: 0)
					self.footerBackButton.alpha = 1
				}
				
				// adjust footer height
				self.footerViewContainer.layoutIfNeeded()
				self.view.layoutIfNeeded()
			}
			
			//			DispatchQueue.main.async {
			
			if self.lastViewController == nil && !destinationViewController.shouldShowFooter {
				self.hideFooter(animated)
			} else {
				self.showFooter(animated)
			}
			//			}
			
			animation.addCompletion { (position) in
				if position == .end {
					
					footerBackButtonSnapshot?.removeFromSuperview()
					
					// remove old button view
					if let buttonView = self.currentViewController?.buttonView {
						self.currentViewController?.view.addSubview(buttonView)
					}
					
					// remove old footer view
					if let footerView = self.currentViewController?.footerView {
						self.currentViewController?.view.addSubview(footerView)
					}
					
					// remove old view controller view
					self.currentViewController?.view.removeFromSuperview()
					
					if popped {
						// let the old view controller know it is about to move
						self.currentViewController?.removeFromParentViewController()
					}
					
					// let the new view controller know it moved if presentation is not an unwind
					if !self.childViewControllers.contains(destinationViewController) {
						destinationViewController.didMove(toParentViewController: self)
					}
					
					// update current view controller
					self.currentViewController = destinationViewController
					
					self.view.isUserInteractionEnabled = true
				}
			}
			
			animation.startAnimation()
			
		}
	}
	
	@IBAction func pop() {
		guard let lastVC = self.lastViewController else {
			// there doesn't appear to be a last view controller. The pop likely happened due to an error.
			guard let newReleasesViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewReleases") as? NewReleasesViewController else {
				return
			}
			
			self.push(newReleasesViewController)
			return
		}
		
		self.push(lastVC, popped: true)
	}
	
}
