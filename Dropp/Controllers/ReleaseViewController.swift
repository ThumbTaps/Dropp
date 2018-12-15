//
//  ReleaseViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 7/21/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

class ReleaseViewController: CardViewController {
	
	var release: Release!
    
    @IBOutlet weak var releaseTitleLabel: UILabel!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var releaseArtworkImageView: ReleaseArtworkImageView!
    @IBOutlet weak var releaseArtworkBackdrop: UIImageView!
    @IBOutlet weak var releaseDateLabel: UILabel!
    	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.releaseTitleLabel.text = self.release.title
        self.artistNameLabel.text = self.release.artist.name
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        self.releaseDateLabel.text = formatter.string(from: self.release.releaseDate)
        
        let backdropDestinationAlpha = self.releaseArtworkBackdrop.alpha
        self.releaseArtworkBackdrop.alpha = 0
        self.releaseArtworkImageView.alpha = 0
        let artworkDestinationTransform = self.releaseArtworkImageView.transform
        self.releaseArtworkImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6).rotated(by: CGFloat(-30*Float.pi/180))
        
        DispatchQueue.global().async {
            self.release.getArtwork(completion: { (image, error) in
                guard error == nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    
                    self.releaseArtworkBackdrop.image = image
                    self.releaseArtworkImageView.image = image
                    
                    UIViewPropertyAnimator(duration: 0.5, curve: .easeOut, animations: {
                        self.releaseArtworkBackdrop.alpha = backdropDestinationAlpha
                        self.releaseArtworkImageView.alpha = 1
                    }).startAnimation()
                    
                    UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.6/0.8, animations: {
                        self.releaseArtworkImageView.transform = artworkDestinationTransform
                    }).startAnimation()
                }
            })
        }
    }
    
    @IBAction func share() {
        let activityViewController = UIActivityViewController(activityItems: [self.release.artworkURL], applicationActivities: [])
        activityViewController.view.tintColor = self.view.tintColor
        self.present(activityViewController, animated: true, completion: nil)
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
