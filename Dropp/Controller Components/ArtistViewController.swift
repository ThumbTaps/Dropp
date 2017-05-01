//
//  ArtistViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson on 11/15/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ArtistViewController: DroppViewController {
	
	@IBOutlet weak var artistImageView: UIImageView!
	
	@IBOutlet weak var followButton: DroppButton!
	
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
	
	override var backButton: DroppButton? {
		let artistButton = ArtistsButton()
		artistButton.tintColor = self.colorPalette?.primaryColor
		return artistButton
	}
	
	override var shouldIgnoreThemeChanges: Bool {
		return true
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = self.currentArtist.name
		self.headerHeight = CGFloat(180 + (self.title!.characters.count - 80))
		
		DispatchQueue.main.async {
			
			if PreferenceManager.shared.followingArtists.contains(where: { $0.itunesID == self.currentArtist.itunesID }) {
				self.followButton.setTitle("Unfollow", for: .normal)
				self.followButton.tintColor = ThemeKit.strokeColor
			}
			
		}
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(true)
		
		self.currentArtist = nil
		self.colorPalette = nil
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	override func adjustToTheme() {
		DispatchQueue.main.async {
			
			self.navController?.view.tintColor = self.colorPalette?.primaryColor ?? ThemeKit.tintColor
			
			if self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) {
				UIApplication.shared.statusBarStyle = .lightContent
				self.navController?.headerView.effect = UIBlurEffect(style: .dark)
				self.collectionView?.indicatorStyle = .white
				
			} else {
				
				UIApplication.shared.statusBarStyle = .default
				self.navController?.headerView.effect = UIBlurEffect(style: .light)
				self.collectionView?.indicatorStyle = .black
			}
			
			self.navController?.headerLabel.textColor = self.colorPalette?.detailColor ?? ThemeKit.primaryTextColor
			self.navController?.footerViewContainer.backgroundColor = self.colorPalette?.backgroundColor ?? ThemeKit.backgroundColor
			self.navController?.footerBackButton.destinationTitle.textColor = self.colorPalette?.detailColor ?? ThemeKit.primaryTextColor
			self.collectionView?.backgroundColor = self.colorPalette?.backgroundColor.withAlpha(0.8) ?? ThemeKit.backdropOverlayColor
			
			//			self.collectionView?.reloadData()
		}
	}
	
	
	
	
	
	// MARK: - IBActions
	@IBAction func followArtist(_ sender: Any) {
		
		PreferenceManager.shared.follow(artist: self.currentArtist)
		
		DispatchQueue.global().async {

			_ = self.currentArtist.loadArtwork {
				DispatchQueue.main.async {
					
					self.currentArtist.artworkImage?.getColors(completionHandler: { (imageColors) in
						self.colorPalette = imageColors
						UIView.transition(with: self.view, duration: 0.6, options: .transitionCrossDissolve, animations: {
							self.followButton.setTitle("Unfollow", for: .normal)
							self.artistImageView.image = self.currentArtist.artworkImage
							self.adjustToTheme()
						}, completion: nil)
					})
					
				}
			}
		}
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
	
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		
	}
}

extension ArtistViewController: UICollectionViewDataSourcePrefetching, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	// MARK: UICollectionViewDataSourcePrefetching
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		
		self.latestReleaseArtworkTask = self.currentArtist.latestRelease?.loadThumbnail()
	}
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		
		self.latestReleaseArtworkTask?.cancel()
	}
	
	
	
	
	// MARK: - UICollectionViewDataSource
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		var numSections = 0
		if self.currentArtist.latestRelease != nil { numSections += 1 }
		if self.currentArtist.summary != nil { numSections += 1 }
		if PreferenceManager.shared.followingArtists.contains(where: { $0.itunesID == currentArtist.itunesID }) { numSections += 1 }
		
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
			if PreferenceManager.shared.followingArtists.contains(where: { $0.itunesID == self.currentArtist.itunesID }) {
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
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM d, YYYY"
		dateFormatter.timeZone = .current
		
		// LATEST RELEASE SECTION
		if self.currentArtist.latestRelease != nil && indexPath.section == 0 {
			
			cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LatestReleaseCell", for: indexPath) as! ReleaseCollectionViewCell
			(cell as! ReleaseCollectionViewCell).releaseTitleLabel.text = self.currentArtist.latestRelease!.title
			
			// get release date
			(cell as! ReleaseCollectionViewCell).secondaryLabel.text = "Released on \(dateFormatter.string(from: self.currentArtist.latestRelease!.releaseDate))"
			
			_ = self.currentArtist.latestRelease!.loadThumbnail {
				
				DispatchQueue.main.async {
					(cell as! ReleaseCollectionViewCell).releaseArtworkView.imageView.image = self.currentArtist.latestRelease!.thumbnailImage
					(cell as! ReleaseCollectionViewCell).releaseArtworkView.showArtwork(true)
				}
			}
			if self.colorPalette?.backgroundColor.isDarkColor ?? false {
				(cell as! ReleaseCollectionViewCell).releaseArtworkView.shadow?.shadowColor = StyleKit.darkShadowColor
			} else {
				(cell as! ReleaseCollectionViewCell).releaseArtworkView.shadow?.shadowColor = StyleKit.lightShadowColor
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
				(cell as? TextAreaCollectionViewCell)?.expandButton?.tintColor = self.colorPalette?.primaryColor
				
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
			
			DispatchQueue.main.async {
				((cell as? SettingsCollectionViewCell)?.accessoryView as? UISwitch)?.tintColor = self.colorPalette?.primaryColor
				((cell as? SettingsCollectionViewCell)?.accessoryView as? UISwitch)?.onTintColor = self.colorPalette?.primaryColor
			}
		}
		
		cell.selectedBackgroundView?.backgroundColor = self.colorPalette?.primaryColor.withAlpha(0.2)
		
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
		
		if PreferenceManager.shared.followingArtists.contains(where: { $0.itunesID == self.currentArtist.itunesID }) &&
			((indexPath.section == 0 && self.currentArtist.latestRelease == nil && self.currentArtist.summary == nil) ||
				(indexPath.section == 1 && self.currentArtist.summary == nil) ||
				indexPath.section == 2) {
			
			// RELEASE OPTIONS
			reusableView.textLabel.text = "RELEASE OPTIONS"
		}
		
		if self.colorPalette != nil {
			
			reusableView.backgroundColor = self.colorPalette?.backgroundColor.withAlpha(0.8)
			reusableView.textLabel.textColor = self.colorPalette?.detailColor
			
		} else {
			
			reusableView.backgroundColor = ThemeKit.backgroundColor
			reusableView.textLabel.textColor = ThemeKit.primaryTextColor
		}
		
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
			size = (collectionView.cellForItem(at: indexPath) as? TextAreaCollectionViewCell)?.textView.contentSize ?? size
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
