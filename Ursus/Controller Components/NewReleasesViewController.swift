//
//  NewReleasesViewController.swift
//  Ursus
//
//  Created by Jeffery Jackson on 11/12/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class NewReleasesViewController: UrsusViewController {
		
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
	
	@IBOutlet weak var nowPlayingArtistQuickViewButton: ArtworkArtView!
	@IBOutlet weak var nowPlayingArtistQuickViewButtonHidingConstraint: NSLayoutConstraint!
	@IBOutlet weak var nowPlayingArtistQuickViewButtonRestingConstraint: NSLayoutConstraint!
	
	@IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
	@IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
	
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
		
		// start monitoring now playing artist changes
		PreferenceManager.shared.nowPlayingArtistDidChangeNotification.add(self, selector: #selector(self.nowPlayingArtistDidChange))
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
			})
		}
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
		
		print("There was a memory warning.")
	}
	
	
	
	
	
	// MARK: - Notifications
	override func didUpdateReleases() {
		
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
			
			UIViewPropertyAnimator(duration: 0.5*ANIMATION_SPEED_MODIFIER, dampingRatio: 0.6, animations: { 
				
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
				
			}).startAnimation()
			
			if self.collectionView != nil && self.bottomScrollFadeView != nil {
				
				// adjust bottom scroll fade view alpha if collection view does not encroach upon its layout space
				UIViewPropertyAnimator(duration: 0.4*ANIMATION_SPEED_MODIFIER, curve: .easeOut, animations: { 
					
					if self.collectionView!.contentSize.height < self.view.bounds.height-self.bottomScrollFadeView!.bounds.height {
						self.bottomScrollFadeView?.alpha = 0.3
					} else {
						self.bottomScrollFadeView?.alpha = 1
					}
				}).startAnimation()
			}
		}
	}
	func nowPlayingArtistDidChange() {
		
		DispatchQueue.main.async {
			
			self.backdrop?.overlay.removeConstraint(self.nowPlayingArtistQuickViewButtonRestingConstraint)
			self.backdrop?.overlay.addConstraint(self.nowPlayingArtistQuickViewButtonHidingConstraint)
			
			let quickViewAnimator = UIViewPropertyAnimator(duration: 0.15*ANIMATION_SPEED_MODIFIER, curve: .easeOut, animations: {
				self.backdrop?.overlay.layoutIfNeeded()
			})
			
			quickViewAnimator.addCompletion({ (position) in
				
				self.nowPlayingArtistQuickViewButton.hideArtwork(false)
				self.nowPlayingArtistQuickViewButton.imageView.image = nil
				
				// if there is anartist to show quick view for AND	the artist is not already being followed
				if PreferenceManager.shared.nowPlayingArtist != nil && !PreferenceManager.shared.followingArtists.contains(where: { $0.itunesID == PreferenceManager.shared.nowPlayingArtist?.itunesID }) {
					
					DispatchQueue.global().async {
						
						// load all info for artist
						let additionalInfoTask = RequestManager.shared.getAdditionalInfo(for: PreferenceManager.shared.nowPlayingArtist!, completion: { (artist, error) in
							
							guard let artist = artist, error == nil else {
								return
							}
							
							PreferenceManager.shared.nowPlayingArtist = artist
							
							guard let thumbnailURL = PreferenceManager.shared.nowPlayingArtist?.artworkURLs[.thumbnail] else {
								return
							}
							
							let loadImageTask = RequestManager.shared.loadImage(from: thumbnailURL, completion: { (image, error) in
								
								guard let image = image, error == nil else {
									return
								}
								
								DispatchQueue.main.async {
									
									self.nowPlayingArtistQuickViewButton.imageView.image = image
									self.nowPlayingArtistQuickViewButton.showArtwork(false)
									
									self.backdrop?.overlay.removeConstraint(self.nowPlayingArtistQuickViewButtonHidingConstraint)
									self.backdrop?.overlay.addConstraint(self.nowPlayingArtistQuickViewButtonRestingConstraint)
									
									UIViewPropertyAnimator(duration: 0.5*ANIMATION_SPEED_MODIFIER, dampingRatio: 0.65, animations: {
										self.backdrop?.overlay.layoutIfNeeded()
									}).startAnimation()
								}
							})
						})
					}
				}
			})
			
			quickViewAnimator.startAnimation()
		}
	}

	
	
	
	
	// MARK: - IBActions
	@IBAction func showSearch(_ sender: Any) {
		let deadlineTime = DispatchTime.now() + .milliseconds(50)
		DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
			self.performSegue(withIdentifier: "NewReleases->ArtistSearch", sender: nil)
		}
	}
	@IBAction func handle(_ recognizer: UIGestureRecognizer) {
		
		guard let presentedViewController = self.presentedViewController as? SettingsViewController else {
			return
		}
		
		if recognizer.isKind(of: UIPanGestureRecognizer.self) {
			
			let progress = abs((recognizer as! UIPanGestureRecognizer).translation(in: presentedViewController.view).y / presentedViewController.view.frame.height)
			print(progress)
			
			switch recognizer.state {
				
			case .began:
				self.animationController = RevealBehindAnimatedTransitionController(forPresenting: false, interactively: true)
				presentedViewController.performSegue(withIdentifier: "Settings->NewReleases", sender: recognizer)
				break
				
			case .changed:
				
				if progress <= 1 {
					self.interactiveTransition?.update(progress)
				}
				break
				
			case .ended:
				
				if progress >= 0.3 {
					if progress > 0.75 || ((recognizer as! UIPanGestureRecognizer).velocity(in: self.view).y < 0 && abs((recognizer as! UIPanGestureRecognizer).velocity(in: self.view).y) > 1000) {
						self.interactiveTransition?.finish()
						self.backdrop?.overlay.isUserInteractionEnabled = true
						self.backdrop?.removeGestureRecognizer(self.tapGestureRecognizer)
						self.backdrop?.removeGestureRecognizer(self.panGestureRecognizer)

					} else {
						self.interactiveTransition?.cancel()
					}
				} else {
					if ((recognizer as! UIPanGestureRecognizer).velocity(in: self.view).y >= 0 && abs((recognizer as! UIPanGestureRecognizer).velocity(in: self.view).y) < 1000) {
						self.interactiveTransition?.cancel()
					} else {
						self.interactiveTransition?.finish()
						self.backdrop?.overlay.isUserInteractionEnabled = true
						self.backdrop?.removeGestureRecognizer(self.tapGestureRecognizer)
						self.backdrop?.removeGestureRecognizer(self.panGestureRecognizer)

					}
				}
				
				break
				
			default:
				self.interactiveTransition?.cancel()
				
			}
		}
			
		else if recognizer.isKind(of: UITapGestureRecognizer.self) {
			self.animationController = RevealBehindAnimatedTransitionController(forPresenting: false, interactively: false)
			presentedViewController.performSegue(withIdentifier: "Settings->NewReleases", sender: recognizer)
			self.backdrop?.overlay.isUserInteractionEnabled = true
			self.backdrop?.removeGestureRecognizer(self.tapGestureRecognizer)
			self.backdrop?.removeGestureRecognizer(self.panGestureRecognizer)

		}
	}

	
	
	// MARK: - Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Pass the selected object to the new view controller.
		
		self.isCurrentlyVisible = false
		
		if segue.identifier == "NewReleases->Release" {
			// set current release for release view controller
			var source = PreferenceManager.shared.newReleases
			switch self.collectionView?.indexPathsForSelectedItems?[0].section ?? 0 {
			case 0:
				source = PreferenceManager.shared.newReleases
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
			
			self.animationController = RevealBehindAnimatedTransitionController(forPresenting: true, interactively: false)
			segue.destination.transitioningDelegate = self
			UIViewPropertyAnimator(duration: 0.4*ANIMATION_SPEED_MODIFIER, curve: .easeOut, animations: {
				self.collectionView?.alpha = 0.15
			}).startAnimation()
			self.backdrop?.overlay.isUserInteractionEnabled = false
			self.backdrop?.addGestureRecognizer(self.tapGestureRecognizer)
			self.backdrop?.addGestureRecognizer(self.panGestureRecognizer)
			
		}
			
		else if segue.identifier == "NewReleases->ArtistSearch" {
			// self.searchButton.alpha = 0
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


extension NewReleasesViewController: UICollectionViewDataSourcePrefetching, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
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
			cell.releaseArtView.shadowed = false
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
}


extension NewReleasesViewController: UIViewControllerTransitioningDelegate {
	
	func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return self.animationController
	}
	func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
		return self.animationController
	}
}
