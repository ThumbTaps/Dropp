//
//  NewReleasesViewController.swift
//  Ursus
//
//  Created by Jeffery Jackson on 11/12/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class NewReleasesViewController: UrsusViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
		
	@IBOutlet weak var settingsButton: SettingsButton!
	@IBOutlet weak var artistsButton: ArtistsButton!
	@IBOutlet weak var searchButton: SearchButton!
	
	@IBOutlet weak var newReleasesCountIndicator: UrsusCountIndicator!
	
	@IBOutlet weak var settingsButtonShowingConstraint: NSLayoutConstraint!
	@IBOutlet weak var settingsButtonHidingConstraint: NSLayoutConstraint!
	@IBOutlet weak var artistsButtonShowingConstraint: NSLayoutConstraint!
	@IBOutlet weak var artistsButtonHidingConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchButtonShowingConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchButtonHidingConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchButtonRestingSizeConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchButtonFocusedSizeConstraint: NSLayoutConstraint!
    @IBOutlet weak var newReleasesCountIndicatorHidingConstraint: NSLayoutConstraint!
    @IBOutlet weak var newReleasesCountIndicatorRestingConstraint: NSLayoutConstraint!
			
	override func viewDidLoad() {
		super.viewDidLoad()
		
//		let refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 100, width: 45, height: 45))
//		self.collectionView.addSubview(refreshControl)
		
		PreferenceManager.shared.didChangeReleaseOptionsNotification.add(self, selector: #selector(self.didChangeReleaseOptions))
		
		DispatchQueue.main.async {
			
			if PreferenceManager.shared.newReleases.isEmpty && PreferenceManager.shared.previousReleases.isEmpty {
				self.bottomScrollFadeView?.alpha = 0.5
			}
			
			if PreferenceManager.shared.theme == .dark {
				self.collectionView?.indicatorStyle = .white
			} else {
				self.collectionView?.indicatorStyle = .black
			}
			
		}
		
		PreferenceManager.shared.updateNewReleases()
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		if PreferenceManager.shared.followingArtists.isEmpty {
			
			DispatchQueue.main.async {
				
				self.backdrop?.overlay.removeConstraints([self.settingsButtonHidingConstraint, self.searchButtonHidingConstraint, self.artistsButtonShowingConstraint])
				self.backdrop?.overlay.addConstraints([self.settingsButtonShowingConstraint, self.searchButtonShowingConstraint, self.artistsButtonHidingConstraint])
				self.searchButton?.removeConstraint(self.searchButtonRestingSizeConstraint)
				self.searchButton?.addConstraint(self.searchButtonFocusedSizeConstraint)
			}
			
			// show search bar
			if PreferenceManager.shared.firstLaunch {
				self.performSegue(withIdentifier: "NewReleases->ArtistSearch", sender: nil)
				PreferenceManager.shared.firstLaunch = false
			}
			
		} else {
			
			DispatchQueue.main.async {
				
				self.backdrop?.overlay.removeConstraints([self.settingsButtonHidingConstraint, self.artistsButtonHidingConstraint, self.searchButtonHidingConstraint])
				self.backdrop?.overlay.addConstraints([self.settingsButtonShowingConstraint, self.artistsButtonShowingConstraint, self.searchButtonShowingConstraint])
				
				if !PreferenceManager.shared.newReleases.isEmpty {
				
					self.backdrop?.overlay.removeConstraint(self.newReleasesCountIndicatorHidingConstraint)
					self.backdrop?.overlay.addConstraint(self.newReleasesCountIndicatorRestingConstraint)
				}
			}
		}
		
		DispatchQueue.main.async {
			
			UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
				
				self.backdrop?.overlay.layoutIfNeeded()
				self.searchButton?.layoutIfNeeded()
				self.searchButton?.setNeedsDisplay()
			})
		}
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	
	
	
	// MARK: - Notifications
	override func didUpdateNewReleases() {
		
		super.didUpdateNewReleases()
		
		DispatchQueue.main.async {
			// update new release count
			self.newReleasesCountIndicator.setTitle(String(PreferenceManager.shared.newReleases.count), for: .normal)
			self.collectionView?.reloadData()
			
			if PreferenceManager.shared.newReleases.isEmpty {
				
				self.backdrop?.overlay.removeConstraint(self.newReleasesCountIndicatorRestingConstraint)
				self.backdrop?.overlay.addConstraint(self.newReleasesCountIndicatorHidingConstraint)
			} else {
				self.backdrop?.overlay.removeConstraint(self.newReleasesCountIndicatorHidingConstraint)
				self.backdrop?.overlay.addConstraint(self.newReleasesCountIndicatorRestingConstraint)
			}
			
		}
	}
	func didChangeReleaseOptions() {
		
		self.collectionView?.reloadData()
	}
	
	
	
	
	
	// MARK: - UICollectionViewDataSource
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		var numSections = 0

		if !PreferenceManager.shared.newReleases.isEmpty {
			numSections += 1
		}
		if PreferenceManager.shared.showPreviousReleases && !PreferenceManager.shared.previousReleases.isEmpty {
			numSections += 1
		}
		return numSections
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		var numItems = 0
		
		switch section {
		case 0:
			if !PreferenceManager.shared.newReleases.isEmpty {
				numItems = PreferenceManager.shared.newReleases.count
			} else {
				numItems = PreferenceManager.shared.previousReleases.count
			}
			break
			
		case 1:
			numItems = PreferenceManager.shared.previousReleases.count
			break
			
		default: return numItems
		}
		
		return numItems
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReleaseCell", for: indexPath) as? ReleaseCollectionViewCell else {
			return UICollectionViewCell()
		}
		
		var source = PreferenceManager.shared.newReleases
		
		if indexPath.section == 0 {
			if PreferenceManager.shared.newReleases.isEmpty {
				source = PreferenceManager.shared.previousReleases
			} else {
				source = PreferenceManager.shared.newReleases
			}
			
		} else if indexPath.section == 1 {
			
			source = PreferenceManager.shared.previousReleases
		}
		
		cell.releaseTitleLabel.text = source[indexPath.row].title
		
		// get artist
		guard let artist: Artist = PreferenceManager.shared.followingArtists.first(where: {
			$0.releases.contains(where: {
				$0.itunesID == source[indexPath.row].itunesID
			})
		}) else {
			return UICollectionViewCell()
		}
		
		cell.secondaryLabel.text = artist.name
		
		DispatchQueue.global().async {
			
			RequestManager.shared.loadImage(from: source[indexPath.row].thumbnailURL!) { (image, error) in
				guard let image = image, error == nil else {
					print(error!)
					return
				}
				
				DispatchQueue.main.async {
					cell.releaseArtView.imageView.image = image
					cell.releaseArtView.showArtwork()
				}
			}
			
		}
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		
		if section == 0 {
			if PreferenceManager.shared.newReleases.isEmpty {
				if !PreferenceManager.shared.previousReleases.isEmpty {
					return CGSize(width: collectionView.bounds.width, height: 60)
				} else {
					return .zero
				}
			}
		} else if section == 1 {
			if !PreferenceManager.shared.previousReleases.isEmpty {
				return CGSize(width: collectionView.bounds.width, height: 60)
			} else {
				return .zero
			}
		}
		
		return .zero
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.bounds.size.width, height: 100)
	}
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		var reusableView = UICollectionReusableView()
		
		if kind == UICollectionElementKindSectionHeader {
			reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NewReleasesCollectionViewHeader", for: indexPath) as! HeaderCollectionReusableView
			
			switch indexPath.section {
			case 0:
				if PreferenceManager.shared.newReleases.isEmpty {
					if !PreferenceManager.shared.previousReleases.isEmpty {
						var timeUnit = "DAYS"
						if PreferenceManager.shared.maxReleaseAge == 1 {
							timeUnit = "DAY"
						}
						(reusableView as! HeaderCollectionReusableView).textLabel.text = "IN THE PAST\(PreferenceManager.shared.maxReleaseAge == 1 ? "" : String(PreferenceManager.shared.maxReleaseAge)) \(timeUnit)"
					}
				}
				break
				
			case 1:
				if !PreferenceManager.shared.previousReleases.isEmpty {
					var timeUnit = "DAYS"
					if PreferenceManager.shared.maxReleaseAge == 1 {
						timeUnit = "DAY"
					}
					(reusableView as! HeaderCollectionReusableView).textLabel.text = "IN THE PAST\(PreferenceManager.shared.maxReleaseAge == 1 ? "" : String(PreferenceManager.shared.maxReleaseAge)) \(timeUnit)"
				}
				break
				
			default: return reusableView
			}
			
			return reusableView
		}
		
		return reusableView
	}
	
	
	
	
	
	
	// MARK: - Navigation
	func dismissDestination() {
		self.presentedViewController?.performSegue(withIdentifier: "Settings->NewReleases", sender: nil)
	}
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		
		if segue.identifier == "NewReleases->Release" {
			// set current release for release view controller
			var source = PreferenceManager.shared.newReleases
			switch self.collectionView?.indexPathsForSelectedItems?[0].section ?? 0 {
			case 0:
				if PreferenceManager.shared.newReleases.isEmpty {
					source = PreferenceManager.shared.previousReleases
				} else {
					source = PreferenceManager.shared.newReleases
				}
				break
				
			case 1:
				source = PreferenceManager.shared.previousReleases
				break
				
			default: source = PreferenceManager.shared.newReleases
			}

			(segue.destination as! ReleaseViewController).currentRelease = source[(self.collectionView?.indexPathsForSelectedItems?[0].row)!]
			
			// adjust colors
			if PreferenceManager.shared.theme == .dark {
				segue.destination.view.tintColor = StyleKit.darkBackgroundColor
			} else {
				segue.destination.view.tintColor = StyleKit.lightBackgroundColor
			}
		}
		
		else if segue.identifier == "NewReleases->Settings" {
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissDestination))
			self.view.addGestureRecognizer(tapGestureRecognizer)
		}
	}
}
