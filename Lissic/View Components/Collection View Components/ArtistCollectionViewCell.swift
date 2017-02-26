//
//  ArtistCollectionViewCell.swift
//  Lissic
//
//  Created by Jeffery Jackson, Jr. on 12/25/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class ArtistCollectionViewCell: LissicCollectionViewCell {
	
	@IBOutlet weak var artistArtView: ArtworkArtView!
	@IBOutlet weak var artistNameLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.tintColorDidChange()
	}
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		DispatchQueue.main.async {
			
			if self.tintColor.isDarkColor {
				self.artistNameLabel?.textColor = StyleKit.darkPrimaryTextColor
			} else {
				self.artistNameLabel?.textColor = StyleKit.lightPrimaryTextColor
			}
			self.setNeedsDisplay()
		}
	}

}
