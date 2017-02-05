//
//  ArtistSearchResultsViewController.swift
//  Ursus
//
//  Created by Jeffery Jackson on 11/15/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ArtistSearchResultsViewController: UrsusViewController, UICollectionViewDataSource, UICollectionViewDelegate {
	
	var artistSearchResults: [Artist] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.collectionView?.contentInset = UIEdgeInsets(top: 80, left: 0, bottom: 80, right: 0)
		
		self.navigationTitle?.text = "\(self.artistSearchResults.count) Result\(self.artistSearchResults.count > 1 ? "s" : "")"
		self.themeDidChange()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	
	
	
	override func themeDidChange() {
		super.themeDidChange()
		
		DispatchQueue.main.async {
			
			self.view.backgroundColor = UIColor.clear
			if PreferenceManager.shared.theme == .dark {
				self.navigationTitle?.textColor = StyleKit.darkTertiaryTextColor
			} else {
				self.navigationTitle?.textColor = StyleKit.lightTertiaryTextColor
			}
		}
	}
	
	
	
	
	
	// MARK: - UICollectionView
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.artistSearchResults.count
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistSearchResultCell", for: indexPath) as! ArtistCollectionViewCell
		
		cell.artistNameLabel.text = self.artistSearchResults[indexPath.row].name
		
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		let selectedArtist: Artist? = self.artistSearchResults[indexPath.row]
		var artistArtworkImage: UIImage?
		
		guard selectedArtist != nil else {
			// TODO: Show error preparing displaying artist
			return
		}
		
		let totalRequests = 2
		var completedRequests = 0 {
			didSet {
				if completedRequests == totalRequests {
					// trigger segue
					self.performSegue(withIdentifier: "ArtistSearchResults->Artist", sender: { (destination: ArtistViewController) in
						destination.artist = selectedArtist
						destination.artistArtworkImage = artistArtworkImage
					})
				}
			}
		}
		
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		// load additional info for artist
		guard let additionalInfoTask = RequestManager.shared.getAdditionalInfo(for: selectedArtist!, completion: { (artist, error) in
			
			guard let artist = artist, error == nil else {
				print(error!)
				return
			}
			
			selectedArtist?.summary = artist.summary
			selectedArtist?.artworkURLs = artist.artworkURLs

			// load artist artwork
			guard let urlForArtwork = selectedArtist?.artworkURLs[.mega] else {
				print("Could not construct artwork URL", selectedArtist?.artworkURLs)
				return
			}

			guard let loadImageTask = RequestManager.shared.loadImage(from: urlForArtwork, completion: { (image, error) in
				
				guard let image = image, error == nil else {
					print(error)
					completedRequests += 1
					UIApplication.shared.isNetworkActivityIndicatorVisible = false
					
					return
				}
				
				artistArtworkImage = image
				
				completedRequests += 1
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
			}) else {
				
				print("Couldn't load artwork")
				completedRequests += 1
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				return
			}
			
		}) else {

			// TODO: Bail
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			return
		}
		
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		// load releases
		guard let releasesTask = RequestManager.shared.getReleases(for: selectedArtist!, completion: { (releases, error) in
			
			guard let releases = releases, error == nil else {
				print(error!)
				return
			}
			
			selectedArtist?.releases = releases
			
			completedRequests += 1
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
		}) else {
			
			// TODO: Bail
			UIApplication.shared.isNetworkActivityIndicatorVisible = false
			return
		}
	}
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
		
		if segue.identifier == "ArtistSearchResults->Artist" {
			(sender as! ((ArtistViewController) -> Void))(segue.destination as! ArtistViewController)
		}
    }

}
