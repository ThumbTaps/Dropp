//
//  ArtistViewController.swift
//  Ursus
//
//  Created by Jeffery Jackson on 11/15/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ArtistViewController: UrsusViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	@IBOutlet weak var navigationTitleCenteredConstraint: NSLayoutConstraint!
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
			self.backdrop?.imageView.image = self.artistArtworkImage
		}
		
		DispatchQueue.main.async {
			
			if self.colorPalette != nil {
			
				self.view.backgroundColor = self.colorPalette!.backgroundColor
				
				self.view.tintColor = self.colorPalette!.primaryColor
				
				self.setNeedsStatusBarAppearanceUpdate()
				
				if self.colorPalette!.backgroundColor.isDarkColor {
					self.navigationTitle?.textColor = UIColor.white
					self.collectionView?.backgroundColor = self.colorPalette!.backgroundColor.withBrightness(0.1).withAlpha(0.25)
					self.collectionView?.indicatorStyle = .white
					self.backdrop?.overlay.tintColor = self.colorPalette!.backgroundColor.withBrightness(0.1).withAlpha(0.8)
					self.topScrollFadeView?.tintColor = self.colorPalette!.backgroundColor.withBrightness(0.1)
					self.bottomScrollFadeView?.tintColor = self.colorPalette!.backgroundColor.withBrightness(0.1)
					
				} else {
					self.navigationTitle?.textColor = UIColor.black
					self.collectionView?.backgroundColor = self.colorPalette!.backgroundColor.withBrightness(0.9).withAlpha(0.25)
					self.collectionView?.indicatorStyle = .black
					self.backdrop?.overlay.tintColor = self.colorPalette!.backgroundColor.withBrightness(0.9).withAlpha(0.8)
					self.topScrollFadeView?.tintColor = self.colorPalette!.backgroundColor.withBrightness(0.9)
					self.bottomScrollFadeView?.tintColor = self.colorPalette!.backgroundColor.withBrightness(0.9)
				}
				
				self.closeButton.tintColor = self.colorPalette!.detailColor
				self.followButton.tintColor = self.colorPalette!.primaryColor
				
			} else {
				
				// no color palette, go ahead and monitor theme changes
				PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
				self.themeDidChange()
			}
			
		}
		
	}

	override func viewDidAppear(_ animated: Bool) {
		
		DispatchQueue.main.async {
		
			// move follow button in
			self.backdrop?.overlay.removeConstraint(self.navigationTitleCenteredConstraint)
			self.backdrop?.overlay.addConstraint(self.navigationTitleRestingConstraint!)
			
			UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
				self.view.layoutIfNeeded()
			})
			
			self.backdrop?.overlay.removeConstraint(self.followButtonCenteredConstraint)
			self.backdrop?.overlay.addConstraint(self.followButtonRestingConstraint)
			
			UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
				self.view.layoutIfNeeded()
			})
			
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            if self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) {
                return .lightContent
            } else {
                return .default
            }
        }
    }
	override func themeDidChange() {
		super.themeDidChange()
		
		DispatchQueue.main.async {
			
			self.setNeedsStatusBarAppearanceUpdate()
			
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
	
	
	
	
	
	// MARK: - UICollectionView
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.artist.latestRelease != nil ? 1 : 0
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.artist.latestRelease != nil ? 1 : 0
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LatestReleaseCell", for: indexPath) as! ReleaseCollectionViewCell
        
		if self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) {
			cell.tintColor = self.colorPalette?.backgroundColor.withAlpha(0.4)
			
		} else {
			cell.tintColor = self.colorPalette?.backgroundColor.withAlpha(0.4)
		}
		
		cell.releaseTitleLabel.text = self.artist.latestRelease?.title
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM d, YYYY"
		dateFormatter.timeZone = .current
		
		// get release date
		if self.artist.latestRelease != nil {
			
			cell.secondaryLabel.text = "Released on \(dateFormatter.string(from: self.artist.latestRelease!.releaseDate))"
            
            RequestManager.shared.loadImage(from: self.artist.latestRelease!.thumbnailURL!) { (image, error) in
                
                DispatchQueue.main.async {
                    cell.releaseArtView.imageView.image = image
                    cell.releaseArtView.showArtwork()
                }
            }
            
		}
		
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LatestReleaseHeader", for: indexPath) as! HeaderCollectionReusableView
		
		if self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) {
			
			reusableView.tintColor = self.colorPalette?.backgroundColor.withBrightness(0.1).withAlpha(0.2)
		} else {
			
			reusableView.tintColor = self.colorPalette?.backgroundColor.withBrightness(0.9).withAlpha(0.2)
		}
		reusableView.textLabel.text = "LATEST RELEASE"
		
		return reusableView
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: self.view.bounds.width, height: 60)
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: self.view.bounds.size.width, height: 100)
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
		
		self.artist = nil
		self.colorPalette = nil
		self.artistArtworkImage = nil
		super.prepareForUnwind(for: segue)
	}
}
