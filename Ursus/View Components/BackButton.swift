//
//  BackButton.swift
//  Ursus
//
//  Created by Jeffery Jackson on 11/27/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class BackButton: UIButton {
	
    var destinationIcon: UIView?
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
		
        StyleKit.drawBackIcon(frame: CGRect(x: 0, y: 0, width: self.frame.width * 0.43, height: self.frame.height), resizing: .aspectFit, iconColor: self.tintColor)
        StyleKit.drawSearchIcon(frame: CGRect(x: self.frame.width * 0.43, y: 0, width: self.frame.width * 0.57, height: self.frame.height), resizing: .aspectFit, iconColor: self.tintColor)
    }
}
