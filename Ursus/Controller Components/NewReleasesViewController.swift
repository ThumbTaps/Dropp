//
//  NewReleasesViewController.swift
//  Ursus
//
//  Created by Jeffery Jackson on 11/12/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class NewReleasesViewController: UrsusViewController, UICollectionViewDataSource, UICollectionViewDataSourcePrefetching, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
		
	@IBOutlet weak var settingsButton: SettingsButton!
	@IBOutlet weak var settingsButtonShowingConstraint: NSLayoutConstraint!
	@IBOutlet weak var settingsButtonHidingConstraint: NSLayoutConstraint!

	@IBOutlet weak var artistsButton: ArtistsButton!
	@IBOutlet weak var artistsButtonShowingConstraint: NSLayoutConstraint!
	@IBOutlet weak var artistsButtonHidingConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var searchButton: SearchButton!
	@IBOutlet weak var searchButtonShowingConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchButtonHidingConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var newReleasesSortButton: SortButton!
	@IBOutlet weak var newReleasesSortButtonHidingConstraint: NSLayoutConstraint!
	@IBOutlet weak var newReleasesSortButtonRestingConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var newReleasesCountIndicator: UrsusCountIndicator!
	@IBOutlet weak var newReleasesCountIndicatorHidingConstraint: NSLayoutConstraint!
	@IBOutlet weak var newReleasesCountIndicatorRestingConstraint: NSLayoutConstraint!
	
	@IBOutlet weak var previousReleasesCountIndicator: UrsusCountIndicator!
	
	var blurView: UIVisualEffectView?
	
	var isCurrentlyVisible = true
	
	var newReleasesArtwork = [UIImage?](repeating: nil, count: PreferenceManager.shared.newReleases.count)
	var previousReleasesArtwork = [UIImage?](repeating: nil, count: PreferenceManager.shared.previousReleases.count)
	
	var newReleasesArtworkDownloadTasks = [URLSessionDataTask?](repeating: nil, count: PreferenceManager.shared.newReleases.count)
	var previousReleasesArtworkDownloadTasks = [URLSessionDataTask?](repeating: nil, count: PreferenceManager.shared.previousReleases.count)
			
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.collectionView?.refreshControl = UIRefreshControl(frame: CGRect(x: 0, y: 100, width: 45, height: 45))
		
		DispatchQueue.main.async {
			
			if PreferenceManager.shared.newReleases.isEmpty && PreferenceManager.shared.previousReleases.isEmpty {
				self.bottomScrollFadeView?.alpha = 0.5
			}
			
			if PreferenceManager.shared.theme == .dark {
				self.collectionView?.indicatorStyle = .white
			} else {
				self.collectionView?.indicatorStyle = .default
			}
			
		}		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		DispatchQueue.main.async {
			
			self.backdrop?.overlay.removeConstraints([self.settingsButtonHidingConstraint, self.searchButtonHidingConstraint])
			self.backdrop?.overlay.addConstraints([self.settingsButtonShowingConstraint, self.searchButtonShowingConstraint])
			
			if PreferenceManager.shared.followingArtists.isEmpty {
				
				self.backdrop?.overlay.removeConstraint(self.artistsButtonShowingConstraint)
				self.backdrop?.overlay.addConstraint(self.artistsButtonHidingConstraint)
				
				// show search bar
				if PreferenceManager.shared.firstLaunch {
					self.performSegue(withIdentifier: "NewReleases->ArtistSearch", sender: nil)
					PreferenceManager.shared.firstLaunch = false
				}
				
			} else {
				
				self.backdrop?.overlay.removeConstraint(self.artistsButtonHidingConstraint)
				self.backdrop?.overlay.addConstraint(self.artistsButtonShowingConstraint)
				
			}
			
			UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
				
				self.backdrop?.overlay.layoutIfNeeded()
			}, completion: { (finished) in
				
				PreferenceManager.shared.updateNewReleases()
			})
		}
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
		
		print("There was a memory warning.")
	}
	
	
	
	
	
	// MARK: - Notifications
	override func didUpdateNewReleases() {
		
		self.collectionView?.prefetchDataSource = self
		self.collectionView?.dataSource = self
		self.collectionView?.delegate = self
		
		self.newReleasesArtwork = [UIImage?](repeating: nil, count: PreferenceManager.shared.newReleases.count)
		self.previousReleasesArtwork = [UIImage?](repeating: nil, count: PreferenceManager.shared.previousReleases.count)
		
		self.newReleasesArtworkDownloadTasks = [URLSessionDataTask?](repeating: nil, count: PreferenceManager.shared.newReleases.count)
		self.previousReleasesArtworkDownloadTasks = [URLSessionDataTask?](repeating: nil, count: PreferenceManager.shared.previousReleases.count)
		
		DispatchQueue.main.async {
			
			// update new release count
			self.newReleasesCountIndicator.setTitle(String(PreferenceManager.shared.newReleases.count), for: .normal)
			self.previousReleasesCountIndicator.setTitle(String(PreferenceManager.shared.previousReleases.count), for: .normal)
			
			if self.isCurrentlyVisible {
				
				self.collectionView?.performBatchUpdates({
					
					if !PreferenceManager.shared.newReleases.isEmpty {
						self.collectionView?.reloadSections([0])
					}
					
					if !PreferenceManager.shared.previousReleases.isEmpty {
						self.collectionView?.reloadSections([1])
					}
				})
				
			} else {
				self.collectionView?.reloadData()
			}
			
			self.collectionView?.refreshControl?.endRefreshing()
			
			if PreferenceManager.shared.newReleases.isEmpty && PreferenceManager.shared.previousReleases.isEmpty {
				
				self.backdrop?.overlay.removeConstraints([self.newReleasesCountIndicatorRestingConstraint, self.newReleasesSortButtonRestingConstraint])
				self.backdrop?.overlay.addConstraints([self.newReleasesCountIndicatorHidingConstraint, self.newReleasesSortButtonHidingConstraint])
			} else {
				self.backdrop?.overlay.removeConstraints([self.newReleasesCountIndicatorHidingConstraint, self.newReleasesSortButtonHidingConstraint])
				self.backdrop?.overlay.addConstraints([self.newReleasesCountIndicatorRestingConstraint, self.newReleasesSortButtonRestingConstraint])
			}
			
			UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
				
				// hide new releases count indicator if there are no new releases
				if PreferenceManager.shared.newReleases.isEmpty {
					self.newReleasesCountIndicator.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
					self.newReleasesCountIndicator.alpha = 0
				} else { // otherwise, show it
					self.newReleasesCountIndicator.transform = CGAffineTransform(scaleX: 1, y: 1)
					self.newReleasesCountIndicator.alpha = 1
				}
				
				// hide previous releases count indicator if there are no previous releases (this likely won't happen often)
				if PreferenceManager.shared.previousReleases.isEmpty {
					self.previousReleasesCountIndicator.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
					self.previousReleasesCountIndicator.alpha = 0
				} else { // otherwise, show it
					self.previousReleasesCountIndicator.transform = CGAffineTransform(scaleX: 1, y: 1)
					self.previousReleasesCountIndicator.alpha = 1
				}
				
				self.backdrop?.overlay.layoutIfNeeded()
			})
			
		}
	}

	
	
	
	
	// MARK: - IBActions
	@IBAction func showSearch(_ sender: Any) {
		let deadlineTime = DispatchTime.now() + .milliseconds(50)
		DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
			self.performSegue(withIdentifier: "NewReleases->ArtistSearch", sender: nil)
		}
	}
	
	
	
	
	
	// MARK: UICollectionViewDataSourcePrefetching
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		
		indexPaths.forEach { (indexPath) in
			
			var source = PreferenceManager.shared.newReleases
			var destination = self.newReleasesArtwork
			
			if indexPath.section == 1 {
				
				source = PreferenceManager.shared.previousReleases
				destination = self.previousReleasesArtwork
			}
			
			if destination[indexPath.row] == nil {
				
				if let artworkURL = source[indexPath.row].artworkURL {
					DispatchQueue.global().async {
						
						UIApplication.shared.isNetworkActivityIndicatorVisible = true
						if let artworkTask = RequestManager.shared.loadImage(from: artworkURL, completion: { (image, error) in
							
							UIApplication.shared.isNetworkActivityIndicatorVisible = false
							if let image = image, error == nil {
								destination[indexPath.row] = image
							}
							
						}) {
							
							if indexPath.section == 0 {
								self.newReleasesArtworkDownloadTasks[indexPath.row] = artworkTask
							} else {
								self.previousReleasesArtworkDownloadTasks[indexPath.row] = artworkTask
							}
						}
					}
				}
			}

		}
	}
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		
		indexPaths.forEach { (indexPath) in
			
			if indexPath.section == 0 {
				self.newReleasesArtworkDownloadTasks[indexPath.row]?.cancel()
			} else {
				self.previousReleasesArtworkDownloadTasks[indexPath.row]?.cancel()
			}
			
		}
	}
	
	
	
	
	
	// MARK: - UICollectionViewDataSource
	func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		var numItems = PreferenceManager.shared.newReleases.count
		
		if section == 1 {
			
			numItems = PreferenceManager.shared.previousReleases.count
		}
		
		return numItems
	}
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		var reusableView = UICollectionReusableView()
		
		if kind == UICollectionElementKindSectionHeader {
			reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NewReleasesCollectionViewHeader", for: indexPath) as! HeaderCollectionReusableView
			
			switch indexPath.section {
			case 0:
				break
				
			case 1:
				var timeUnit = " MONTHS"
				if PreferenceManager.shared.maxPreviousReleaseAge == 1 {
					timeUnit = "MONTH"
				}
				(reusableView as! HeaderCollectionReusableView).textLabel.text = "IN THE PAST \(PreferenceManager.shared.maxPreviousReleaseAge == 1 ? "" : String(PreferenceManager.shared.maxPreviousReleaseAge))\(timeUnit)"
				break
				
			default: return reusableView
			}
			
			return reusableView
		}
		
		return reusableView
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReleaseCell", for: indexPath) as? ReleaseCollectionViewCell else {
			return UICollectionViewCell()
		}
		
		var source = PreferenceManager.shared.newReleases
		var artworkSource = self.newReleasesArtwork
		
		if indexPath.section == 1 {
			
			source = PreferenceManager.shared.previousReleases
			artworkSource = self.previousReleasesArtwork
		}
		
		let release = source[indexPath.row]
		
		DispatchQueue.main.async {
			cell.releaseArtView.hideArtwork()
		}
		
		cell.releaseTitleLabel.text = release.title
		
		cell.secondaryLabel.text = release.artist.name
		
		guard let image = artworkSource[indexPath.row] else {
			
			guard let url = release.thumbnailURL else {
				return cell
			}
			
			DispatchQueue.global().async {
				
				UIApplication.shared.isNetworkActivityIndicatorVisible = true
				let artworkTask = RequestManager.shared.loadImage(from: url, completion: { (image, error) in
					UIApplication.shared.isNetworkActivityIndicatorVisible = false
					guard let image = image, error == nil else {
						print(error!)
						return
					}
					
					// add loaded image to prefetch source
					if indexPath.section == 0 {
						self.newReleasesArtwork[indexPath.row] = image
					} else {
						self.previousReleasesArtwork[indexPath.row] = image
					}
					
					DispatchQueue.main.async {
						cell.releaseArtView.imageView.image = image
						cell.releaseArtView.showArtwork(true)
					}
				})
			}
			
			return cell
		}
		
		DispatchQueue.main.async {
			cell.releaseArtView.imageView.image = image
			cell.releaseArtView.showArtwork()
		}
		
		
		return cell
	}

	
	
	
	
	
	// MARK: - UICollectionViewDelegate
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		
		if section == 1 && !PreferenceManager.shared.previousReleases.isEmpty {
			return CGSize(width: collectionView.bounds.width, height: 60)
		}
		
		return CGSize(width: 0.1, height: 0.1)
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: collectionView.bounds.size.width, height: 100)
	}
	
	
	
	
	
	
	// MARK: - UIScrollViewDelegate
	func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		
		if scrollView == self.collectionView {
			if self.collectionView?.refreshControl?.isRefreshing ?? false {

				let deadlineTime = DispatchTime.now() + .milliseconds(300)
				DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
					if PreferenceManager.shared.lastReleasesUpdate != nil && PreferenceManager.shared.lastReleasesUpdate! < Calendar.current.date(byAdding: .minute, value: -5, to: Date())! {
						PreferenceManager.shared.updateNewReleases()
					} else {
						self.collectionView?.refreshControl?.endRefreshing()
					}
					
				}
			}
		}
	}
	
	
	
	
	
	
	// MARK: - Navigation
	func dismissDestination() {
		guard let presentedVC = self.presentedViewController else {
			self.presentedViewController?.dismiss(animated: true, completion: nil)
			return
		}
		
		if presentedVC.isKind(of: SettingsViewController.self) {
			self.presentedViewController?.performSegue(withIdentifier: "Settings->NewReleases", sender: nil)
		}
		else if presentedVC.isKind(of: ReleaseSortingViewController.self) {
			self.presentedViewController?.performSegue(withIdentifier: "ReleaseSorting->NewReleases", sender: nil)
		}
	}
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destinationViewController.
		// Pass the selected object to the new view controller.
		
		self.isCurrentlyVisible = false
		
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
			self.newReleasesSortButton.isEnabled = false
			self.collectionView?.isUserInteractionEnabled = false
			UIView.animate(withDuration: 0.4*ANIMATION_SPEED_MODIFIER, animations: {
				self.collectionView?.alpha = 0.15
			})
			let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissDestination))
			self.view.addGestureRecognizer(tapGestureRecognizer)
		}
		
		else if segue.identifier == "NewReleases->ArtistSearch" {
//			self.searchButton.alpha = 0
		}
		
		else if segue.identifier == "NewReleases->ReleaseSorting" {
			self.blurView = UrsusBlurView(frame: self.view.bounds)
			self.backdrop?.addSubview(self.blurView!)
			UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*0.3, animations: {
				self.blurView?.effect = PreferenceManager.shared.theme == .dark ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .light)
			})

		}
	}
	override func prepareForUnwind(for segue: UIStoryboardSegue) {
		super.prepareForUnwind(for: segue)
		
		self.isCurrentlyVisible = true
		
		if segue.identifier == "Settings->NewReleases" {
			self.newReleasesSortButton.isEnabled = true
			self.collectionView?.isUserInteractionEnabled = true
			UIView.animate(withDuration: 0.4*ANIMATION_SPEED_MODIFIER, animations: {
				self.collectionView?.alpha = 1
			})
		}
		
		else if segue.identifier == "ReleaseSorting->NewReleases" {
			
			UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*0.5, animations: {
				self.blurView?.effect = nil
			}) { (finished) in
				self.blurView?.removeFromSuperview()
				self.blurView = nil
			}
		}
		
		else if segue.identifier == "Release->NewReleases" {
			if let selectedIndex = self.collectionView?.indexPathsForSelectedItems?[0] {
				self.collectionView?.deselectItem(at: selectedIndex, animated: false)
			}

		}
	}
}
