//
//  ArtistArtworkImageView.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 10/31/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

class ArtistArtworkImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.frame.width / 2
    }
}
