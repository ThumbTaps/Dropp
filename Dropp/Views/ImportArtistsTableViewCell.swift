//
//  ImportArtistsTableViewCell.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 10/29/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

class ImportArtistsTableViewCell: UITableViewCell {
	
	@IBOutlet weak var label: UILabel?
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
	}
	
	override func setHighlighted(_ highlighted: Bool, animated: Bool) {
		super.setHighlighted(highlighted, animated: animated)

		if highlighted {
			self.contentView.backgroundColor = self.backgroundColor?.withBrightness(0.8)
		} else {
			self.contentView.backgroundColor = self.backgroundColor
		}
	}
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
