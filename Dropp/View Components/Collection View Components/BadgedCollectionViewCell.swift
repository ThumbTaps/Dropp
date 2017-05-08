//
//  BadgedCollectionViewCell.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 5/7/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class BadgedCollectionViewCell: DroppCollectionViewCell {
	
	@IBOutlet weak var badgeContainer: UIView!
	@IBOutlet weak var textLabel: UILabel!
	
	private var _badge: UIView?
	@IBOutlet weak var badge: UIView? {
		set {
			self.badge?.removeFromSuperview()
			
			if let newBadge = newValue {
				self.badgeContainer?.addSubview(newBadge)
				self.badgeContainer?.addConstraints([
					NSLayoutConstraint(item: newBadge, attribute: .width, relatedBy: .equal, toItem: self.badgeContainer, attribute: .width, multiplier: 1, constant: 0),
					NSLayoutConstraint(item: newBadge, attribute: .height, relatedBy: .equal, toItem: self.badgeContainer, attribute: .height, multiplier: 1, constant: 0),
					NSLayoutConstraint(item: newBadge, attribute: .centerX, relatedBy: .equal, toItem: self.badgeContainer, attribute: .centerX, multiplier: 1, constant: 0),
					NSLayoutConstraint(item: newBadge, attribute: .centerY, relatedBy: .equal, toItem: self.badgeContainer, attribute: .centerY, multiplier: 1, constant: 0)
					])
				self.badgeContainer?.layoutIfNeeded()
			}
			
			self._badge = newValue
		}
		get {
			return self._badge
		}
	}
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
