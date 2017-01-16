//
//  ArtistSearchViewController.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/5/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ArtistSearchViewController: UrsusViewController, ArtistSearchBarDelegate, UIGestureRecognizerDelegate {
	
	@IBOutlet weak var blurView: UIVisualEffectView!
	@IBOutlet weak var searchBar: ArtistSearchBar!
	@IBOutlet weak var searchBarHidingConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchBarCenteredConstraint: NSLayoutConstraint!
	
	var transitionData: Any?

	private var _performingArtistSearch: Bool = false
	var performingArtistSearch: Bool {
		set {
			self._performingArtistSearch = newValue
			self.searchBar.isSearching = self._performingArtistSearch
		}
		get {
			return self._performingArtistSearch
		}
	}
	
	private var _searchResults: [Any]?
	var searchResults: Array<Any> {
		set {
			self._searchResults = newValue
			self.handleSearchResults()
		}
		get {
			return self._searchResults!
		}
	}

    override func viewDidLoad() {
        super.viewDidLoad()

		// Do any additional setup after loading the view.
		
		self.searchBar.delegate = self
		
		// start blur view off as nil (why on earth can't this be done from IB?)
		self.blurView.effect = nil
		
		Notification.Name.UIApplicationWillResignActive.add(self, selector: #selector(self.applicationWillResignActive))
		
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
				
		self.searchBar.textField.becomeFirstResponder()
		
		searchBar.textField.selectedTextRange = searchBar.textField.textRange(from: searchBar.textField.beginningOfDocument, to: searchBar.textField.endOfDocument)
		
		DispatchQueue.main.async {
			
			// update auto layout constraints
			self.view.removeConstraint(self.searchBarHidingConstraint)
			self.view.addConstraint(self.searchBarCenteredConstraint)
			
			UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
				self.view.layoutIfNeeded()
			})
			
			UIView.animate(withDuration: 0.4, animations: {
				
				if PreferenceManager.shared.themeMode == .dark {
					self.blurView.effect = UIBlurEffect(style: .dark)
				} else {
					self.blurView.effect = UIBlurEffect(style: .light)
				}
				
			})
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	
	
	
	// MARK: - Notifications
	func applicationWillResignActive() {
		
		// start listening for active notification
		Notification.Name.UIApplicationDidBecomeActive.add(self, selector: #selector(self.applicationDidBecomeActive))
		
		self.searchBar.textField.resignFirstResponder()
	}
	func applicationDidBecomeActive() {
		
		// start listening for inactive notification
		Notification.Name.UIApplicationWillResignActive.add(self, selector: #selector(self.applicationWillResignActive))
		
		self.searchBar.textField.becomeFirstResponder()
	}
	override func themeDidChange() {
		
		super.themeDidChange()
		
		DispatchQueue.main.async {
			
			if PreferenceManager.shared.themeMode == .dark {
				self.blurView.effect = UIBlurEffect(style: .dark)
			} else {
				self.blurView.effect = UIBlurEffect(style: .light)
			}
			
		}

	}
	
	
	
	
	
	// MARK: - Custom Functions
	func performSearch(for artist: String!) {
		self.performingArtistSearch = true
		
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		
		// trigger search
		RequestManager.shared.search(for: artist, on: .iTunes, completion: { (itunesResponse, error) -> Void in

            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            guard error == nil else {
                
                print(error!)
                return
            }
            
            self.searchResults = itunesResponse!
	
		})
	}
	func handleSearchResults() {
		if self.searchResults.count == 0 { // no results
			
			
		} else if self.searchResults.count == 1 { // go directly to artist view
			
			let itunesArtistInfo = self.searchResults[0] as! [String: Any]
			
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			
			// get artist info from last.fm
			RequestManager.shared.search(for: itunesArtistInfo["artistName"] as! String, on: .LastFM, completion: { (lastFMResponse, error) in
				
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				
				let lastFMArtistInfo = (lastFMResponse! as [Any])[0] as! [String: Any]
				
				// get artwork URLs
				if let artistImages = lastFMArtistInfo["image"] as? [[String: Any]] {
					
					// construct array
					var artistArtworkURLs: [String: URL] = [:]
					artistImages.forEach({ (current) in
						let url = current["#text"] as! String
						artistArtworkURLs[current["size"] as! String] = URL(string: url)!
					})
					
					UIApplication.shared.isNetworkActivityIndicatorVisible = true
					
					RequestManager.shared.getReleases(for: itunesArtistInfo["artistId"] as! Int, completion: { (releases, error) in
						
						UIApplication.shared.isNetworkActivityIndicatorVisible = false
						
						// create artist object
						let artist = Artist(
							itunesID: itunesArtistInfo["artistId"] as! Int,
							name: itunesArtistInfo["artistName"] as! String,
							itunesURL: URL(string: itunesArtistInfo["artistLinkUrl"] as! String),
							summary: (lastFMArtistInfo["bio"] as? [String: Any])?["summary"] as? String,
							genre: itunesArtistInfo["primaryGenreName"] as? String,
							artworkURLs: artistArtworkURLs,
							releases: releases
						)
						
						UIApplication.shared.isNetworkActivityIndicatorVisible = true
						
						// Load artwork
						RequestManager.shared.loadImage(from: artist.artworkURLs!["mega"]!) { (artworkImage, error) in
							
							UIApplication.shared.isNetworkActivityIndicatorVisible = false
							
							let artistViewData: [String: Any] = [
								"artist": artist,
								"artistArtwork": artworkImage!
							]
							
							self.transitionData = artistViewData
							
							self.performingArtistSearch = false
							
							
						}
						
					})
					
				}
			})
			
		} else { // go to search results
			
			
		}
	}
	
	
	
	
	// MARK: - ArtistSearchBarDelegate
	func searchBarTextFieldDidChange(_ searchBar: ArtistSearchBar) {
		
	}
	func searchBar(_ searchBar: ArtistSearchBar, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		let currentCharacterCount = searchBar.textField.text?.characters.count ?? 0
		if (range.length + range.location > currentCharacterCount){
			return false
		}
		let newLength = currentCharacterCount + string.characters.count - range.length
		return newLength <= 60
	}
	func searchBarShouldReturn(_ searchBar: ArtistSearchBar) -> Bool {
		
		self.performSearch(for: self.searchBar.textField.text)
		
		self.searchBar.textField.resignFirstResponder()
		
		return true
	}
	func searchBarShouldShowCompletedSearch(_ searchBar: ArtistSearchBar) -> Bool {
		
		return !self.performingArtistSearch
	}
	func searchBarDidShowCompletedSearch(_ searchBar: ArtistSearchBar) {
		
		self.performSegue(withIdentifier: "ArtistSearch->Artist", sender: self.transitionData)
	}

	
	



	
	// MARK: - Navigation
	@IBAction func dismissSearch(_ sender: Any) {
		
		if self.searchBar.textField.text!.characters.count > 0 {
			
		} else {
			
			self.performSegue(withIdentifier: "ArtistSearch->NewReleases", sender: nil)
		}
	}
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ArtistSearch->ArtistSearchResults" {
            
        } else if segue.identifier == "ArtistSearch->Artist" {
            
            // pass off artist information
            if let artistData = sender as? [String: Any] {
                (segue.destination as! ArtistViewController).artist = artistData["artist"] as? Artist
                (segue.destination as! ArtistViewController).artistArtwork = artistData["artistArtwork"] as? UIImage
            }
            
        }

    }
}
