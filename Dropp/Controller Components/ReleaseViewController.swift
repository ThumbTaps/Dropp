//
//  ReleaseViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 1/13/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit
import AVFoundation

class ReleaseViewController: DroppModalViewController {
	
	@IBOutlet weak var releaseArtworkView: ReleaseArtworkView!
	@IBOutlet weak var releaseTitleLabel: UILabel!
	@IBOutlet weak var artistNameButton: DroppButton!
	@IBOutlet weak var releaseDateLabel: UILabel!
	@IBOutlet weak var shareButton: ShareButton!
	@IBOutlet weak var viewOnButton: DroppButton!
	@IBOutlet weak var viewArtworkButton: ViewArtworkButton!
	
	var currentRelease: Release!
	
	var previewPlayer: AVPlayer?
	var currentlyPlayingTrackIndex: Int?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.releaseTitleLabel.text = self.currentRelease.title
		self.artistNameButton.setTitle(self.currentRelease.artist.name, for: .normal)
		self.releaseDateLabel.text = self.currentRelease.releaseDate.string(prefixed: true)
		
		_ = self.currentRelease.loadArtwork {
			
			self.releaseArtworkView.imageView.image = self.currentRelease.artworkImage
			self.releaseArtworkView.showArtwork(false)
		}
		
		if let layout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
			layout.sectionHeadersPinToVisibleBounds = false
		}

		if self.currentRelease.tracks == nil {
			
			_ = self.currentRelease.loadTracks {
				self.collectionView?.reloadData()
			}
		}
		
		if !UIAccessibilityIsReduceMotionEnabled() {
			self.releaseArtworkView.enableParallax(amount: 15)
		}
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		self.currentRelease.artworkImage = nil
	}
	
	func playTrack(_ sender: Any?) {
		
		guard let previewButton = (sender as? UIView)?.superview as? PreviewButton else {
			return
		}
		
		if self.currentlyPlayingTrackIndex != nil,
			let currentlyPlayingTrackCell = self.collectionView?.cellForItem(at: IndexPath(item: self.currentlyPlayingTrackIndex!, section: 1)) as? ReleaseTrackCollectionViewCell,
			self.currentlyPlayingTrackIndex != previewButton.tag {
			self.stopTrack(currentlyPlayingTrackCell.previewButton.stopButton)
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
		super.adjustToTheme()
		
		DispatchQueue.main.async {
			
			self.view.tintColor = self.currentRelease.colorPalette?.primaryColor.shadow(withLevel: 0.2) ?? ThemeKit.tintColor
		}
	}
	
	@IBAction func viewOn() {
		UIApplication.shared.open(self.currentRelease.itunesURL, options: [:], completionHandler: nil)
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
		return 1
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		
		return self.currentRelease.tracks?.count ?? 0
	}
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ReleaseCollectionViewHeader", for: indexPath) as? HeaderCollectionReusableView
		
		DispatchQueue.main.async {
			
			reusableView?.textLabel.text = "TRACK LISTING"
			reusableView?.backgroundColor = ThemeKit.backdropOverlayColor
			reusableView?.textLabel.textColor = ThemeKit.primaryTextColor
			reusableView?.strokeColor = ThemeKit.strokeColor
		}
		
		return reusableView ?? UICollectionReusableView()
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell: ReleaseTrackCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReleaseTrackCell", for: indexPath) as! ReleaseTrackCollectionViewCell
		
		DispatchQueue.main.async {
			
			if let track = self.currentRelease.tracks?[indexPath.row] {
				cell.trackNumberLabel.text = String(track.trackNumber)
				cell.trackTitleLabel.text = track.title
				
				if (track.isStreamable ?? false) && track.previewURL != nil {
					cell.previewButton.isHidden = false
					
					// set action
					cell.previewButton.tag = indexPath.row
					cell.previewButton.playButton.addTarget(self, action: #selector(self.playTrack(_:)), for: .touchUpInside)
					cell.previewButton.stopButton.addTarget(self, action: #selector(self.stopTrack(_:)), for: .touchUpInside)
				} else {
					cell.previewButton.isHidden = true
				}
			}
			
			cell.trackNumberLabel.textColor = ThemeKit.tertiaryTextColor
			cell.trackTitleLabel.textColor = ThemeKit.primaryTextColor
			cell.backgroundColor = ThemeKit.backdropOverlayColor.withAlpha(0.7)
			cell.strokeColor = ThemeKit.strokeColor
		}
		
		return cell
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
