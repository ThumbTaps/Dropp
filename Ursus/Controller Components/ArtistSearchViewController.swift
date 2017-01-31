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

    override func viewDidLoad() {
        super.viewDidLoad()

		// Do any additional setup after loading the view.
		
		self.searchBar.textField.delegate = self
		
		Notification.Name.UIApplicationWillResignActive.add(self, selector: #selector(self.applicationWillResignActive))
		
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
	func applicationWillResignActive() {
		
		self.searchBar.textField.resignFirstResponder()
		Notification.Name.UIApplicationWillResignActive.remove(self)
		// start listening for active notification
		Notification.Name.UIApplicationDidBecomeActive.add(self, selector: #selector(self.applicationDidBecomeActive))
		
	}
	func applicationDidBecomeActive() {
		
		self.searchBar.textField.becomeFirstResponder()
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
		
		self.searchBar.textField.resignFirstResponder()

		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		
		self.searchBar.startSearching()
		
		// trigger search
		RequestManager.shared.search(for: artistName, completion: { (artists, error) -> Void in
			guard let artists = artists, error == nil else {
				print(error!)
				return
			}
			
			if artists.count == 0 { // no results
				
				
			} else if artists.count == 1 { // go directly to artist view
				
				let artist = artists[0]

				UIApplication.shared.isNetworkActivityIndicatorVisible = true
				
				// get additional artist info
				RequestManager.shared.getAdditionalInfo(for: artist, completion: { (artist, error) in
					guard artist != nil, error == nil else {
						print(error!)
						UIApplication.shared.isNetworkActivityIndicatorVisible = false

						return
					}
					
					// get latest releases
					RequestManager.shared.getReleases(for: artist!, completion: { (releases, error) in
						guard let releases = releases, artist != nil, error == nil else {
							print(error!)
							UIApplication.shared.isNetworkActivityIndicatorVisible = false

							return
						}
						
						artist!.releases = releases
						
						// load artist artwork
						RequestManager.shared.loadImage(from: (artist?.artworkURLs[.mega])!, completion: { (image, error) in
							guard let image = image, artist != nil, error == nil else {
								print(error!)
								UIApplication.shared.isNetworkActivityIndicatorVisible = false

								return
							}
							
							UIApplication.shared.isNetworkActivityIndicatorVisible = false
							
							self.searchBar.endSearching {
								self.performSegue(withIdentifier: "ArtistSearch->Artist", sender: { (destination: ArtistViewController) in
									destination.artist = artist
									destination.artistArtworkImage = image
								})
							}
						})
						
					})
				})
				
			} else { // go to search results
				
				
			}
			
		})
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
            
        } else if segue.identifier == "ArtistSearch->Artist" {
			
            (sender as! ((ArtistViewController) -> Void))(segue.destination as! ArtistViewController)
            
        }

    }
}
