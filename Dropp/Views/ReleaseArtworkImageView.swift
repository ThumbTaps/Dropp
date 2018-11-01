//
//  ReleaseArtworkImageView.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 10/31/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

class ReleaseArtworkImageView: UIImageView {
    
    override func layoutSubviews() {
        super.layoutSubviews()

        self.layer.masksToBounds = true
        self.layer.cornerRadius = min(self.frame.height * 0.1, 8)
    }
}
