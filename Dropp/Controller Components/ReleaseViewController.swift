//
//  ReleaseViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 1/13/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit
import AVFoundation

class ReleaseViewController: DroppViewController {
	
	@IBOutlet weak var releaseArtworkView: ReleaseArtworkView!
	@IBOutlet var releaseArtworkViewFullScreenConstraint: NSLayoutConstraint!
	@IBOutlet weak var shareButton: ShareButton!
	@IBOutlet weak var viewOnButton: DroppButton!
	@IBOutlet weak var viewArtworkButton: ViewArtworkButton!
	
	var currentRelease: Release!
	var colorPalette: UIImageColors?
	
	var previewPlayer: AVPlayer?
	var currentlyPlayingTrackIndex: Int?
	
	override var indicator: UIView? {
		let emblem = ReleaseArtworkView()
		emblem.shadowed = true
		emblem.imageView?.image = self.currentRelease.thumbnailImage
		return emblem
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		self.title = self.currentRelease.title
		if let characterCount = self.title?.characters.count {
			self.headerHeight = CGFloat(100 + (30 * (CGFloat(characterCount) / (UIScreen.main.bounds.width / 14))))
		}
		
		if self.currentRelease.artist?.isBeingFollowed ?? false {
			
			// load artwork
			_ = self.currentRelease.loadArtwork({
				
				self.currentRelease.artworkImage?.getColors(completionHandler: { (imageColors) in
					self.colorPalette = imageColors
					
					DispatchQueue.main.async {
						
						UIView.transition(with: self.view, duration: 0.3 * ANIMATION_SPEED_MODIFIER, options: .transitionCrossDissolve, animations: {
							self.releaseArtworkView.imageView.image = self.currentRelease.artworkImage
							self.releaseArtworkView.showArtwork()
							self.releaseArtworkView.alpha = 1
							self.adjustToTheme()
						}, completion: nil)
					}
				})
			})
			
		} else {
			
			DispatchQueue.main.async {
				
				UIView.transition(with: self.view, duration: 0.3 * ANIMATION_SPEED_MODIFIER, options: .transitionCrossDissolve, animations: {
					self.adjustToTheme()
				}, completion: nil)
			}
		}
		
	}
	
	override func willMove(toParentViewController parent: UIViewController?) {
		
		if parent == nil {
			self.currentRelease.artworkImage = nil
			self.currentRelease.tracks = nil
		}
		
		super.willMove(toParentViewController: parent)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	func playTrack(_ sender: Any?) {
		
		// stop any currently playing tracks
		if self.currentlyPlayingTrackIndex != nil,
			let currentlyPlayingTrackCell = self.collectionView?.cellForItem(at: IndexPath(item: self.currentlyPlayingTrackIndex!, section: 1)) as? ReleaseTrackCollectionViewCell {
			self.stopTrack(currentlyPlayingTrackCell.previewButton.stopButton)
		}
			
		guard let previewButton = (sender as? UIView)?.superview as? PreviewButton else {
			return
		}
		
		let currentIndex = previewButton.tag
		guard let track = self.currentRelease.tracks?[currentIndex] else {
			return
		}
		guard let previewURL = track.previewURL else {
			return
		}
		
		let playerItem = AVPlayerItem(url: previewURL)
		self.previewPlayer = AVPlayer(playerItem: playerItem)
		self.previewPlayer?.volume = 1
		self.previewPlayer?.play()
			
		previewButton.setPlaying(true, animated: true)
		self.currentlyPlayingTrackIndex = currentIndex
	}
	
	func stopTrack(_ sender: Any?) {
		
		if let previewButton = (sender as? UIView)?.superview as? PreviewButton {
			self.previewPlayer?.pause()
			previewButton.setPlaying(false, animated: true)
		}
	}
	
	override func adjustToTheme() {
		
		self.navController?.view.tintColor = self.colorPalette?.primaryColor ?? ThemeKit.tintColor
		
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
		self.navController?.footerBackButton.destinationTitle.textColor = self.colorPalette?.primaryColor ?? ThemeKit.tintColor
		
		self.collectionView?.reloadData()
		
	}
	
	@IBAction func viewOn() {
		UIApplication.shared.open(self.currentRelease.itunesURL, options: [:], completionHandler: nil)
	}
	
	@IBAction func revealArtwork() {
		DispatchQueue.main.async {
			
			self.navController?.hideFooter(true)
			
			self.view.removeConstraint(self.releaseArtworkViewFullScreenConstraint)
			UIViewPropertyAnimator(duration: 0.45 * ANIMATION_SPEED_MODIFIER, dampingRatio: 0.8) {
				self.view.backgroundColor = self.colorPalette?.backgroundColor ?? ThemeKit.backgroundColor
				self.collectionView?.alpha = 0
				self.view.layoutIfNeeded()
				}.startAnimation()
		}
	}
	@IBAction func concealArtwork() {
		DispatchQueue.main.async {
			
			self.view.addConstraint(self.releaseArtworkViewFullScreenConstraint)
			let animation = UIViewPropertyAnimator(duration: 0.35 * ANIMATION_SPEED_MODIFIER, curve: .easeOut) {
				self.view.backgroundColor = ThemeKit.backgroundColor
				self.collectionView?.alpha = 1
				self.view.layoutIfNeeded()
			}
			
			animation.addCompletion({ (position) in
				if position == .end {
					self.navController?.showFooter(true)
				}
			})
			
			animation.startAnimation()
		}
	}
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
}


extension ReleaseViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
	
	// MARK: - UICollectionViewDataSource
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 2
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		switch section {
		case 0: return 2
		case 1: return self.currentRelease.tracks?.count ?? 0
		default: return 0
		}
	}
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ReleaseCollectionViewHeader", for: indexPath) as? HeaderCollectionReusableView
		
		switch indexPath.section {
		case 0: reusableView?.textLabel.text = "INFO"
			break
		case 1: reusableView?.textLabel.text = "TRACK LISTING"
			break
		default: reusableView?.textLabel.text = ""
		}
		if self.colorPalette?.backgroundColor.isDarkColor ?? false {
			reusableView?.backgroundColor = self.colorPalette?.backgroundColor.withBrightness(0.25).withAlpha(0.8)
		} else {
			reusableView?.backgroundColor = self.colorPalette?.backgroundColor.withAlpha(0.8) ?? ThemeKit.backdropOverlayColor
		}
		reusableView?.textLabel.textColor = self.colorPalette?.detailColor ?? ThemeKit.primaryTextColor
		reusableView?.strokeColor = self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) ? StyleKit.darkStrokeColor : StyleKit.lightStrokeColor
		
		return reusableView ?? UICollectionReusableView()
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		var cell: DroppCollectionViewCell?
		
		if indexPath.section == 0 {
			
			var badgedCell: BadgedCollectionViewCell?
			
			if indexPath.row == 0 {
				
				badgedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistCell", for: indexPath) as? BadgedCollectionViewCell
				
				badgedCell?.textLabel.text = self.currentRelease.artist.name
					
			}
			
			else if indexPath.row == 1 {

				badgedCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReleaseDateCell", for: indexPath) as? BadgedCollectionViewCell
					
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "MMM d, YYYY"
				dateFormatter.timeZone = .current
				if Date() == self.currentRelease.releaseDate {
					badgedCell?.textLabel.text = "Released Today"
				} else if Date() > self.currentRelease.releaseDate {
					badgedCell?.textLabel.text = "Released on \(dateFormatter.string(from: self.currentRelease.releaseDate))"
				} else {
					badgedCell?.textLabel.text = "Due on \(dateFormatter.string(from: self.currentRelease.releaseDate))"
				}
			}
			
			badgedCell?.badge?.tintColor = self.colorPalette?.primaryColor ?? ThemeKit.tintColor
			badgedCell?.textLabel.textColor = self.colorPalette?.primaryColor ?? ThemeKit.tintColor
			
			cell = badgedCell
			
		} else if indexPath.section == 1 {
			if let trackCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReleaseTrackCell", for: indexPath) as? ReleaseTrackCollectionViewCell {
				
				trackCell.trackNumberLabel.text = "\(indexPath.row + 1)."

				if let track = self.currentRelease.tracks?[indexPath.row] {
					trackCell.trackTitleLabel.text = track.title
					
					if (track.isStreamable ?? false) && track.previewURL != nil {
						trackCell.previewButton.isHidden = false
						
						// set action
						trackCell.previewButton.tag = indexPath.row
						trackCell.previewButton.playButton.addTarget(self, action: #selector(self.playTrack(_:)), for: .touchUpInside)
						trackCell.previewButton.stopButton.addTarget(self, action: #selector(self.stopTrack(_:)), for: .touchUpInside)
					} else {
						trackCell.previewButton.isHidden = true
					}
				}
				
				trackCell.trackTitleLabel.textColor = self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) ? StyleKit.darkPrimaryTextColor : StyleKit.lightPrimaryTextColor
				trackCell.trackNumberLabel.textColor = self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) ? StyleKit.darkSecondaryTextColor : StyleKit.lightSecondaryTextColor
				trackCell.previewButton.tintColor = self.colorPalette?.primaryColor ?? ThemeKit.tintColor
				
				cell = trackCell
			}
		}
		
		
		if self.colorPalette?.backgroundColor.isDarkColor ?? false {
			cell?.backgroundColor = self.colorPalette?.backgroundColor.withBrightness(0.25).withAlpha(0.8)
		} else {
			cell?.backgroundColor = self.colorPalette?.backgroundColor.withAlpha(0.8) ?? ThemeKit.backdropOverlayColor
		}
		cell?.selectedBackgroundView?.backgroundColor = self.colorPalette?.primaryColor.withAlpha(0.2) ?? ThemeKit.tintColor.withAlpha(0.2)
		cell?.strokeColor = self.colorPalette?.backgroundColor.isDarkColor ?? (PreferenceManager.shared.theme == .dark) ? StyleKit.darkStrokeColor : StyleKit.lightStrokeColor
		
		return cell ?? UICollectionViewCell()
	}
	
	
	
	// MARK: - UICollectionViewDelegate
	func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		return indexPath.section == 0
	}
	
	
	
	// MARK: - UICollectionViewDelegateFlowLayout
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		
		return CGSize(width: collectionView.frame.width, height: 50)
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		return CGSize(width: collectionView.frame.size.width, height: 50)
	}
	
}
