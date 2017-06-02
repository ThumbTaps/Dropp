//
//  DroppChildViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 5/28/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class DroppChildViewController: DroppViewController {

	var navController: DroppNavigationController? {
		return self.parent as? DroppNavigationController
	}
	
	@IBInspectable var headerHeight: CGFloat = 120
	@IBInspectable var headerLabelSize: CGFloat = 30
	
	var indicator: UIView? {
		return nil
	}
	
	@IBOutlet weak var buttonView: UIView?
	
	@IBOutlet weak var footerView: UIView?
	
	var shouldShowFooter: Bool {
		return true
	}
	
	var shouldIgnoreThemeChanges: Bool {
		return false
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let topInset = self.headerHeight + (self.shouldShowFooter ? (self.footerView?.frame.height ?? self.navController?.footerBackButton.frame.height ?? 0) - 10 : 0)
		self.collectionView?.contentInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
		self.collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: topInset, left: 0, bottom: 10, right: 0)

	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
