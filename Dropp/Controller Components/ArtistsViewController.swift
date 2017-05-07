//
//  ArtistsViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 1/13/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ArtistsViewController: DroppViewController {
	
	@IBOutlet weak var searchButton: SearchButton!
	@IBOutlet weak var settingsButton: SettingsButton!
	
	var artworkDownloadTasks = [URLSessionDataTask?](repeating: nil, count: PreferenceManager.shared.followingArtists.count)
	
	override var indicator: UIView? {
		return ArtistsButton()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	override func willMove(toParentViewController parent: UIViewController?) {
		
		PreferenceManager.shared.followingArtists.forEach({
			$0.thumbnailImage = nil
			$0.artworkImage = nil
		})
		
		super.willMove(toParentViewController: parent)
	}
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		
		if segue.identifier == "showArtist" {
			
			if let selectedIndex = self.collectionView?.indexPathsForSelectedItems?[0].row {
				
				(segue.destination as? ArtistViewController)?.currentArtist = PreferenceManager.shared.followingArtists[selectedIndex]
			}
		}

		super.prepare(for: segue, sender: sender)
    }
}

extension ArtistsViewController: UICollectionViewDataSourcePrefetching, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	// MARK: - UICollectionViewDataSourcePrefetching
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		
		indexPaths.forEach { (indexPath) in
			
			let artworkTask = PreferenceManager.shared.followingArtists[indexPath.row].loadArtwork(thumbnailOnly: true) {
				self.artworkDownloadTasks[indexPath.row] = nil
			}
			self.artworkDownloadTasks[indexPath.row] = artworkTask
		}
	}
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		
		indexPaths.forEach { (indexPath) in
			self.artworkDownloadTasks[indexPath.row]?.cancel()
		}
	}
	
	
	// MARK: - UICollectionViewDataSource
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return PreferenceManager.shared.followingArtists.count
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistCell", for: indexPath) as! ArtistCollectionViewCell
		
		let artist = PreferenceManager.shared.followingArtists[indexPath.row]
		
		cell.artistNameLabel.text = artist.name
		cell.backgroundColor = ThemeKit.backdropOverlayColor
		cell.artistNameLabel.textColor = ThemeKit.primaryTextColor
		cell.selectedBackgroundView?.backgroundColor = ThemeKit.tintColor.withAlpha(0.4)
		cell.artistArtworkView.backgroundColor = ThemeKit.backgroundColor
		cell.artistArtworkView.hideArtwork()
		
		
//		DispatchQueue.main.async {
		
			_ = artist.loadArtwork(thumbnailOnly: true) {
			
				cell.artistArtworkView.imageView.image = artist.thumbnailImage
				cell.artistArtworkView.showArtwork(true)
			}
//		}
		
		return cell
	}
	
	
	
	// MARK: - UICollectionViewDelegateFlowLayout
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		
		return .zero // CGSize(width: collectionView.frame.width, height: 50)
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		return CGSize(width: collectionView.frame.size.width, height: 80)
	}

}
