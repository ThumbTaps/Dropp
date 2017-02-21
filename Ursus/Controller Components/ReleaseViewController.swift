//
//  ReleaseViewController.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/13/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ReleaseViewController: UrsusViewController {
	
	@IBOutlet weak var releaseArtworkView: ReleaseArtView!
	@IBOutlet weak var releaseTitleLabel: UILabel!
	
	var currentRelease: Release!
	var theme: Theme?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		if self.theme == nil {
			self.theme = PreferenceManager.shared.theme
		} else {
			// stop monitoring theme (forced by source view controller)
			PreferenceManager.shared.themeDidChangeNotification.remove(self)
		}
		
		self.releaseTitleLabel.text = self.currentRelease?.title
		
		// load artwork
		if self.currentRelease.artworkURL != nil {
			
			// show network activity indicator
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
			
			RequestManager.shared.loadImage(from: self.currentRelease.artworkURL!) { (image, error) in
				
				// hide network activity indicator
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
				
				if error == nil {
					
					DispatchQueue.main.async {
						
						self.releaseArtworkView.imageView.image = image
						self.releaseArtworkView.showArtwork(true)
					}
					
				} else {
					
				}
			}
		}
		
    }
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override func themeDidChange() {
		super.themeDidChange()
		
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
