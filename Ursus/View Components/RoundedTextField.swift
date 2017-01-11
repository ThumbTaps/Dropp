//
//  RoundedTextField.swift
//  Ursus
//
//  Created by Jeffery Jackson on 11/28/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedTextField: UITextField {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
		
        // Drawing code
		self.layer.cornerRadius = rect.height / 2
		self.layer.borderWidth = 2
		self.layer.masksToBounds = true

    }

}
