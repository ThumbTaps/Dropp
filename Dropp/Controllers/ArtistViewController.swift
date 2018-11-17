//
//  ArtistViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 7/21/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

class ArtistViewController: CardViewController {
	
    @IBOutlet weak var followButton: DroppButton!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var artistArtworkBackdrop: UIImageView!
    @IBOutlet weak var artistArtworkImageView: ArtistArtworkImageView!
    
	var artist: Artist!
		
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.artistNameLabel.text = self.artist.name
        
        DispatchQueue.global().async {
            self.artist.getArtwork(completion: { (image, error) in
                guard error == nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    
                    self.artistArtworkBackdrop.image = image
                    self.artistArtworkImageView.image = image
                }
            })
        }
		
		if self.artist.isFollowed {
			self.followButton.setTitle("Unfollow", for: .normal)
			self.followButton.glyph = .close
			self.followButton.tintColor = UIColor(red:0.76, green:0.00, blue:0.23, alpha:1.00)
		} else {
			self.followButton.setTitle("Follow", for: .normal)
			self.followButton.glyph = .checkmark
			self.followButton.tintColor = self.view.tintColor
		}
		
    }
	override func viewWillDisappear(_ animated: Bool) {
		self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
		self.navigationController?.navigationBar.shadowImage = nil
		self.navigationController?.navigationBar.barTintColor = .white

		super.viewWillDisappear(animated)
	}
	
	@IBAction func toggleFollowingArtist() {
		if self.artist.isFollowed {
			self.artist.unfollow()
			
			DispatchQueue.main.async {
				
				self.followButton.setTitle("Follow", for: .normal)
				self.followButton.glyph = .checkmark
				self.followButton.tintColor = self.view.tintColor
			}

		} else {
			self.artist.follow()
			
			DispatchQueue.main.async {
				
				self.followButton.setTitle("Unfollow", for: .normal)
				self.followButton.glyph = .close
                self.followButton.tintColor = UIColor(red:0.76, green:0.00, blue:0.23, alpha:1.00)
			}
		}
	}
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
