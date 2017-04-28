//
//  ReleaseViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 1/13/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ReleaseViewController: DroppViewController {
	
	@IBOutlet weak var releaseArtworkView: ReleaseArtworkView!
	
	var currentRelease: Release!
	
	override var backButton: DroppButton? {
		return ReleasesButton()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.		
		self.title = self.currentRelease?.title
		
		// load artwork
		if self.currentRelease.artworkURL != nil {
			
			RequestManager.shared.loadImage(from: self.currentRelease.artworkURL!, completion: { (image, error) in
				
				guard let image = image, error == nil else {
					return
				}
				
				DispatchQueue.main.async {
					
					self.releaseArtworkView.imageView.image = image
					self.releaseArtworkView.showArtwork(true)
				}
				
			})?.resume()
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
