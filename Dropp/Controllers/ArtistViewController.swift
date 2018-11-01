//
//  ArtistViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 7/21/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

class ArtistViewController: UIViewController {
	
	var artist: Artist!
	
	let followButton = DroppButton()
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.title = self.artist.name
		self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
		self.navigationController?.navigationBar.shadowImage = UIImage()
		self.navigationController?.navigationBar.barTintColor = UIColor.clear
		
		self.followButton.frame = CGRect(origin: .zero, size: CGSize(width: 35, height: 35))
		self.followButton.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
		
		if self.artist.isFollowed {
			self.followButton.setTitle("Unfollow", for: .normal)
			self.followButton.glyph = .close
			self.followButton.tintColor = UIColor(red:0.76, green:0.00, blue:0.23, alpha:1.00)
			self.followButton.filled = true
		} else {
			self.followButton.setTitle("Follow", for: .normal)
			self.followButton.glyph = .checkmark
			self.followButton.tintColor = self.view.tintColor
			self.followButton.filled = false
		}
		
		self.followButton.addTarget(self, action: #selector(self.toggleFollowingArtist), for: .touchUpInside)
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.followButton)
    }
	override func viewWillDisappear(_ animated: Bool) {
		self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
		self.navigationController?.navigationBar.shadowImage = nil
		self.navigationController?.navigationBar.barTintColor = .white

		super.viewWillDisappear(animated)
	}
	
	@objc func toggleFollowingArtist() {
		if self.artist.isFollowed {
			self.artist.unfollow()
			
			DispatchQueue.main.async {
				
				self.followButton.setTitle("Follow", for: .normal)
				self.followButton.glyph = .checkmark
				self.followButton.tintColor = self.view.tintColor
				self.followButton.filled = false
			}

		} else {
			self.artist.follow()
			
			DispatchQueue.main.async {
				
				self.followButton.setTitle("Unfollow", for: .normal)
				self.followButton.glyph = .close
				self.followButton.tintColor = UIColor(red: 220, green: 30, blue: 60, alpha: 1)
				self.followButton.filled = true
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
