//
//  NoResultsCollectionViewCell.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 12/3/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

@IBDesignable
class NoResultsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var actionButton: DroppButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.iconImageView.tintColor = UIColor(white: 0.8, alpha: 1)
        self.descriptionLabel.textColor = UIColor(white: 0.7, alpha: 1)
    }
}
