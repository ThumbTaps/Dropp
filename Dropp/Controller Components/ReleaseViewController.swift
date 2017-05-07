//
//  ReleaseViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 1/13/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ReleaseViewController: DroppViewController {
	
	@IBOutlet weak var releaseArtworkImageView: UIImageView!
	@IBOutlet weak var shareButton: ShareButton!
	@IBOutlet weak var viewOnButton: DroppButton!
	@IBOutlet weak var viewArtworkButton: ViewArtworkButton!
	
	var currentRelease: Release!
	var colorPalette: UIImageColors?
	
	override var indicator: UIView? {
		let emblem = ReleaseArtworkView()
		emblem.shadowed = true
		emblem.imageView?.image = self.currentRelease.thumbnailImage
		return emblem
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		self.title = self.currentRelease.title
		if let characterCount = self.title?.characters.count {
			self.headerHeight = CGFloat(100 + (30 * (CGFloat(characterCount) / (UIScreen.main.bounds.width / 14))))
		}
		
		if self.currentRelease.artist?.isBeingFollowed ?? false {
			
			// load artwork
			_ = self.currentRelease.loadArtwork({
				
				self.currentRelease.artworkImage?.getColors(completionHandler: { (imageColors) in
					self.colorPalette = imageColors
					
					DispatchQueue.main.async {
						
						UIView.transition(with: self.view, duration: 0.3 * ANIMATION_SPEED_MODIFIER, options: .transitionCrossDissolve, animations: {
							self.releaseArtworkImageView.image = self.currentRelease.artworkImage
							self.adjustToTheme()
						}, completion: nil)
					}
				})
			})
			
		} else {
			
			DispatchQueue.main.async {
				
				UIView.transition(with: self.view, duration: 0.3 * ANIMATION_SPEED_MODIFIER, options: .transitionCrossDissolve, animations: {
					self.adjustToTheme()
				}, completion: nil)
			}
		}
		
	}
	
	override func willMove(toParentViewController parent: UIViewController?) {
		
		if parent == nil {
			self.currentRelease.artworkImage = nil
		}
		
		super.willMove(toParentViewController: parent)
	}
	

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	override func adjustToTheme() {
		
		self.navController?.view.tintColor = self.colorPalette?.primaryColor ?? ThemeKit.tintColor
		
		if self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) {
			UIApplication.shared.statusBarStyle = .lightContent
			self.navController?.headerView.effect = UIBlurEffect(style: .dark)
			self.collectionView?.indicatorStyle = .white
			self.navController?.shadowBackdrop.shadowColor = StyleKit.darkShadowColor
			
		} else {
			
			UIApplication.shared.statusBarStyle = .default
			self.navController?.headerView.effect = UIBlurEffect(style: .light)
			self.collectionView?.indicatorStyle = .black
			self.navController?.shadowBackdrop.shadowColor = StyleKit.lightShadowColor

		}
		
		self.navController?.headerLabel.textColor = self.colorPalette?.detailColor ?? ThemeKit.primaryTextColor
		self.navController?.footerViewContainer.backgroundColor = self.colorPalette?.backgroundColor ?? ThemeKit.backgroundColor
		self.navController?.footerBackButton.destinationTitle.textColor = self.colorPalette?.detailColor ?? ThemeKit.primaryTextColor
		self.collectionView?.backgroundColor = self.colorPalette?.backgroundColor.withAlpha(0.8) ?? ThemeKit.backdropOverlayColor
		
		self.collectionView?.reloadData()
		
	}
	
	@IBAction func viewOn(_ sender: Any) {
		UIApplication.shared.open(self.currentRelease.itunesURL, options: [:], completionHandler: nil)
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


extension ReleaseViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	// MARK: - UICollectionViewDataSource
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.currentRelease.tracks?.count ?? 0
	}
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ReleaseCollectionViewHeader", for: indexPath) as? HeaderCollectionReusableView
		
		reusableView?.backgroundColor = self.colorPalette?.backgroundColor.withAlpha(0.8) ?? ThemeKit.backdropOverlayColor
		reusableView?.textLabel.textColor = self.colorPalette?.detailColor ?? ThemeKit.primaryTextColor
		reusableView?.strokeColor = self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) ? StyleKit.darkStrokeColor : StyleKit.lightStrokeColor
		
		return reusableView ?? UICollectionReusableView()
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReleaseTrackCell", for: indexPath) as? ReleaseTrackCollectionViewCell
		
		cell?.trackNumberLabel.text = "\(indexPath.row + 1)."
		cell?.trackTitleLabel.text = self.currentRelease.tracks?[indexPath.row].title
		
		cell?.trackTitleLabel.textColor = self.colorPalette?.detailColor ?? ThemeKit.primaryTextColor
		cell?.trackNumberLabel.textColor = self.colorPalette?.detailColor.withAlpha(0.5) ?? ThemeKit.secondaryTextColor
		cell?.backgroundColor = self.colorPalette?.backgroundColor.withAlpha(0.8) ?? ThemeKit.backdropOverlayColor
		cell?.selectedBackgroundView?.backgroundColor = self.colorPalette?.primaryColor.withAlpha(0.4) ?? ThemeKit.tintColor.withAlpha(0.4)
		cell?.strokeColor = self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) ? StyleKit.darkStrokeColor : StyleKit.lightStrokeColor
		
		return cell ?? UICollectionViewCell()
	}
	
	
	
	// MARK: - UICollectionViewDelegateFlowLayout
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		
		return CGSize(width: collectionView.frame.width, height: 50)
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		return CGSize(width: collectionView.frame.size.width, height: 50)
	}
	
}
