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
		PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
		
		if PreferenceManager.shared.followingArtists.isEmpty {
			
			// show search bar
			if PreferenceManager.shared.firstLaunch {
				if let searchViewController = self.storyboard?.instantiateViewController(withIdentifier: "ArtistSearch") as? ArtistSearchViewController {
					
					self.push(searchViewController, animated: false)
				}
				
				PreferenceManager.shared.firstLaunch = false
			}
			
		}
		
	}
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.view.layer.cornerRadius = 12
		self.childViewContainer.layer.cornerRadius = 12
		
		self.themeDidChange()
	}
	
	func themeDidChange() {
		DispatchQueue.main.async {
			
			UIApplication.shared.keyWindow?.backgroundColor = ThemeKit.backgroundColor
			UIApplication.shared.statusBarStyle = ThemeKit.statusBarStyle
			self.view.tintColor = ThemeKit.tintColor
			self.view.backgroundColor = ThemeKit.backgroundColor
			self.childViewContainer.backgroundColor = ThemeKit.backgroundColor
			self.headerView.effect = UIBlurEffect(style: ThemeKit.blurEffectStyle)
			self.footerViewContainer.backgroundColor = ThemeKit.backgroundColor
			self.headerLabel.textColor = ThemeKit.primaryTextColor
			self.currentViewController?.themeDidChange()
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
				NSLayoutConstraint(item: footerView, attribute: .top, relatedBy: .equal, toItem: self.footerViewContainer, attribute: .top, multiplier: 1, constant: 10),
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
	public func hideFooter(_ animated: Bool=false) {
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
	func push(_ childViewController: DroppViewController, animated: Bool=true, popped: Bool=false) {
		
		// disable interaction
		self.view.isUserInteractionEnabled = false
		
		DispatchQueue.main.async {
			if popped {
				// let the old view controller know it is about to move
				self.currentViewController?.willMove(toParentViewController: nil)
			}
			
			// add new view controller
			if !self.childViewControllers.contains(childViewController) {
				self.addChildViewController(childViewController)
			}
			
			// add new view controller view
			self.addChildView(childViewController.view)
			
			// add the button view of the new view controller
			self.addButtonView(childViewController.buttonView)
			
			// determine header height delta
			let headerHeightDelta = (childViewController.headerHeight + 20) - self.headerViewHeightConstraint.constant
			
			var footerBackButtonSnapshot: UIView?
			
			if let footerView = childViewController.footerView {
				
				// add the footer view of the new view controller
				self.addFooterView(footerView)
				
				// prepare footer view for transition in
				footerView.transform = CGAffineTransform(translationX: 0, y: headerHeightDelta > 0 ? -self.footerViewHeightConstraint.constant : self.footerViewHeightConstraint.constant)
				
			} else {
				
				if self.currentViewController?.footerView == nil {
					
					// take snapshot of footer back button
					footerBackButtonSnapshot = self.footerBackButton.snapshotView(afterScreenUpdates: true)
					self.addFooterView(footerBackButtonSnapshot)
				}
				
				// prepare footer back button for transition in
				self.footerBackButton.transform = CGAffineTransform(translationX: 0, y: headerHeightDelta > 0 ? -self.footerViewHeightConstraint.constant : self.footerViewHeightConstraint.constant)
				
				// adjust footer view back button
				if let backButton = self.lastViewController?.backButton {
					self.footerBackButton.setDestinationButton(button: backButton)
					self.footerBackButton.showDestinationButton()
				} else {
					self.footerBackButton.hideDestinationButton()
				}
				self.footerBackButton.destinationTitle.text = self.lastViewController?.title
				
			}
			
			// prepare new view controller for transition
			childViewController.view.transform = CGAffineTransform(translationX: 0, y: headerHeightDelta > 0 ? -abs(headerHeightDelta) : abs(headerHeightDelta))
			childViewController.buttonView?.transform = CGAffineTransform(translationX: 0, y: headerHeightDelta > 0 ? -self.buttonViewContainer.frame.height : self.buttonViewContainer.frame.height)
			childViewController.view.alpha = 0
			childViewController.buttonView?.alpha = 0
			
			
			// animate
			self.headerViewHeightConstraint.constant = childViewController.headerHeight + 20
			self.footerViewHeightConstraint.constant = (childViewController.footerView?.frame.height ?? 60) + 10
			let animation = UIViewPropertyAnimator(duration: (animated ? 0.6 : 0) * ANIMATION_SPEED_MODIFIER, dampingRatio: 0.7) {
				
				// adjust header height
				self.headerView.layoutIfNeeded()
				
				// adjust header label
				self.headerLabel.font = UIFont(name: self.headerLabel.font.fontName, size: childViewController.headerLabelSize)
				self.headerLabel.text = childViewController.title
				
				// move out old view
				self.currentViewController?.view.transform = CGAffineTransform(translationX: 0, y: headerHeightDelta)
				self.currentViewController?.view.alpha = 0
				
				// move out old button view
				self.currentViewController?.buttonView?.transform = CGAffineTransform(translationX: 0, y: headerHeightDelta < 0 ? -self.buttonViewContainer.frame.height/2 : self.buttonViewContainer.frame.height/2)
				self.currentViewController?.buttonView?.alpha = 0
				
				// move out old button view
				self.currentViewController?.footerView?.transform = CGAffineTransform(translationX: 0, y: -self.footerViewHeightConstraint.constant)
				self.currentViewController?.footerView?.alpha = 0
				
				// move in new view
				childViewController.view.transform = CGAffineTransform(translationX: 0, y: 0)
				childViewController.view.alpha = 1
				
				// move in new button view
				childViewController.buttonView?.transform = CGAffineTransform(translationX: 0, y: 0)
				childViewController.buttonView?.alpha = 1
				
				// if footer back button snapshot has been taken, then there is no footer view to reveal
				if footerBackButtonSnapshot == nil, let footerView = childViewController.footerView {
					
					// move in new footer view
					footerView.transform = CGAffineTransform(translationX: 0, y: 0)
					
					self.footerBackButton.transform = CGAffineTransform(translationX: 0, y: headerHeightDelta > 0 ? self.footerViewHeightConstraint.constant : -self.footerViewHeightConstraint.constant)
					
				} else {
					footerBackButtonSnapshot?.transform = CGAffineTransform(translationX: 0, y: headerHeightDelta > 0 ? self.footerViewHeightConstraint.constant : -self.footerViewHeightConstraint.constant)
					
					self.footerBackButton.transform = CGAffineTransform(translationX: 0, y: 0)
				}
				
				// adjust footer height
				self.footerViewContainer.layoutIfNeeded()
				
			}
			
			DispatchQueue.main.async {
				
				if self.lastViewController != nil || childViewController.shouldShowFooter {
					self.showFooter(animated)
				} else {
					self.hideFooter(animated)
				}
			}
			
			animation.addCompletion { (position) in
				if position == .end {
					
					footerBackButtonSnapshot?.removeFromSuperview()
					
					if popped {
						// let the old view controller know it is about to move
						self.currentViewController?.removeFromParentViewController()
					}
					
					// remove old view controller view
					self.currentViewController?.view.removeFromSuperview()
					
					// remove old button view
					if let buttonView = self.currentViewController?.buttonView {
						self.currentViewController?.view.addSubview(buttonView)
					}
					
					// remove old footer view
					if let footerView = self.currentViewController?.footerView {
						self.currentViewController?.view.addSubview(footerView)
					}
					
					// let the new view controller know it moved
					if !self.childViewControllers.contains(childViewController) {
						childViewController.didMove(toParentViewController: self)
					}
					
					// update current view controller
					self.currentViewController = childViewController
					
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
