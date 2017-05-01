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
	@IBOutlet weak var destinationButtonContainer: UIView!
	@IBOutlet weak var destinationTitle: UILabel!
	
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
	
	func setDestinationButton(button: DroppButton) {
		for subview in self.destinationButtonContainer.subviews {
			subview.removeFromSuperview()
		}
		
		DispatchQueue.main.async {
			
			self.destinationButtonContainer.addSubview(button)
			button.frame = CGRect(x: 0, y: 0, width: self.destinationButtonContainer.frame.width, height: self.destinationButtonContainer.frame.height)
			self.destinationButtonContainer.addConstraints([
				NSLayoutConstraint(item: button, attribute: .top, relatedBy: .equal, toItem: self.destinationButtonContainer, attribute: .top, multiplier: 1, constant: 10),
				NSLayoutConstraint(item: button, attribute: .left, relatedBy: .equal, toItem: self.destinationButtonContainer, attribute: .left, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: button, attribute: .bottom, relatedBy: .equal, toItem: self.destinationButtonContainer, attribute: .bottom, multiplier: 1, constant: 0),
				NSLayoutConstraint(item: button, attribute: .right, relatedBy: .equal, toItem: self.destinationButtonContainer, attribute: .right, multiplier: 1, constant: 0)
				])
			self.destinationButtonContainer.layoutIfNeeded()
		}
	}
	func hideDestinationButton() {
		self.destinationButtonContainer.isHidden = true
		self.destinationTitle.transform = CGAffineTransform(translationX: -self.destinationButtonContainer.frame.width, y: 0)
	}
	func showDestinationButton() {
		self.destinationButtonContainer.isHidden = false
		self.destinationTitle.transform = CGAffineTransform(translationX: 0, y: 0)
	}
	
}
