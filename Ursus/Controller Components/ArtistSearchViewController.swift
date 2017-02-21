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
	@IBOutlet var dismissGestureRecognizer: UITapGestureRecognizer!
	@IBOutlet weak var searchBarHidingConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchBarCenteredConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchBarRestingConstraint: NSLayoutConstraint!
	
	var searching = false

    override func viewDidLoad() {
        super.viewDidLoad()

		// Do any additional setup after loading the view.
		
		self.searchBar.textField.delegate = self
		self.dismissGestureRecognizer.isEnabled = false
		
		Notification.Name.UIApplicationWillResignActive.add(self, selector: #selector(self.applicationWillResignActive))
		
		self.themeDidChange()
		
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.searchBar.becomeSearchBar()
		self.showSearchBar {
			
			self.dismissGestureRecognizer.isEnabled = true
			self.searchBar.textField.selectedTextRange = self.searchBar.textField.textRange(from: self.searchBar.textField.beginningOfDocument, to: self.searchBar.textField.endOfDocument)
		}
		let deadlineTime = DispatchTime.now() + .milliseconds(150)
		DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
			self.searchBar.textField.becomeFirstResponder()
		}
		
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
			self.view.removeConstraints([self.searchBarHidingConstraint, self.searchBarRestingConstraint])
			self.view.addConstraint(self.searchBarCenteredConstraint)
			
			UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
				self.view.layoutIfNeeded()
			}, completion: { (completed) in
				completion?()
			})
		}
	}
	func hideSearchBar(completion: (() -> Void)?=nil) {
		
		DispatchQueue.main.async {
			// update auto layout constraints
			self.view.removeConstraints([self.searchBarCenteredConstraint, self.searchBarRestingConstraint])
			self.view.addConstraint(self.searchBarHidingConstraint)
			
			UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*0.45, delay: 0, options: .curveEaseOut, animations: {
				self.view.layoutIfNeeded()
			}, completion: { (completed) in
				completion?()
			})
		}
	}
	func settleSearchBar(completion: (() -> Void)?=nil) {
		DispatchQueue.main.async {
			self.view.removeConstraints([self.searchBarCenteredConstraint, self.searchBarHidingConstraint])
			self.view.addConstraint(self.searchBarRestingConstraint)
			
			UIView.animate(withDuration: ANIMATION_SPEED_MODIFIER*0.9, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.7, options: .curveEaseOut, animations: {
				
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
				
				self.searching = false
				self.searchBar.endSearching {
					
					self.searchBar.textField.becomeFirstResponder()
					self.searchBar.textField.selectedTextRange = self.searchBar.textField.textRange(from: self.searchBar.textField.beginningOfDocument, to: self.searchBar.textField.endOfDocument)

				}
				
			} else if artists.count == 1 { // go directly to artist view
				
				let finalArtist = PreferenceManager.shared.followingArtists.first(where: { $0.itunesID == artists[0].itunesID }) ?? artists[0]

				UIApplication.shared.isNetworkActivityIndicatorVisible = true
				
				// get additional artist info
				guard let additionalInfoTask = RequestManager.shared.getAdditionalInfo(for: finalArtist!, completion: { (artist, error) in
					guard artist != nil, error == nil else {
						print(error!)
						UIApplication.shared.isNetworkActivityIndicatorVisible = false

						return
					}
					
					finalArtist?.summary = artist?.summary
					finalArtist?.artworkURLs = artist?.artworkURLs
					
					// get latest releases
					guard let getReleasesTask = RequestManager.shared.getReleases(for: finalArtist!, completion: { (releases, error) in
						guard let releases = releases, error == nil else {
							print(error!)
							UIApplication.shared.isNetworkActivityIndicatorVisible = false

							return
						}
						
						finalArtist?.releases = releases
						
						// load artist artwork
						guard let urlForArtwork = finalArtist?.artworkURLs[.mega] else {
							print("Could not construct artwork URL", finalArtist!.artworkURLs)
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
					self.settleSearchBar()
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
		
		if self.searchBar.textField.text!.characters.count == 0 {
			self.view.isUserInteractionEnabled = false
			self.dismissGestureRecognizer.isEnabled = false
			self.searchBar.textField.resignFirstResponder()
			self.searchBar.becomeButton()
			self.settleSearchBar()
				
			self.performSegue(withIdentifier: "ArtistSearch->NewReleases", sender: nil)
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
	override func prepareForUnwind(for segue: UIStoryboardSegue) {
		super.prepareForUnwind(for: segue)
		
		self.searching = false
		
		if segue.identifier == "ArtistSearchResults->ArtistSearch" {
			self.viewDidAppear(true)
		}
		
		else if segue.identifier == "Artist->ArtistSearch" {
			self.themeDidChange()
		}
	}
}
