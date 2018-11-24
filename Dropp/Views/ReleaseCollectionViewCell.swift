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
    
    func commonInit() {
        
        self.selectedBackgroundView = UIView(frame: self.frame)
        self.selectedBackgroundView?.backgroundColor = UIColor(white: 0, alpha: 0.1)
        self.selectedBackgroundView?.layer.cornerRadius = 8
        self.selectedBackgroundView?.clipsToBounds = true
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        commonInit()
    }
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
