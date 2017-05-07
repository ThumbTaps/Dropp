//
//  FooterBackButton.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 4/24/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class FooterBackButton: FooterButton {
	
	@IBOutlet weak var backArrow: LeftButton!
	@IBOutlet weak var destinationEmblemContainer: UIView!
	@IBOutlet weak var destinationTitle: UILabel!
	
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
	
	func setDestinationIndicator(_ emblem: UIView) {
		for subview in self.destinationEmblemContainer.subviews {
			subview.removeFromSuperview()
		}
		
		DispatchQueue.main.async {
			
			self.destinationEmblemContainer.addSubview(emblem)
			emblem.frame = CGRect(x: 0, y: 0, width: self.destinationEmblemContainer.frame.width, height: self.destinationEmblemContainer.frame.height)
			self.destinationEmblemContainer.addConstraints([
				NSLayoutConstraint(item: emblem, attribute: .top, relatedBy: .equal, toItem: self.destinationEmblemContainer, attribute: .top, multiplier: 1, constant: 10),
				NSLayoutConstraint(item: emblem, attribute: .left, relatedBy: .equal, toItem: self.destinationEmblemContainer, attribute: .left, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: emblem, attribute: .bottom, relatedBy: .equal, toItem: self.destinationEmblemContainer, attribute: .bottom, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: emblem, attribute: .right, relatedBy: .equal, toItem: self.destinationEmblemContainer, attribute: .right, multiplier: 1, constant: 0)
				])
			self.destinationEmblemContainer.layoutIfNeeded()
		}
	}
	func hideDestinationIndicator() {
		self.destinationEmblemContainer.isHidden = true
		self.destinationTitle.transform = CGAffineTransform(translationX: -self.destinationEmblemContainer.frame.width, y: 0)
	}
	func showDestinationIndicator() {
		self.destinationEmblemContainer.isHidden = false
		self.destinationTitle.transform = CGAffineTransform(translationX: 0, y: 0)
	}
	
}
