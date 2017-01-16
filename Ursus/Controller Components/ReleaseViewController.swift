//
//  ReleaseViewController.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/13/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ReleaseViewController: UrsusViewController {
	
	@IBOutlet weak var blurView: UIVisualEffectView!
	@IBOutlet weak var releaseArtworkView: ReleaseArtView!
	@IBOutlet weak var releaseTitleLabel: UILabel!
	
	var currentRelease: Release!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.releaseTitleLabel.text = self.currentRelease?.title
		
		// load artwork
		if self.currentRelease.artworkURL != nil {
			
			RequestManager.shared.loadImage(from: self.currentRelease.artworkURL!) { (image, error) in
				
				if error == nil {
					
					self.releaseArtworkView.imageView.image = image
					self.releaseArtworkView.showArtwork()
					
				} else {
					
				}
			}
		}
		
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
