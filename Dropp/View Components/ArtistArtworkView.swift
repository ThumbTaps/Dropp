//
//  ArtistArtworkView.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 4/23/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ArtistArtworkView: ArtworkView {

	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		ThemeKit.drawPlaceholderArtistArtwork(frame: rect, resizing: .aspectFit)
	}
}
