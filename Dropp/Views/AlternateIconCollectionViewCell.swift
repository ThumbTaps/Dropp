//
//  AlternateIconCollectionViewCell.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 11/24/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

class AlternateIconCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var checkmark: DroppButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.iconImageView.clipsToBounds = true
        self.iconImageView.layer.cornerRadius = 13
                
        self.checkmark.isHidden = !self.isSelected
    }
}
