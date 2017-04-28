//
//  ArtistSearchViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 4/17/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ArtistSearchViewController: DroppViewController {
	
	@IBOutlet weak var searchBar: UISearchBar!
	
	override var backButton: DroppButton? {
		let searchButton = SearchButton()
		searchButton.tintColor = ThemeKit.tertiaryTextColor
		return searchButton
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.searchBar.becomeFirstResponder()
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
		
		if segue.identifier == "showSearchResults" {
			if let searchTerm = self.searchBar.text, let searchResults = sender as? [Artist] {
				(segue.destination).title = "Results for '\(searchTerm)'"
				(segue.destination as? ArtistSearchResultsViewController)?.artistSearchResults = searchResults
			}
			
		}
		
		else if segue.identifier == "showArtist" {
			(segue.destination as? ArtistViewController)?.artist = sender as? Artist
		}
    }

}

extension ArtistSearchViewController: UISearchBarDelegate {
	func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
		
		searchBar.resignFirstResponder()
		self.navController?.pop()
	}
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		
		guard let searchTerm = searchBar.text else {
			return
		}
		
		searchBar.resignFirstResponder()
		_ = RequestManager.shared.search(for: searchTerm) { (artists, error) in
			guard error == nil else {
				print(error!)
				return
			}
			
			DispatchQueue.main.async {
				self.performSegue(withIdentifier: "showSearchResults", sender: artists)
			}
			
		}?.resume()
	}
}

extension ArtistSearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		if PreferenceManager.shared.nowPlayingArtist != nil {
			return 1
		}
		
		return 0
	}
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

		guard let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NowPlayingArtistCollectionViewHeader", for: indexPath) as? HeaderCollectionReusableView else {
			return UICollectionReusableView()
		}
		
		reusableView.textLabel.text = "NOW PLAYING"
		reusableView.backgroundColor = ThemeKit.backdropOverlayColor
		reusableView.textLabel.textColor = ThemeKit.primaryTextColor
		
		return reusableView
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if PreferenceManager.shared.nowPlayingArtist != nil {
			return 1
		}
		
		return 0
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NowPlayingArtistCell", for: indexPath) as? ArtistCollectionViewCell else {
			return UICollectionViewCell()
		}
		
		guard let nowPlayingArtist = PreferenceManager.shared.nowPlayingArtist else {
			return cell
		}
		
		cell.artistNameLabel.text = nowPlayingArtist.name
		cell.backgroundColor = ThemeKit.backdropOverlayColor
		cell.artistNameLabel.textColor = ThemeKit.primaryTextColor
		
		// check if thumbnail image needs to be downloaded
		guard let image = nowPlayingArtist.thumbnailImage else {
			guard let url = nowPlayingArtist.thumbnailURL else {
				return cell
			}
			
			RequestManager.shared.loadImage(from: url, completion: { (image, error) in
				
				guard let image = image, error == nil else {
					print(error!)
					return
				}
				
				// add loaded image to now playing artist if now playing artist hasn't changed since download began
				if PreferenceManager.shared.nowPlayingArtist?.itunesID ==
					nowPlayingArtist.itunesID {
					PreferenceManager.shared.nowPlayingArtist?.thumbnailImage = image
				}
				
				DispatchQueue.main.async {
					cell.artistArtworkView.imageView.image = image
					cell.artistArtworkView.showArtwork(true)
				}
				
			})?.resume()
			
			return cell
		}
		
		DispatchQueue.main.async {
			cell.artistArtworkView.imageView.image = image
			cell.artistArtworkView.showArtwork(true)
		}
		
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		guard let nowPlayingArtist = PreferenceManager.shared.nowPlayingArtist else {
			return
		}
		
		self.performSegue(withIdentifier: "showArtist", sender: nowPlayingArtist)
	}
}
