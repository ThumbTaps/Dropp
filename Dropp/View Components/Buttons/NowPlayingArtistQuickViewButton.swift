//
//  NowPlayingArtistQuickViewButton.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 2/23/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class NowPlayingArtistQuickViewButton: FooterButton {
	
	@IBOutlet weak var artistArtworkView: ArtistArtworkView!
	@IBOutlet weak var artistNameLabel: UILabel!
	@IBOutlet weak var secondaryLabel: UILabel!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
