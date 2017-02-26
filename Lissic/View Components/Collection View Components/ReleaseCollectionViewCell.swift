//
//  ReleaseCollectionViewCell.swift
//  Lissic
//
//  Created by Jeffery Jackson, Jr. on 12/25/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class ReleaseCollectionViewCell: LissicCollectionViewCell {
	    
	@IBOutlet weak var releaseArtView: ArtworkArtView!
	@IBOutlet weak var releaseTitleLabel: UILabel!
	@IBOutlet weak var secondaryLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.tintColorDidChange()
	}
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        if self.tintColor.isDarkColor {
            self.releaseTitleLabel?.textColor = StyleKit.darkPrimaryTextColor
            self.secondaryLabel?.textColor = StyleKit.darkSecondaryTextColor
        } else {
            self.releaseTitleLabel?.textColor = StyleKit.lightPrimaryTextColor
            self.secondaryLabel?.textColor = StyleKit.lightSecondaryTextColor
        }
        self.setNeedsDisplay()
    }
}
