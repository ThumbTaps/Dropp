//
//  ArtistCollectionViewCell.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 12/25/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class ArtistCollectionViewCell: UrsusCollectionViewCell {
	
	@IBOutlet weak var artistArtView: ArtistArtView!
	@IBOutlet weak var artistNameLabel: UILabel!
	
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		if self.tintColor.isDarkColor {
			
			self.artistNameLabel?.textColor = StyleKit.darkPrimaryTextColor
		} else {
			
			self.artistNameLabel?.textColor = StyleKit.lightPrimaryTextColor
		}
	}

}
