//
//  ReleaseCollectionViewCell.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 7/20/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

class ReleaseCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var titleLabel: UILabel?
	@IBOutlet weak var artistNameLabel: UILabel?
	@IBOutlet weak var artworkImageView: ReleaseArtworkImageView!
    @IBOutlet weak var classificationIndicator: UIButton?
    
    @IBOutlet weak var classificationIndicatorHiddenConstraint: NSLayoutConstraint?
    
    
    func setClassificationIndicatorHidden(_ hidden: Bool) {
        guard self.classificationIndicator != nil, self.classificationIndicatorHiddenConstraint != nil else {
            return
        }
        
        if hidden {
            self.addConstraint(self.classificationIndicatorHiddenConstraint!)
        } else {
            self.removeConstraint(self.classificationIndicatorHiddenConstraint!)
        }
        
        self.layoutIfNeeded()
    }
}
