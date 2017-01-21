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

//    @IBOutlet weak var backButton: BackButton?
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
		Notification.Name.UrsusThemeDidChange.add(self, selector: #selector(self.themeDidChange))
		
		self.collectionView?.contentInset = UIEdgeInsets(top: (self.topScrollFadeView?.frame.height ?? 120) - 40, left: 0, bottom: 80, right: 0)

    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
        // This can't be a direct call to self.themeDidChange because it will trigger on other view controllers that may want to animate in certain properties
        DispatchQueue.main.async {
            
            self.setNeedsStatusBarAppearanceUpdate()
            
            if PreferenceManager.shared.theme == .dark {
                self.view.tintColor = StyleKit.darkTintColor
                self.topScrollFadeView?.tintColor = StyleKit.darkBackdropOverlayColor
                self.bottomScrollFadeView?.tintColor = StyleKit.darkBackdropOverlayColor
                self.navigationTitle?.textColor = StyleKit.darkPrimaryTextColor
            } else {
                self.view.tintColor = StyleKit.lightTintColor
                self.topScrollFadeView?.tintColor = StyleKit.lightBackdropOverlayColor
                self.bottomScrollFadeView?.tintColor = StyleKit.lightBackdropOverlayColor
                self.navigationTitle?.textColor = StyleKit.lightPrimaryTextColor
            }
            
        }
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if self.navigationTitle != nil {
			// move navigation title in
			self.backdrop?.overlay.removeConstraint(self.navigationTitleHidingConstraint!)
			self.backdrop?.overlay.addConstraint(self.navigationTitleRestingConstraint!)
			
			DispatchQueue.main.async {
				UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
					self.view.layoutIfNeeded()
				})
			}
		}
		
		

	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    // MARK: - Custom Methods
//    func showBackButton() {
//        
//        if self.backButtonHidingConstraint != nil {
//            
//            self.view.removeConstraint(self.backButtonHidingConstraint!)
//        }
//        if self.backButtonVisibleLeadingConstraint != nil && self.backButtonVisibleTrailingConstraint != nil {
//            
//            self.view.addConstraints([self.backButtonVisibleLeadingConstraint!, self.backButtonVisibleTrailingConstraint!])
//        }
//        
//        UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.6, options: .curveEaseOut, animations: { 
//            self.view.layoutIfNeeded()
//        })
//    }
//    func hideBackButton() {
//        
//        if self.backButtonVisibleLeadingConstraint != nil && self.backButtonVisibleTrailingConstraint != nil {
//            
//            self.view.removeConstraints([self.backButtonVisibleLeadingConstraint!, self.backButtonVisibleTrailingConstraint!])
//        }
//        if self.backButtonHidingConstraint != nil {
//            
//            self.view.addConstraint(self.backButtonHidingConstraint!)
//        }
//        
//        UIView.animate(withDuration: 0.6, delay: 0, options: .curveEaseOut, animations: {
//            self.view.layoutIfNeeded()
//        })
//    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		get {
			if PreferenceManager.shared.theme == .dark {
				return .lightContent
			} else {
				return .default
			}
		}
	}

	
	
	
	// MARK: - PreferenceManager Delegate
	func themeDidChange() {
		
		DispatchQueue.main.async {
			
			self.setNeedsStatusBarAppearanceUpdate()
			
			if PreferenceManager.shared.theme == .dark {
				self.view.tintColor = StyleKit.darkTintColor
				self.topScrollFadeView?.tintColor = StyleKit.darkBackdropOverlayColor
				self.bottomScrollFadeView?.tintColor = StyleKit.darkBackdropOverlayColor
				self.navigationTitle?.textColor = StyleKit.darkPrimaryTextColor
			} else {
				self.view.tintColor = StyleKit.lightTintColor
				self.topScrollFadeView?.tintColor = StyleKit.lightBackdropOverlayColor
				self.bottomScrollFadeView?.tintColor = StyleKit.lightBackdropOverlayColor
				self.navigationTitle?.textColor = StyleKit.lightPrimaryTextColor
			}
			
		}
	}
	
	
	
	
	
	
	@IBAction func prepareForUnwind(for segue: UIStoryboardSegue) {
	}

}
