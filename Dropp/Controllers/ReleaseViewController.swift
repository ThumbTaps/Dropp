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
    	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.releaseTitleLabel.text = self.release.title
        self.artistNameLabel.text = self.release.artist.name
        
        DispatchQueue.global().async {
            self.release.getArtwork(completion: { (image, error) in
                guard error == nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    
                    self.releaseArtworkBackdrop.image = image
                    self.releaseArtworkImageView.image = image
                }
            })
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
