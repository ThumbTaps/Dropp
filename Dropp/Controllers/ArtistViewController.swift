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
    
    private var backdropDestinationAlpha: CGFloat!
    private var artworkDestinationTransform: CGAffineTransform!
		
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.backdropDestinationAlpha = self.artistArtworkBackdrop.alpha
        self.artworkDestinationTransform = self.artistArtworkImageView.transform
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            
            self.artistNameLabel.text = self.artist.name
            
            self.artistArtworkBackdrop.alpha = 0
            self.artistArtworkImageView.alpha = 0
            self.artistArtworkImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6).rotated(by: CGFloat(-30*Float.pi/180))
        }
        
        self.renderForArtistFollowingStatus()
    }
    
    func renderForArtistFollowingStatus() {
        if self.artist.isFollowed {
            self.followButton.setTitle("Unfollow", for: .normal)
            self.followButton.glyph = .close
            self.followButton.tintColor = UIColor(red:0.76, green:0.00, blue:0.23, alpha:1.00)
        } else {
            self.followButton.setTitle("Follow", for: .normal)
            self.followButton.glyph = .checkmark
            self.followButton.tintColor = self.view.tintColor
        }

        DispatchQueue.global().async {
            self.artist.getArtwork(thumbnail: !self.artist.isFollowed, completion: { (image, error) in
                guard error == nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    
                    if self.artist.isFollowed {
                        self.artistArtworkBackdrop.image = image
                    }
                    self.artistArtworkImageView.image = image
                    
                    let artworkAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: {
                        
                        self.artistArtworkBackdrop.alpha = self.artist.isFollowed ? self.backdropDestinationAlpha : 0
                        self.artistArtworkImageView.alpha = 1
                    })
                    
                    artworkAnimator.addCompletion({ (position) in
                        if position == .end {
                            if !self.artist.isFollowed {
                                self.artistArtworkBackdrop.image = nil
                            }
                        }
                    })
                        
                    artworkAnimator.startAnimation()
                    
                    UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.6/0.8, animations: {
                        self.artistArtworkImageView.transform = self.artworkDestinationTransform
                    }).startAnimation()
                }
            })
        }

    }
	
	@IBAction func toggleFollowingArtist() {
		if self.artist.isFollowed {
			self.artist.unfollow()
		} else {
			self.artist.follow()
		}
        
        self.renderForArtistFollowingStatus()
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
