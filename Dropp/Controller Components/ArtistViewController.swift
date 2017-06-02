//
//  ArtistViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson on 11/15/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ArtistViewController: DroppModalViewController {
	
	@IBOutlet weak var artistNameLabel: UILabel!
	@IBOutlet weak var artistArtworkView: ArtistArtworkView!
	@IBOutlet weak var followButton: DroppButton!
	@IBOutlet weak var viewOnButton: DroppButton!
	
	var currentArtist: Artist!
	
	var latestReleaseArtworkTask: URLSessionDataTask?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.artistNameLabel.text = self.currentArtist.name
		
		_ = self.currentArtist.loadArtwork {
			
			self.artistArtworkView.imageView.image = self.currentArtist.artworkImage
			self.artistArtworkView.showArtwork(false)
		}
		
		if !UIAccessibilityIsReduceMotionEnabled() {
			self.artistArtworkView.enableParallax(amount: 15)
		}
		
		self.followingStatusDidChange()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		self.currentArtist.artworkImage = nil
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	override func adjustToTheme() {
		super.adjustToTheme()
		
		DispatchQueue.main.async {
			
			self.view.tintColor = self.currentArtist.colorPalette?.detailColor.highlight(withLevel: 0.35) ?? ThemeKit.tintColor
			
			self.artistNameLabel.textColor = ThemeKit.primaryTextColor
			
			if self.currentArtist.isBeingFollowed {
				self.followButton.tintColor = self.currentArtist.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) ? StyleKit.darkStrokeColor : StyleKit.lightStrokeColor
			} else {
				self.followButton.tintColor = self.view.tintColor
			}
		}
	}
	func followingStatusDidChange() {
		
		DispatchQueue.main.async {
			if self.currentArtist.isBeingFollowed {
				self.followButton.setTitle("Unfollow", for: .normal)
			} else {
				self.followButton.setTitle("Follow", for: .normal)
			}
			
			UIViewPropertyAnimator(duration: 0.2 * ANIMATION_SPEED_MODIFIER, curve: .linear, animations: {
				
				if self.currentArtist.isBeingFollowed {
					self.followButton.tintColor = self.currentArtist.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) ? StyleKit.darkStrokeColor : StyleKit.lightStrokeColor
				} else {
					self.followButton.tintColor = self.view.tintColor
				}
			}).startAnimation()
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
			
			latestReleaseCell.releaseTitleLabel.textColor = self.currentArtist.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) ? StyleKit.darkPrimaryTextColor : StyleKit.lightPrimaryTextColor
			latestReleaseCell.secondaryLabel.textColor = self.currentArtist.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) ? StyleKit.darkSecondaryTextColor : StyleKit.lightSecondaryTextColor
			latestReleaseCell.releaseArtworkView.hideArtwork()
			
			if self.currentArtist.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) {
				latestReleaseCell.releaseArtworkView.shadow?.shadowColor = StyleKit.darkShadowColor
			} else {
				latestReleaseCell.releaseArtworkView.shadow?.shadowColor = StyleKit.lightShadowColor
			}
			
			latestReleaseCell.releaseArtworkView.backgroundColor = self.currentArtist.colorPalette?.backgroundColor ?? ThemeKit.backgroundColor
			
			_ = self.currentArtist.latestRelease!.loadArtwork {
				
				//				DispatchQueue.main.async {
				
				latestReleaseCell.releaseArtworkView.imageView.image = self.currentArtist.latestRelease?.thumbnailImage
				if latestReleaseCell.releaseArtworkView.imageView.image != nil {
					latestReleaseCell.releaseArtworkView.showArtwork(true)
				}
				//				}
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
				(cell as? TextAreaCollectionViewCell)?.textView.textColor = self.currentArtist.colorPalette?.detailColor ?? ThemeKit.primaryTextColor
				
				break
				
			default: break
			}
			
		}
		
		// RELEASE OPTIONS
		if self.currentArtist.isBeingFollowed &&
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
			
			(cell as? SettingsCollectionViewCell)?.textLabel?.textColor = self.currentArtist.colorPalette?.detailColor ?? ThemeKit.primaryTextColor
			((cell as? SettingsCollectionViewCell)?.accessoryView as? UISwitch)?.onTintColor = self.view.tintColor
		}
		
		cell.strokeColor = self.currentArtist.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) ? StyleKit.darkStrokeColor : StyleKit.lightStrokeColor
		cell.backgroundColor = self.currentArtist.colorPalette?.backgroundColor.withAlpha(0.8) ?? ThemeKit.backdropOverlayColor
		cell.selectedBackgroundView?.backgroundColor = self.currentArtist.colorPalette?.primaryColor.withAlpha(0.2) ?? ThemeKit.tintColor.withAlpha(0.2)
		
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
		
		reusableView.backgroundColor = self.currentArtist.colorPalette?.backgroundColor.withAlpha(0.8) ?? ThemeKit.backdropOverlayColor
		reusableView.textLabel.textColor = self.currentArtist.colorPalette?.detailColor ?? ThemeKit.primaryTextColor
		reusableView.strokeColor = self.currentArtist.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) ? StyleKit.darkStrokeColor : StyleKit.lightStrokeColor
		
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
		
		if self.currentArtist.isBeingFollowed &&
			((indexPath.section == 0 && self.currentArtist.latestRelease == nil && self.currentArtist.summary == nil) ||
				(indexPath.section == 1 && self.currentArtist.summary == nil) ||
				indexPath.section == 2) {
			
			// RELEASE OPTIONS
			size = CGSize(width: collectionView.bounds.width, height: 50)
		}
		
		return size
	}
}
