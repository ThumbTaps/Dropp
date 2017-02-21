//
//  ArtistViewController.swift
//  Ursus
//
//  Created by Jeffery Jackson on 11/15/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ArtistViewController: UrsusViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	@IBOutlet weak var closeButton: CloseButton!
	@IBOutlet weak var followButton: UrsusButton!
    @IBOutlet weak var followButtonRestingConstraint: NSLayoutConstraint!
    @IBOutlet weak var followButtonHidingConstraint: NSLayoutConstraint!
	@IBOutlet weak var followButtonCenteredConstraint: NSLayoutConstraint!
	
	var artist: Artist!
	var artistArtworkImage: UIImage?
    private var colorPalette: UIImageColors?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// don't monitor theme changes
		PreferenceManager.shared.themeDidChangeNotification.remove(self)
		
		self.navigationTitle?.text = self.artist?.name
			
		if PreferenceManager.shared.followingArtists.contains(where: { $0.itunesID == self.artist.itunesID }) {
			self.followButton.isEnabled = false
			self.followButton.alpha = 0.5
		}
		
		if PreferenceManager.shared.adaptiveArtistView {
			
			self.colorPalette = self.artistArtworkImage?.getColors()
				
			DispatchQueue.main.async {
				self.backdrop?.imageView.image = self.artistArtworkImage
				if !UIAccessibilityIsReduceMotionEnabled() {
					self.backdrop?.imageView.enableParallax()
				}
			}
		}
		
		DispatchQueue.main.async {
			
			if self.colorPalette != nil {
			
				self.view.backgroundColor = self.colorPalette!.backgroundColor
				
				self.view.tintColor = self.colorPalette!.primaryColor
				
				if self.colorPalette!.backgroundColor.isDarkColor {
					UIApplication.shared.statusBarStyle = .lightContent
					self.navigationTitle?.textColor = UIColor.white
					self.collectionView?.backgroundColor = self.colorPalette!.backgroundColor.withBrightness(0.2).withAlpha(0.25)
					self.collectionView?.indicatorStyle = .white
					self.backdrop?.overlay.tintColor = self.colorPalette!.backgroundColor.withBrightness(0.2).withAlpha(0.9)
					self.topScrollFadeView?.tintColor = self.colorPalette!.backgroundColor.withBrightness(0.2)
					self.bottomScrollFadeView?.tintColor = self.colorPalette!.backgroundColor.withBrightness(0.2)
					
				} else {
					
					UIApplication.shared.statusBarStyle = .default
					self.navigationTitle?.textColor = UIColor.black
					self.collectionView?.backgroundColor = self.colorPalette!.backgroundColor.withBrightness(0.8).withAlpha(0.25)
					self.collectionView?.indicatorStyle = .black
					self.backdrop?.overlay.tintColor = self.colorPalette!.backgroundColor.withBrightness(0.8).withAlpha(0.9)
					self.topScrollFadeView?.tintColor = self.colorPalette!.backgroundColor.withBrightness(0.8)
					self.bottomScrollFadeView?.tintColor = self.colorPalette!.backgroundColor.withBrightness(0.8)
				}
				
				self.closeButton.tintColor = self.colorPalette!.primaryColor
				self.followButton.tintColor = self.colorPalette!.primaryColor
				
			} else {
				
				// no color palette, go ahead and monitor theme changes
				self.closeButton.changesWithTheme = true
				self.followButton.changesWithTheme = true
				
				PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
				self.themeDidChange()
			}
			
		}
		
	}
	override func viewDidAppear(_ animated: Bool) {
		
		DispatchQueue.main.async {
		
			// move follow button in
			self.backdrop?.overlay.removeConstraint(self.followButtonCenteredConstraint)
			self.backdrop?.overlay.addConstraint(self.followButtonRestingConstraint)
			
			UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
				self.view.layoutIfNeeded()
			})
			
		}
    }
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(true)
		
		self.artist = nil
		self.artistArtworkImage = nil
		self.colorPalette = nil
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func themeDidChange() {
		super.themeDidChange()
		
		DispatchQueue.main.async {
						
			if PreferenceManager.shared.theme == .dark {
				self.collectionView?.backgroundColor = self.colorPalette?.backgroundColor.withBrightness(0.1).withAlpha(0.25)
				
			} else {
				self.collectionView?.backgroundColor = self.colorPalette?.backgroundColor.withBrightness(0.9).withAlpha(0.25)
			}
			
		}
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
	@IBAction func exit(_ sender: Any) {
		if self.presentingViewController!.isKind(of: ArtistSearchViewController.self) {
			self.performSegue(withIdentifier: "Artist->ArtistSearch", sender: sender)
		}
		
		else if self.presentingViewController!.isKind(of: ArtistSearchResultsViewController.self) {
			self.performSegue(withIdentifier: "Artist->ArtistSearchResults", sender: sender)
		}
	}

	
	
	
	
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
		
		var cell = UrsusCollectionViewCell()
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM d, YYYY"
		dateFormatter.timeZone = .current
		
		// LATEST RELEASE SECTION
		if self.artist.latestRelease != nil &&
			indexPath.section == 0 {
			
			cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LatestReleaseCell", for: indexPath) as! ReleaseCollectionViewCell
			(cell as! ReleaseCollectionViewCell).releaseTitleLabel.text = self.artist.latestRelease!.title
			
			// get release date
			(cell as! ReleaseCollectionViewCell).secondaryLabel.text = "Released on \(dateFormatter.string(from: self.artist.latestRelease!.releaseDate))"
			
			if let thumbnailURL = self.artist.latestRelease!.thumbnailURL {
				
				RequestManager.shared.loadImage(from: thumbnailURL) { (image, error) in
					guard let image = image, error == nil else {
						return
					}
					
					DispatchQueue.main.async {
						(cell as! ReleaseCollectionViewCell).releaseArtView.imageView.image = image
						(cell as! ReleaseCollectionViewCell).releaseArtView.showArtwork(true)
					}
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
		
		if self.colorPalette != nil {
			cell.tintColor = self.colorPalette?.backgroundColor.withAlpha(0.15)
			
		} else {
			cell.changesWithTheme = true
		}
		
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		var reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ArtistCollectionViewHeader", for: indexPath) as! HeaderCollectionReusableView
		
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
		
		if self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) {
			
			reusableView.tintColor = self.colorPalette?.backgroundColor.withBrightness(0.1).withAlpha(0.2)
		} else {
			
			reusableView.tintColor = self.colorPalette?.backgroundColor.withBrightness(0.9).withAlpha(0.2)
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
	

	
	
	

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
				
		if segue.identifier == "Artist->Release" {
			// set current release for release view controller
			(segue.destination as! ReleaseViewController).currentRelease = self.artist.latestRelease
			
			// adjust colors
			if self.colorPalette!.backgroundColor.isDarkColor {
				(segue.destination as! ReleaseViewController).theme = .dark
			} else {
				(segue.destination as! ReleaseViewController).theme = .light
			}
		}
    }
	override func prepareForUnwind(for segue: UIStoryboardSegue) {
		super.prepareForUnwind(for: segue)
		
		self.artist = nil
		self.colorPalette = nil
		self.artistArtworkImage = nil
	}
}
