//
//  ArtistViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson on 11/15/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ArtistViewController: DroppViewController {
	
	@IBOutlet weak var artistArtworkImageView: UIImageView!
	@IBOutlet weak var followButton: DroppButton!
	@IBOutlet weak var viewOnButton: DroppButton!
	@IBOutlet weak var viewArtworkButton: ViewArtworkButton!
	
	var currentArtist: Artist!
	private var palette: UIImageColors?
	var colorPalette: UIImageColors? {
		set {
			self.palette = newValue
		}
		get {
			if !PreferenceManager.shared.adaptiveArtistView {
				return nil
			}
			
			return self.palette
		}
	}
	
	var latestReleaseArtworkTask: URLSessionDataTask?
	
	override var indicator: UIView? {
		let emblem = ArtistArtworkView()
		emblem.shadowed = true
		emblem.imageView?.image = self.currentArtist.thumbnailImage
		return emblem
	}
	
	override var shouldIgnoreThemeChanges: Bool {
		return true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = self.currentArtist.name
		self.headerHeight = CGFloat(180 + (self.title!.characters.count - 80))
		
		self.followingStatusDidChange()
		
		if let flowLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
			flowLayout.itemSize = UICollectionViewFlowLayoutAutomaticSize
		}
	}
	
	override func willMove(toParentViewController parent: UIViewController?) {
		
		if parent == nil {
			self.currentArtist.artworkImage = nil
		}
		
		super.willMove(toParentViewController: parent)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	override func adjustToTheme() {
		
		self.navController?.view.tintColor = self.colorPalette?.primaryColor ?? ThemeKit.tintColor
		self.view.tintColor = self.colorPalette?.primaryColor ?? ThemeKit.tintColor
		
		if self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) {
			UIApplication.shared.statusBarStyle = .lightContent
			self.navController?.headerView.effect = UIBlurEffect(style: .dark)
			self.collectionView?.indicatorStyle = .white
			self.navController?.shadowBackdrop.shadowColor = StyleKit.darkShadowColor
			self.navController?.footerViewContainer.backgroundColor = self.colorPalette?.backgroundColor.withBrightness(0.25) ?? ThemeKit.backgroundColor
			self.collectionView?.backgroundColor = self.colorPalette?.backgroundColor.withBrightness(0.25).withAlpha(0.8) ?? ThemeKit.backdropOverlayColor

		} else {
			
			UIApplication.shared.statusBarStyle = .default
			self.navController?.headerView.effect = UIBlurEffect(style: .light)
			self.collectionView?.indicatorStyle = .black
			self.navController?.shadowBackdrop.shadowColor = StyleKit.lightShadowColor
			self.navController?.footerViewContainer.backgroundColor = self.colorPalette?.backgroundColor ?? ThemeKit.backgroundColor
			self.collectionView?.backgroundColor = self.colorPalette?.backgroundColor.withAlpha(0.8) ?? ThemeKit.backdropOverlayColor
		}
		
		self.navController?.headerLabel.textColor = self.colorPalette?.detailColor ?? ThemeKit.primaryTextColor
		self.navController?.footerViewContainer.backgroundColor = self.colorPalette?.backgroundColor ?? ThemeKit.backgroundColor
		self.navController?.footerBackButton.destinationTitle.textColor = self.colorPalette?.detailColor ?? ThemeKit.primaryTextColor
		
		self.collectionView?.reloadData()
	}
	func followingStatusDidChange() {
		
		if !self.currentArtist.isBeingFollowed {
			
			DispatchQueue.main.async {
				self.followButton.setTitle("Follow", for: .normal)
				
				UIView.transition(with: self.view, duration: 0.3 * ANIMATION_SPEED_MODIFIER, options: .transitionCrossDissolve, animations: {
					self.followButton.tintColor = ThemeKit.tintColor
					self.artistArtworkImageView.image = nil
					self.colorPalette = nil
					self.adjustToTheme()
					
				}, completion: nil)
			}
			
		} else {
			
			DispatchQueue.main.async {
				self.followButton.setTitle("Unfollow", for: .normal)
				
				_ = self.currentArtist.loadArtwork {
					self.currentArtist.artworkImage?.getColors(completionHandler: { (imageColors) in
						self.colorPalette = imageColors
						self.followButton.tintColor = self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) ? StyleKit.darkStrokeColor : StyleKit.lightStrokeColor
						
						UIView.transition(with: self.view, duration: 0.3 * ANIMATION_SPEED_MODIFIER, options: .transitionCrossDissolve, animations: {
							self.artistArtworkImageView.image = self.currentArtist.artworkImage
							self.adjustToTheme()
							
						}, completion: nil)
					})
				}
			}
		}
	}
	
	
	
	
	
	// MARK: - IBActions
	@IBAction func toggleFollowing(_ sender: Any) {
		
		if self.currentArtist.isBeingFollowed {
			PreferenceManager.shared.unfollow(artist: self.currentArtist)
		} else {
			PreferenceManager.shared.follow(artist: self.currentArtist)
		}
		
		self.followingStatusDidChange()
	}
	@IBAction func toggleIncludeSingles(_ sender: UISwitch) {
		self.currentArtist.includeSingles = sender.isOn
		self.collectionView?.performBatchUpdates({
			self.collectionView?.reloadSections([(self.collectionView?.numberOfSections ?? 3) - 1])
		})
	}
	@IBAction func toggleIgnoreFeatures(_ sender: UISwitch) {
		self.currentArtist.ignoreFeatures = sender.isOn
	}
	@IBAction func toggleIncludeEPs(_ sender: UISwitch) {
		self.currentArtist.includeEPs = sender.isOn
	}
	@IBAction func viewOn(_ sender: Any) {
		UIApplication.shared.open(self.currentArtist.itunesURL, options: [:], completionHandler: nil)
	}
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		
		if segue.identifier == "showLatestRelease" {
			// set current release
			(segue.destination as? ReleaseViewController)?.currentRelease = self.currentArtist.latestRelease
		}

	}
}

extension ArtistViewController: UICollectionViewDataSourcePrefetching, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	// MARK: UICollectionViewDataSourcePrefetching
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		
		self.latestReleaseArtworkTask = self.currentArtist.latestRelease?.loadArtwork()
	}
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		
		self.latestReleaseArtworkTask?.cancel()
	}
	
	
	
	
	// MARK: - UICollectionViewDataSource
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		var numSections = 0
		if self.currentArtist.latestRelease != nil { numSections += 1 }
		if self.currentArtist.summary != nil { numSections += 1 }
		if self.currentArtist.isBeingFollowed { numSections += 1 }
		
		return numSections
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		var numItems = 0
		switch section {
		case 0:
			if self.currentArtist.latestRelease != nil { numItems += 1 }
			break
		case 1:
			if self.currentArtist.summary != nil { numItems += 1 }
			break
		case 2:
			if self.currentArtist.isBeingFollowed {
				numItems += 2
				if self.currentArtist.includeSingles ?? PreferenceManager.shared.includeSingles {
					numItems += 1
				}
			}
			break
		default: break
		}
		
		return numItems
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		var cell = DroppCollectionViewCell()
		
		// LATEST RELEASE SECTION
		if self.currentArtist.latestRelease != nil && indexPath.section == 0 {
			
			let latestReleaseCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LatestReleaseCell", for: indexPath) as! ReleaseCollectionViewCell
			
			latestReleaseCell.releaseTitleLabel.text = self.currentArtist.latestRelease!.title

			let dateFormatter = DateFormatter()
			dateFormatter.dateFormat = "MMM d, YYYY"
			dateFormatter.timeZone = .current
			latestReleaseCell.secondaryLabel.text = "Released on \(dateFormatter.string(from: self.currentArtist.latestRelease!.releaseDate))"
			
			latestReleaseCell.releaseTitleLabel.textColor = self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) ? StyleKit.darkPrimaryTextColor : StyleKit.lightPrimaryTextColor
			latestReleaseCell.secondaryLabel.textColor = self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) ? StyleKit.darkSecondaryTextColor : StyleKit.lightSecondaryTextColor
			latestReleaseCell.releaseArtworkView.hideArtwork()
			
			if self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) {
				latestReleaseCell.releaseArtworkView.shadow?.shadowColor = StyleKit.darkShadowColor
			} else {
				latestReleaseCell.releaseArtworkView.shadow?.shadowColor = StyleKit.lightShadowColor
			}
			
			latestReleaseCell.releaseArtworkView.backgroundColor = self.colorPalette?.backgroundColor ?? ThemeKit.backgroundColor
			
			_ = self.currentArtist.latestRelease!.loadArtwork {
				
				DispatchQueue.main.async {
					
					latestReleaseCell.releaseArtworkView.imageView.image = self.currentArtist.latestRelease?.thumbnailImage
					if latestReleaseCell.releaseArtworkView.imageView.image != nil {
						latestReleaseCell.releaseArtworkView.showArtwork(true)
					}
				}
			}
			
		}
		
		// SUMMARY SECTION
		if self.currentArtist.summary != nil &&
			((indexPath.section == 0 && self.currentArtist.latestRelease == nil) ||
				(indexPath.section == 1 && self.currentArtist.latestRelease != nil)) {
			
			switch indexPath.row {
			case 0:
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistSummaryCell", for: indexPath) as! TextAreaCollectionViewCell
				(cell as? TextAreaCollectionViewCell)?.textView.text = self.currentArtist.summary
				(cell as? TextAreaCollectionViewCell)?.textView.textColor = self.colorPalette?.detailColor ?? ThemeKit.primaryTextColor
				
				break
				
			default: break
			}
			
		}
		
		// RELEASE OPTIONS
		if PreferenceManager.shared.followingArtists.contains(where: { $0.itunesID == self.currentArtist.itunesID }) &&
			((indexPath.section == 0 && self.currentArtist.latestRelease == nil && self.currentArtist.summary == nil) ||
				(indexPath.section == 1 && self.currentArtist.summary == nil) ||
				indexPath.section == 2) {
			
			switch indexPath.row {
			case 0: // IGNORE SINGLES
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IncludeSinglesCell", for: indexPath) as! SettingsCollectionViewCell
				((cell as? SettingsCollectionViewCell)?.accessoryView as? UISwitch)?.isOn = self.currentArtist.includeSingles ?? PreferenceManager.shared.includeSingles
				break
				
			case 1: // INCLUDE EPS / IGNORE FEATURES
				if self.currentArtist.includeSingles ?? PreferenceManager.shared.includeSingles {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IgnoreFeaturesCell", for: indexPath) as! SettingsCollectionViewCell
					((cell as? SettingsCollectionViewCell)?.accessoryView as? UISwitch)?.isOn = self.currentArtist.ignoreFeatures ?? PreferenceManager.shared.ignoreFeatures
				} else {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IncludeEPsCell", for: indexPath) as! SettingsCollectionViewCell
					((cell as? SettingsCollectionViewCell)?.accessoryView as? UISwitch)?.isOn = self.currentArtist.includeEPs ?? PreferenceManager.shared.includeEPs
				}
				break
				
			case 2: // INCLUDE EPS
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IncludeEPsCell", for: indexPath) as! SettingsCollectionViewCell
				((cell as? SettingsCollectionViewCell)?.accessoryView as? UISwitch)?.isOn = self.currentArtist.includeEPs ?? PreferenceManager.shared.includeEPs
				break
			default: break
			}
			
			(cell as? SettingsCollectionViewCell)?.textLabel?.textColor = self.colorPalette?.detailColor ?? ThemeKit.primaryTextColor
			((cell as? SettingsCollectionViewCell)?.accessoryView as? UISwitch)?.onTintColor = self.view.tintColor
		}
		
		cell.strokeColor = self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) ? StyleKit.darkStrokeColor : StyleKit.lightStrokeColor
		cell.backgroundColor = self.colorPalette?.backgroundColor.withAlpha(0.8) ?? ThemeKit.backdropOverlayColor
		cell.selectedBackgroundView?.backgroundColor = self.colorPalette?.primaryColor.withAlpha(0.2) ?? ThemeKit.tintColor.withAlpha(0.2)
		
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		guard let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ArtistCollectionViewHeader", for: indexPath) as? HeaderCollectionReusableView else {
			return UICollectionReusableView()
		}
		
		if self.currentArtist.latestRelease != nil &&
			indexPath.section == 0 {
			
			// LATEST RELEASE SECTION
			reusableView.textLabel.text = "LATEST RELEASE"
			
		}
		
		if self.currentArtist.summary != nil &&
			((indexPath.section == 0 && self.currentArtist.latestRelease == nil) ||
				(indexPath.section == 1 && self.currentArtist.latestRelease != nil)) {
			
			// ADDITIONAL INFO SECTION
			reusableView.textLabel.text = "SUMMARY"
		}
		
		if self.currentArtist.isBeingFollowed &&
			((indexPath.section == 0 && self.currentArtist.latestRelease == nil && self.currentArtist.summary == nil) ||
				(indexPath.section == 1 && self.currentArtist.summary == nil) ||
				indexPath.section == 2) {
			
			// RELEASE OPTIONS
			reusableView.textLabel.text = "RELEASE OPTIONS"
		}
		
		reusableView.backgroundColor = self.colorPalette?.backgroundColor.withAlpha(0.8) ?? ThemeKit.backdropOverlayColor
		reusableView.textLabel.textColor = self.colorPalette?.detailColor ?? ThemeKit.primaryTextColor
		reusableView.strokeColor = self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) ? StyleKit.darkStrokeColor : StyleKit.lightStrokeColor
		
		return reusableView
	}
	
	
	// MARK: - UICollectionViewDelegate
	func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		guard let cell = collectionView.cellForItem(at: indexPath) else {
			return false
		}
		
		return cell.reuseIdentifier == "LatestReleaseCell"
	}
	
	
	// MARK: - UICollectionViewDelegateFlowLayout
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: self.view.bounds.width, height: 50)
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		var size = CGSize(width: collectionView.bounds.width, height: 100)
		
		if self.currentArtist.latestRelease != nil &&
			indexPath.section == 0 {
			
			// LATEST RELEASE SECTION
		}
		
		if self.currentArtist.summary != nil &&
			((indexPath.section == 0 && self.currentArtist.latestRelease == nil) ||
				(indexPath.section == 1 && self.currentArtist.latestRelease != nil)) {
			
			// SUMMARY SECTION
			size = (collectionView.cellForItem(at: indexPath) as? TextAreaCollectionViewCell)?.contentView.systemLayoutSizeFitting(UILayoutFittingCompressedSize) ?? size
		}
		
		if PreferenceManager.shared.followingArtists.contains(where: { $0.itunesID == self.currentArtist.itunesID }) &&
			((indexPath.section == 0 && self.currentArtist.latestRelease == nil && self.currentArtist.summary == nil) ||
				(indexPath.section == 1 && self.currentArtist.summary == nil) ||
				indexPath.section == 2) {
			
			// RELEASE OPTIONS
			size = CGSize(width: collectionView.bounds.width, height: 50)
		}
		
		return size
	}
}
