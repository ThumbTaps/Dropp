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
	
	var nowPlayingArtistArtworkTask: URLSessionDataTask?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// start monitoring now playing artist changes
		PreferenceManager.shared.nowPlayingArtistDidChangeNotification.add(self, selector: #selector(self.nowPlayingArtistDidChange))
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.searchBar.becomeFirstResponder()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		PreferenceManager.shared.nowPlayingArtistDidChangeNotification.remove(self)
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	
	
	override func adjustToTheme() {
		super.adjustToTheme()
		
		self.searchBar.barStyle = ThemeKit.barStyle
		let shouldBecomeFirstResponderAgain = self.searchBar.isFirstResponder
		self.searchBar.resignFirstResponder()
		self.searchBar.keyboardAppearance = ThemeKit.keyboardAppearance
		if shouldBecomeFirstResponderAgain { self.searchBar.becomeFirstResponder() }
	}
	func nowPlayingArtistDidChange() {
		self.collectionView?.reloadData()
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
			(segue.destination as? ArtistViewController)?.currentArtist = sender as? Artist
		}
		
		super.prepare(for: segue, sender: sender)
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

extension ArtistSearchViewController: UICollectionViewDataSourcePrefetching, UICollectionViewDataSource, UICollectionViewDelegate {
	
	// MARK: UICollectionViewDataSourcePrefetching
	func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
		
		self.nowPlayingArtistArtworkTask = PreferenceManager.shared.nowPlayingArtist?.loadThumbnail()
	}
	func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
		
		self.nowPlayingArtistArtworkTask?.cancel()
	}
	
	
	
	
	// MARK: UICollectionViewDataSource
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

		_ = nowPlayingArtist.loadThumbnail({
			
			DispatchQueue.main.async {
				cell.artistArtworkView.imageView.image = PreferenceManager.shared.nowPlayingArtist?.thumbnailImage
				cell.artistArtworkView.showArtwork(true)
			}
			
		})
		
		return cell
	}
	
	
	
	
	// MARK: UICollectionViewDelegate
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		guard let nowPlayingArtist = PreferenceManager.shared.nowPlayingArtist else {
			return
		}
		
		self.performSegue(withIdentifier: "showArtist", sender: nowPlayingArtist)
	}
}
