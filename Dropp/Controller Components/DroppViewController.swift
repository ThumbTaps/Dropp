//
//  DroppViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 12/1/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class DroppViewController: UIViewController {
	
	@IBOutlet weak var collectionView: UICollectionView?
	
    override func viewDidLoad() {
        super.viewDidLoad()
						
		PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.adjustToTheme))
		
		// start listening for new releases updates
		PreferenceManager.shared.didUpdateReleasesNotification.add(self, selector: #selector(self.didUpdateReleases))
		
		if let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
			layout.sectionHeadersPinToVisibleBounds = true
		}		
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		self.adjustToTheme()
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		// deselect any collection view cells
		if let selectedIndexPaths = self.collectionView?.indexPathsForSelectedItems {
			if !selectedIndexPaths.isEmpty {
				self.collectionView?.deselectItem(at: selectedIndexPaths[0], animated: true)
			}
		}

	}
	

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
	
	
	
	
	// MARK: - Notifications
	func didUpdateReleases() {
		
		// show banner if not on new releases view somehow... eheh
		
	}
	func adjustToTheme() {
		self.view.tintColor = ThemeKit.tintColor
		self.view.backgroundColor = ThemeKit.backgroundColor
		self.collectionView?.indicatorStyle = ThemeKit.indicatorStyle
		self.collectionView?.reloadData()
	}	
}

extension UIView {
	
	func enableParallax(amount: Int=30) {
		
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
