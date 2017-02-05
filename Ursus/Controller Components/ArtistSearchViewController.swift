//
//  ArtistSearchViewController.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/5/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ArtistSearchViewController: UrsusViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
	
	@IBOutlet weak var searchBar: ArtistSearchBar!
	@IBOutlet weak var searchBarHidingConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchBarCenteredConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchBarRestingConstraint: NSLayoutConstraint!
	
	var searching = false

    override func viewDidLoad() {
        super.viewDidLoad()

		// Do any additional setup after loading the view.
		
		self.searchBar.textField.delegate = self
		
		Notification.Name.UIApplicationWillResignActive.add(self, selector: #selector(self.applicationWillResignActive))
		
		self.themeDidChange()
		
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.searchBar.textField.becomeFirstResponder()
		self.searchBar.textField.selectedTextRange = searchBar.textField.textRange(from: searchBar.textField.beginningOfDocument, to: searchBar.textField.endOfDocument)
		self.showSearchBar()
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	
	
	
	// MARK: - Notifications
	override func themeDidChange() {
		super.themeDidChange()
		
		DispatchQueue.main.async {
			
			self.view.backgroundColor = UIColor.clear
		}
	}
	func applicationWillResignActive() {
		
		self.searchBar.textField.resignFirstResponder()
		Notification.Name.UIApplicationWillResignActive.remove(self)
		// start listening for active notification
		Notification.Name.UIApplicationDidBecomeActive.add(self, selector: #selector(self.applicationDidBecomeActive))
		
	}
	func applicationDidBecomeActive() {
		
		if !self.searching {
			self.searchBar.textField.becomeFirstResponder()
		}
			
		Notification.Name.UIApplicationDidBecomeActive.remove(self)
		// start listening for inactive notification
		Notification.Name.UIApplicationWillResignActive.add(self, selector: #selector(self.applicationWillResignActive))
	}
	
	
	
	
	
	// MARK: - Custom Functions
	func showSearchBar(completion: (() -> Void)?=nil) {
			
		DispatchQueue.main.async {
			// update auto layout constraints
			self.view.removeConstraint(self.searchBarHidingConstraint)
			self.view.addConstraint(self.searchBarCenteredConstraint)
			
			UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
				self.view.layoutIfNeeded()
			}, completion: { (completed) in
				completion?()
			})
		}
	}
	func hideSearchBar(completion: (() -> Void)?=nil) {
		
		DispatchQueue.main.async {
			// update auto layout constraints
			self.view.removeConstraint(self.searchBarCenteredConstraint)
			self.view.addConstraint(self.searchBarHidingConstraint)
			
			UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
				self.view.layoutIfNeeded()
			}, completion: { (completed) in
				completion?()
			})
		}
	}
	func performSearch(for artistName: String!) {
		
		self.searching = true
		
		self.searchBar.textField.resignFirstResponder()

		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		
		self.searchBar.startSearching()
		
		// trigger search
		guard let searchTask = RequestManager.shared.search(for: artistName, completion: { (artists, error) -> Void in
			
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			
			guard let artists = artists, error == nil else {
				print(error!)
				return
			}
			
			if artists.count == 0 { // no results
				
				
			} else if artists.count == 1 { // go directly to artist view
				
				let finalArtist = artists[0]

				UIApplication.shared.isNetworkActivityIndicatorVisible = true
				
				// get additional artist info
				guard let additionalInfoTask = RequestManager.shared.getAdditionalInfo(for: finalArtist, completion: { (artist, error) in
					guard artist != nil, error == nil else {
						print(error!)
						UIApplication.shared.isNetworkActivityIndicatorVisible = false

						return
					}
					
					finalArtist.summary = artist?.summary
					finalArtist.artworkURLs = artist?.artworkURLs
					
					// get latest releases
					guard let getReleasesTask = RequestManager.shared.getReleases(for: finalArtist, completion: { (releases, error) in
						guard let releases = releases, error == nil else {
							print(error!)
							UIApplication.shared.isNetworkActivityIndicatorVisible = false

							return
						}
						
						finalArtist.releases = releases
						
						// load artist artwork
						guard let urlForArtwork = finalArtist.artworkURLs[.mega] else {
							print("Could not construct artwork URL", finalArtist.artworkURLs)
							return
						}
						guard let loadImageTask = RequestManager.shared.loadImage(from: urlForArtwork, completion: { (image, error) in
							guard error == nil else {
								print(error!)
								UIApplication.shared.isNetworkActivityIndicatorVisible = false

								return
							}
							
							UIApplication.shared.isNetworkActivityIndicatorVisible = false
							
							self.searchBar.endSearching {
								self.performSegue(withIdentifier: "ArtistSearch->Artist", sender: { (destination: ArtistViewController) in
									destination.artist = finalArtist
									destination.artistArtworkImage = image
								})
							}
						}) else {
							return
						}
						
					}) else {
						return
					}
				}) else {
					return
				}
				
			} else { // go to search results
				
				self.searchBar.endSearching {
					self.searchBar.becomeButton()
					
					DispatchQueue.main.async {
						self.view.removeConstraint(self.searchBarCenteredConstraint)
						self.view.addConstraint(self.searchBarRestingConstraint)
						
						UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
							
							self.view.layoutIfNeeded()
						}, completion: nil)
					}
					
					self.performSegue(withIdentifier: "ArtistSearch->ArtistSearchResults", sender: artists)

				}
				
			}
			
		}) else {
			
			self.searching = false
			self.searchBar.endSearching()
			
			return
		}
	}




	// MARK: - ArtistSearchBarDelegate
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
		let currentCharacterCount = self.searchBar.textField.text?.characters.count ?? 0
		if (range.length + range.location > currentCharacterCount){
			return false
		}
		let newLength = currentCharacterCount + string.characters.count - range.length
		return newLength <= 60
	}
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		self.performSearch(for: self.searchBar.textField.text)
		
		return true
	}

	
	



	
	// MARK: - Navigation
	@IBAction func dismissSearch(_ sender: Any) {
		
		if self.searchBar.textField.text!.characters.count > 0 {
			
		} else {
			
			self.searchBar.textField.resignFirstResponder()
			self.hideSearchBar {
				self.performSegue(withIdentifier: "ArtistSearch->NewReleases", sender: nil)
			}
		}
	}
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "ArtistSearch->NewReleases" {
			
		} else if segue.identifier == "ArtistSearch->ArtistSearchResults" {
			
			(segue.destination as! ArtistSearchResultsViewController).artistSearchResults = sender as! [Artist]
            
        } else if segue.identifier == "ArtistSearch->Artist" {
			
            (sender as! ((ArtistViewController) -> Void))(segue.destination as! ArtistViewController)
            
        }

    }
}
