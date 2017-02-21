//
//  ArtistsViewController.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/13/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ArtistsViewController: UrsusViewController, UICollectionViewDataSourcePrefetching, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	var artistsArtwork = [UIImage?](repeating: nil, count: PreferenceManager.shared.followingArtists.count)
	var artworkDownloadTasks = [URLSessionDataTask?](repeating: nil, count: PreferenceManager.shared.followingArtists.count)
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	
	
	// MARK: - UICollectionViewDataSourcePrefetching
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		
		indexPaths.forEach { (indexPath) in
			
			guard let artworkURL = PreferenceManager.shared.followingArtists[indexPath.row].artworkURLs[.thumbnail] else {
				return
			}
			
			DispatchQueue.global().async {
				
				if let artworkTask = RequestManager.shared.loadImage(from: artworkURL, completion: { (image, error) in
					
					if let image = image, error == nil {
						self.artistsArtwork[indexPath.row] = image
					}
					
				}) {
					self.artworkDownloadTasks[indexPath.row] = artworkTask
				}
			}
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
		cell.artistArtView.hideArtwork()
		
		guard let image = self.artistsArtwork[indexPath.row] else {
			
			guard let url = artist.artworkURLs[.thumbnail] else {
				return cell
			}
			
			DispatchQueue.global().async {
				
				let artworkTask = RequestManager.shared.loadImage(from: url, completion: { (image, error) in
					
					guard let image = image, error == nil else {
						print(error!)
						return
					}
					
					// add loaded image to prefetch source
					self.artistsArtwork[indexPath.row] = image
					
					DispatchQueue.main.async {
						cell.artistArtView.imageView.image = image
						cell.artistArtView.showArtwork(true)
					}
				})
			}
			
			return cell
		}
		
		DispatchQueue.main.async {
			cell.artistArtView.imageView.image = image
			cell.artistArtView.showArtwork()
		}
				
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: self.view.bounds.width, height: 100)
	}

	
	
	
	
	
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		
		
    }

}
