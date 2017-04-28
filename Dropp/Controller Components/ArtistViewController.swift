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
	
	var artist: Artist! // expects a fully-formed artist object
	var colorPalette: UIImageColors?
	
	override var backButton: DroppButton? {
		let artistButton = ArtistsButton()
		artistButton.tintColor = self.colorPalette?.primaryColor
		return artistButton
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = self.artist.name
		
		// don't monitor theme changes
		PreferenceManager.shared.themeDidChangeNotification.remove(self)
		
		DispatchQueue.main.async {
			
			if PreferenceManager.shared.followingArtists.contains(where: { $0.itunesID == self.artist.itunesID }) {
				self.followButton.setTitle("Unfollow", for: .normal)
				self.followButton.tintColor = ThemeKit.strokeColor
			}
			
			if PreferenceManager.shared.adaptiveArtistView {
				
				self.colorPalette = self.artist.artworkImage?.getColors()
				self.artistImageView.image = self.artist.artworkImage
				
				if !UIAccessibilityIsReduceMotionEnabled() {
					self.artistImageView.enableParallax()
				}
			}
			
			if self.colorPalette != nil {
				
				self.view.backgroundColor = self.colorPalette!.backgroundColor
				
				self.view.tintColor = self.colorPalette!.primaryColor
				
				if self.colorPalette!.backgroundColor.isDarkColor {
					UIApplication.shared.statusBarStyle = .lightContent
					self.collectionView?.backgroundColor = self.colorPalette!.backgroundColor.withBrightness(0.2).withAlpha(0.25)
					self.collectionView?.indicatorStyle = .white
					
				} else {
					
					UIApplication.shared.statusBarStyle = .default
					self.collectionView?.backgroundColor = self.colorPalette!.backgroundColor.withBrightness(0.8).withAlpha(0.25)
					self.collectionView?.indicatorStyle = .black
				}
			}
		}
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(true)
		
		self.artist = nil
		self.colorPalette = nil
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
		
	
	
	
	
	// MARK: - IBActions
	@IBAction func followArtist(_ sender: Any) {
		
		PreferenceManager.shared.follow(artist: self.artist)
	}
	@IBAction func toggleIncludeSingles(_ sender: UISwitch) {
		self.artist.includeSingles = sender.isOn
		self.collectionView?.performBatchUpdates({
			self.collectionView?.reloadSections([(self.collectionView?.numberOfSections ?? 3) - 1])
		})
	}
	@IBAction func toggleIgnoreFeatures(_ sender: UISwitch) {
		self.artist.ignoreFeatures = sender.isOn
	}
	@IBAction func toggleIncludeEPs(_ sender: UISwitch) {
		self.artist.includeEPs = sender.isOn
	}
	
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		
	}
}

extension ArtistViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	// MARK: - UICollectionViewDataSource
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		var numSections = 0
		if self.artist.latestRelease != nil { numSections += 1 }
		if self.artist.summary != nil { numSections += 1 }
		if PreferenceManager.shared.followingArtists.contains(where: { $0.itunesID == artist.itunesID }) { numSections += 1 }
		
		return numSections
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		var numItems = 0
		switch section {
		case 0:
			if self.artist.latestRelease != nil { numItems += 1 }
			break
		case 1:
			if self.artist.summary != nil { numItems += 1 }
			break
		case 2:
			if PreferenceManager.shared.followingArtists.contains(where: { $0.itunesID == self.artist.itunesID }) {
				numItems += 2
				if self.artist.includeSingles ?? PreferenceManager.shared.includeSingles {
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
		if self.artist.latestRelease != nil && indexPath.section == 0 {
			
			cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LatestReleaseCell", for: indexPath) as! ReleaseCollectionViewCell
			(cell as! ReleaseCollectionViewCell).releaseTitleLabel.text = self.artist.latestRelease!.title
			
			// get release date
			(cell as! ReleaseCollectionViewCell).secondaryLabel.text = "Released on \(dateFormatter.string(from: self.artist.latestRelease!.releaseDate))"
			
			_ = self.artist.latestRelease!.loadThumbnail {
				
				DispatchQueue.main.async {
					(cell as! ReleaseCollectionViewCell).releaseArtworkView.imageView.image = self.artist.latestRelease!.thumbnailImage
					(cell as! ReleaseCollectionViewCell).releaseArtworkView.showArtwork(true)
				}
			}
		}
		
		// SUMMARY SECTION
		if self.artist.summary != nil &&
			((indexPath.section == 0 && self.artist.latestRelease == nil) ||
				(indexPath.section == 1 && self.artist.latestRelease != nil)) {
			
			switch indexPath.row {
			case 0:
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistSummaryCell", for: indexPath) as! TextAreaCollectionViewCell
				(cell as? TextAreaCollectionViewCell)?.textView.text = self.artist.summary
				(cell as? TextAreaCollectionViewCell)?.expandButton?.tintColor = self.colorPalette?.primaryColor
				
				break
				
			default: break
			}
			
		}
		
		// RELEASE OPTIONS
		if PreferenceManager.shared.followingArtists.contains(where: { $0.itunesID == self.artist.itunesID }) &&
			((indexPath.section == 0 && self.artist.latestRelease == nil && self.artist.summary == nil) ||
				(indexPath.section == 1 && self.artist.summary == nil) ||
				indexPath.section == 2) {
			
			switch indexPath.row {
			case 0: // IGNORE SINGLES
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IncludeSinglesCell", for: indexPath) as! SettingsCollectionViewCell
				((cell as? SettingsCollectionViewCell)?.accessoryView as? UISwitch)?.isOn = self.artist.includeSingles ?? PreferenceManager.shared.includeSingles
				break
				
			case 1: // INCLUDE EPS / IGNORE FEATURES
				if self.artist.includeSingles ?? PreferenceManager.shared.includeSingles {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IgnoreFeaturesCell", for: indexPath) as! SettingsCollectionViewCell
					((cell as? SettingsCollectionViewCell)?.accessoryView as? UISwitch)?.isOn = self.artist.ignoreFeatures ?? PreferenceManager.shared.ignoreFeatures
				} else {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IncludeEPsCell", for: indexPath) as! SettingsCollectionViewCell
					((cell as? SettingsCollectionViewCell)?.accessoryView as? UISwitch)?.isOn = self.artist.includeEPs ?? PreferenceManager.shared.includeEPs
				}
				break
				
			case 2: // INCLUDE EPS
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IncludeEPsCell", for: indexPath) as! SettingsCollectionViewCell
				((cell as? SettingsCollectionViewCell)?.accessoryView as? UISwitch)?.isOn = self.artist.includeEPs ?? PreferenceManager.shared.includeEPs
				break
			default: break
			}
			
			DispatchQueue.main.async {
				((cell as? SettingsCollectionViewCell)?.accessoryView as? UISwitch)?.tintColor = self.colorPalette?.primaryColor
				((cell as? SettingsCollectionViewCell)?.accessoryView as? UISwitch)?.onTintColor = self.colorPalette?.primaryColor
			}
		}
		
//		if self.colorPalette != nil {
//			cell.tintColor = self.colorPalette?.backgroundColor.withAlphaComponent(0.15)
//			
//		} else {
//			cell.changesWithTheme = true
//		}
		
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		guard let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ArtistCollectionViewHeader", for: indexPath) as? HeaderCollectionReusableView else {
			return UICollectionReusableView()
		}
		
		if self.artist.latestRelease != nil &&
			indexPath.section == 0 {
			
			// LATEST RELEASE SECTION
			reusableView.textLabel.text = "LATEST RELEASE"
			
		}
		
		if self.artist.summary != nil &&
			((indexPath.section == 0 && self.artist.latestRelease == nil) ||
				(indexPath.section == 1 && self.artist.latestRelease != nil)) {
			
			// ADDITIONAL INFO SECTION
			reusableView.textLabel.text = "SUMMARY"
		}
		
		if PreferenceManager.shared.followingArtists.contains(where: { $0.itunesID == self.artist.itunesID }) &&
			((indexPath.section == 0 && self.artist.latestRelease == nil && self.artist.summary == nil) ||
				(indexPath.section == 1 && self.artist.summary == nil) ||
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
		return CGSize(width: self.view.bounds.width, height: 60)
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		var size = CGSize(width: collectionView.bounds.width, height: 100)
		
		if self.artist.latestRelease != nil &&
			indexPath.section == 0 {
			
			// LATEST RELEASE SECTION
		}
		
		if self.artist.summary != nil &&
			((indexPath.section == 0 && self.artist.latestRelease == nil) ||
				(indexPath.section == 1 && self.artist.latestRelease != nil)) {
			
			// SUMMARY SECTION
			size = (collectionView.cellForItem(at: indexPath) as? TextAreaCollectionViewCell)?.textView.contentSize ?? size
		}
		
		if PreferenceManager.shared.followingArtists.contains(where: { $0.itunesID == self.artist.itunesID }) &&
			((indexPath.section == 0 && self.artist.latestRelease == nil && self.artist.summary == nil) ||
				(indexPath.section == 1 && self.artist.summary == nil) ||
				indexPath.section == 2) {
			
			// RELEASE OPTIONS
			size = CGSize(width: collectionView.bounds.width, height: 50)
		}
		
		return size
	}
}
