//
//  ArtistViewController.swift
//  Ursus
//
//  Created by Jeffery Jackson on 11/15/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ArtistViewController: UrsusViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	@IBOutlet weak var followButton: UrsusButton!
    @IBOutlet weak var followButtonRestingConstraint: NSLayoutConstraint!
    @IBOutlet weak var followButtonHidingConstraint: NSLayoutConstraint!
	
	var artist: Artist!
    var artistArtwork: UIImage?
    private var colorPalette: UIImageColors?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// don't monitor theme changes
		Notification.Name.UrsusThemeDidChange.remove(self)
		
		self.colorPalette = self.artistArtwork?.getColors()
		
		self.navigationTitle?.text = self.artist?.name
		self.backdrop?.imageView.image = self.artistArtwork
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if self.colorPalette != nil {
			
			DispatchQueue.main.async {
				
				self.view.backgroundColor = self.colorPalette!.backgroundColor
				
				self.view.tintColor = self.colorPalette?.primaryColor
				
				if self.colorPalette!.backgroundColor.isDarkColor {
					self.navigationTitle?.textColor = UIColor.white
					self.collectionView?.backgroundColor = self.colorPalette?.backgroundColor.withBrightness(0.1).withAlpha(0.5)
					self.backdrop?.overlay.tintColor = self.colorPalette?.backgroundColor.withBrightness(0.1).withAlpha(0.9)
					self.topScrollFadeView?.tintColor = self.colorPalette?.backgroundColor.withBrightness(0.1)
					self.bottomScrollFadeView?.tintColor = self.colorPalette?.backgroundColor.withBrightness(0.1)
					
				} else {
					self.navigationTitle?.textColor = UIColor.black
					self.collectionView?.backgroundColor = self.colorPalette?.backgroundColor.withBrightness(0.9).withAlpha(0.5)
					self.backdrop?.overlay.tintColor = self.colorPalette?.backgroundColor.withBrightness(0.9).withAlpha(0.9)
					self.topScrollFadeView?.tintColor = self.colorPalette?.backgroundColor.withBrightness(0.9)
					self.bottomScrollFadeView?.tintColor = self.colorPalette?.backgroundColor.withBrightness(0.9)
				}
				
				self.followButton.tintColor = self.colorPalette?.primaryColor
				
			}
			
		}
	}

	override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
		
		DispatchQueue.main.async {
		
			// move follow button in
			self.backdrop?.overlay.removeConstraint(self.followButtonHidingConstraint)
			self.backdrop?.overlay.addConstraint(self.followButtonRestingConstraint)
			
			UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
				self.view.layoutIfNeeded()
			}, completion: { (finished) in
				
				// self.showBackButton()
			})
		}
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
    override var preferredStatusBarStyle: UIStatusBarStyle {
        get {
            if self.colorPalette?.backgroundColor.isDarkColor ?? false {
                return .lightContent
            } else {
                return .default
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
        
		if self.colorPalette!.backgroundColor.isDarkColor {
			cell.tintColor = self.colorPalette?.backgroundColor.withBrightness(0.1).withAlpha(0.3)
			
		} else {
			cell.tintColor = self.colorPalette?.backgroundColor.withBrightness(0.9).withAlpha(0.3)
		}
		
		cell.releaseTitleLabel.text = self.artist.latestRelease?.title
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "MMM d, YYYY"
		dateFormatter.timeZone = .current
		
		// get release date
		if self.artist.latestRelease != nil {
			
			cell.secondaryLabel.text = "Released on \(dateFormatter.string(from: self.artist.latestRelease!.releaseDate))"
            
            RequestManager.shared.loadImage(from: self.artist.latestRelease!.artworkURL!) { (image, error) in
                
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
		
		if self.colorPalette!.backgroundColor.isDarkColor {
			
			reusableView.tintColor = self.colorPalette?.backgroundColor.withBrightness(0.1).withAlpha(0.3)
		} else {
			
			reusableView.tintColor = self.colorPalette?.backgroundColor.withBrightness(0.9).withAlpha(0.3)
		}
		reusableView.textLabel.text = "LATEST RELEASE"
		
		return reusableView
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.bounds.size.width, height: 100)
	}

	
	
	
	
	

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
