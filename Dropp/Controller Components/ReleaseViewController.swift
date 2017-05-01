//
//  ReleaseViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 1/13/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ReleaseViewController: DroppViewController {
	
	@IBOutlet weak var releaseArtworkImageView: UIImageView!
	@IBOutlet weak var shareButton: ShareButton!
	
	var currentRelease: Release!
	var colorPalette: UIImageColors?
	
	override var backButton: DroppButton? {
		return ReleasesButton()
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
		self.title = self.currentRelease.title
		if let characterCount = self.title?.characters.count {
			self.headerHeight = CGFloat(100 + (30 * (CGFloat(characterCount) / (UIScreen.main.bounds.width / 14))))
		}
		
		// load artwork
		if self.currentRelease.artworkURL != nil {
			
			_ = self.currentRelease.loadArtwork({
				
				DispatchQueue.main.async {
					
					self.colorPalette = self.currentRelease.artworkImage?.getColors()
					self.releaseArtworkImageView.image = self.currentRelease.artworkImage
					
					DispatchQueue.main.async {
						
						if self.colorPalette != nil {
							
							self.navController?.view.tintColor = self.colorPalette?.primaryColor
							
							if self.colorPalette!.backgroundColor.isDarkColor {
								UIApplication.shared.statusBarStyle = .lightContent
								self.navController?.headerView.effect = UIBlurEffect(style: .dark)
								self.collectionView?.indicatorStyle = .white
								//							self.collectionView?.backgroundColor = StyleKit.darkBackdropOverlayColor
								self.collectionView?.backgroundColor = self.colorPalette?.backgroundColor.withBrightness(0.3).withAlpha(0.8)
							} else {
								
								UIApplication.shared.statusBarStyle = .default
								self.navController?.headerView.effect = UIBlurEffect(style: .light)
								self.collectionView?.indicatorStyle = .black
								//							self.collectionView?.backgroundColor = StyleKit.lightBackdropOverlayColor
								self.collectionView?.backgroundColor = self.colorPalette?.backgroundColor.withAlpha(0.8)
							}
							
							self.navController?.headerLabel.textColor = self.colorPalette?.detailColor
							self.navController?.footerViewContainer.backgroundColor = self.colorPalette?.backgroundColor
							self.navController?.footerBackButton.destinationTitle.textColor = self.colorPalette?.detailColor
						}
					}
				}
				
			})
		}
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	
	override func adjustToTheme() {
		
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


extension ReleaseViewController: UICollectionViewDataSource {
	
	// MARK: - UICollectionViewDataSource
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.currentRelease.tracks?.count ?? 0
	}
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		let reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ReleaseCollectionViewHeader", for: indexPath) as? HeaderCollectionReusableView
		if kind == UICollectionElementKindSectionHeader {
			
		}
		
		if self.colorPalette != nil {
			if self.colorPalette?.backgroundColor.isDarkColor ?? false {
				reusableView?.backgroundColor = self.colorPalette?.backgroundColor.withBrightness(0.3).withAlpha(0.8)
				reusableView?.strokeColor = StyleKit.darkStrokeColor
			} else {
				reusableView?.backgroundColor = self.colorPalette?.backgroundColor.withAlpha(0.8)
				reusableView?.strokeColor = StyleKit.lightStrokeColor
			}
			reusableView?.textLabel.textColor = self.colorPalette?.detailColor
		} else {
			
		}
		
		return reusableView ?? UICollectionReusableView()
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReleaseTrackCell", for: indexPath) as? ReleaseTrackCollectionViewCell
		
		cell?.trackNumberLabel.text = "\(indexPath.row + 1)."
		cell?.trackTitleLabel.text = self.currentRelease.tracks?[indexPath.row].title
		
		cell?.trackTitleLabel.textColor = self.colorPalette?.primaryColor
		cell?.trackNumberLabel.textColor = self.colorPalette?.detailColor
		
		if self.colorPalette != nil {
			
			if self.colorPalette?.backgroundColor.isDarkColor ?? false {
				cell?.backgroundColor = self.colorPalette?.backgroundColor.withBrightness(0.3).withAlpha(0.8)
				cell?.strokeColor = StyleKit.darkStrokeColor
			} else {
				cell?.backgroundColor = self.colorPalette?.backgroundColor.withAlpha(0.8)
				cell?.strokeColor = StyleKit.lightStrokeColor
			}
		} else {
			cell?.backgroundColor = ThemeKit.backdropOverlayColor
		}
		
		return cell ?? UICollectionViewCell()
	}
}
