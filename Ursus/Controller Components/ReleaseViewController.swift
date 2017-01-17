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
	var themeMode: ThemeMode?
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		if self.themeMode == nil {
			self.themeMode = PreferenceManager.shared.themeMode
		} else {
			// stop monitoring theme (forced by source view controller)
			Notification.Name.UrsusThemeDidChange.remove(self)
		}
		
		self.releaseTitleLabel.text = self.currentRelease?.title
		
		self.blurView.effect = nil
		
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
						self.releaseArtworkView.showArtwork()
					}
					
				} else {
					
				}
			}
		}
		
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		DispatchQueue.main.async {
			
			UIView.animate(withDuration: 0.4, animations: {
				
				if self.themeMode == .dark {
					self.blurView.effect = UIBlurEffect(style: .dark)
				} else {
					self.blurView.effect = UIBlurEffect(style: .light)
				}
				
			})
		}
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		get {
			if self.themeMode == .dark {
				return .lightContent
			} else {
				return .default
			}
		}
	}

	override func themeDidChange() {
		super.themeDidChange()
		
		DispatchQueue.main.async {
			
			if self.themeMode == .dark {
				self.blurView.effect = UIBlurEffect(style: .dark)
			} else {
				self.blurView.effect = UIBlurEffect(style: .light)
			}
			
		}

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
