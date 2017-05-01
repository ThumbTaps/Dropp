//
//  ArtistSearchResultsViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson on 11/15/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ArtistSearchResultsViewController: DroppViewController {
	
	@IBOutlet weak var resultsSortingButton: SortButton!
	@IBOutlet weak var resultCoundIndicator: UIButton!
	
	var artistSearchResults: [Artist] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
        // Do any additional setup after loading the view.
		self.resultCoundIndicator.setTitle("\(self.artistSearchResults.count) Result\(self.artistSearchResults.count == 1 ? "" : "s")", for: .normal)
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
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
		
		super.prepare(for: segue, sender: sender)
    }

}

extension ArtistSearchResultsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.artistSearchResults.count
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: self.view.bounds.width, height: 50)
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistSearchResultCell", for: indexPath) as? ArtistCollectionViewCell else {
			return UICollectionViewCell()
		}
		
		cell.artistNameLabel.text = self.artistSearchResults[indexPath.row].name
		
		cell.backgroundColor = ThemeKit.backdropOverlayColor
		cell.artistNameLabel.textColor = ThemeKit.primaryTextColor
		
		return cell
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		// show existing following artist or from search results
		let selectedArtist = PreferenceManager.shared.followingArtists.first(where: { $0.itunesID == self.artistSearchResults[indexPath.row].itunesID }) ?? self.artistSearchResults[indexPath.row]
		var artistArtworkImage: UIImage?
		
		var remainingRequests = 3 {
			didSet {
				print(remainingRequests)
				if remainingRequests == 0 {
					// trigger segue
					self.performSegue(withIdentifier: "showArtist", sender: { (destination: ArtistViewController) in
						destination.currentArtist = selectedArtist
					})
				}
			}
		}
		
		// additional info request - 1
		RequestManager.shared.getAdditionalInfo(for: selectedArtist, completion: { (artist, error) in
			
			remainingRequests -= 1
			
			guard let artist = artist, error == nil else {
				print(error!)
				return
			}
			
			selectedArtist.summary = artist.summary
			selectedArtist.artworkURL = artist.artworkURL
			selectedArtist.thumbnailURL = artist.thumbnailURL
			
			_ = selectedArtist.loadArtwork {
				
				remainingRequests -= 1
			}
			
		})?.resume()
		
		
		// load releases - 3
		RequestManager.shared.getReleases(for: selectedArtist, completion: { (releases, error) in
			
			remainingRequests -= 1
			
			guard let releases = releases, error == nil else {
				print(error!)
				return
			}
			
			selectedArtist.releases = releases
			
		})?.resume()
	}
}
