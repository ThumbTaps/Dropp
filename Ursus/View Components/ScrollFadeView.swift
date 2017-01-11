//
//  ScrollFadeView.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 12/27/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

enum ScrollFadeViewPlacement {
	case top, bottom, left, right
}

@IBDesignable
class ScrollFadeView: UIView {
	
	var placement: ScrollFadeViewPlacement = .bottom
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.commonInit()
		self.themeDidChange()
		Notification.Name.UrsusThemeDidChange.add(self, selector: #selector(self.themeDidChange))
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.commonInit()
		self.themeDidChange()
		Notification.Name.UrsusThemeDidChange.add(self, selector: #selector(self.themeDidChange))
	}
	func themeDidChange() {
		self.setNeedsDisplay()
		
	}

	func commonInit() {
		
		if frame.width > frame.height {
			if frame.origin.y <= 20 {
				self.placement = .top
			} else {
				self.placement = .bottom
			}
		} else {
			if frame.origin.x <= 0 {
				self.placement = .left
			} else {
				self.placement = .right
			}
		}
	}
	
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
				
        // Drawing code
		let ctx = UIGraphicsGetCurrentContext()
		ctx?.saveGState()
		
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		
		var firstColor = UIColor.white.withAlphaComponent(0)
		var firstColorComponents = firstColor.cgColor.components
		var secondColor = UIColor.white.withAlphaComponent(0.85)
		var secondColorComponents = secondColor.cgColor.components
		var thirdColor = UIColor.white.withAlphaComponent(0.9)
		var thirdColorComponents = thirdColor.cgColor.components
		var fourthColor = UIColor.white
		var fourthColorComponents = fourthColor.cgColor.components
		
		if PreferenceManager.shared.themeMode == .dark {
			firstColor = UIColor.black.withAlphaComponent(0)
			firstColorComponents = firstColor.cgColor.components
			secondColor = UIColor.black.withAlphaComponent(0.7)
			secondColorComponents = secondColor.cgColor.components
			thirdColor = UIColor.black.withAlphaComponent(0.85)
			thirdColorComponents = thirdColor.cgColor.components
			fourthColor = UIColor.black
			fourthColorComponents = fourthColor.cgColor.components
		}
		
		let colorComponents = [firstColorComponents[0], firstColorComponents[1], firstColorComponents[2], firstColorComponents[3], secondColorComponents[0], secondColorComponents[1], secondColorComponents[2], secondColorComponents[3], thirdColorComponents[0], thirdColorComponents[1], thirdColorComponents[2], thirdColorComponents[3], fourthColorComponents[0], fourthColorComponents[1], fourthColorComponents[2], fourthColorComponents[3]]
		
		var locations:[CGFloat] = [0.0, 0.4, 0.6, 1.0]
		if self.placement == .top || self.placement == .left {
			locations = locations.reversed()
		}
		
		let gradient = CGGradient(colorSpace: colorSpace, colorComponents: colorComponents, locations: locations, count: 4)
		
		var startPoint = CGPoint(x: rect.width / 2, y: 0)
		var endPoint = CGPoint(x: rect.width / 2, y: rect.height)
		
		if self.placement == .left || self.placement == .right {
			startPoint = CGPoint(x: 0, y: rect.height / 2)
			endPoint = CGPoint(x: rect.width, y: rect.height / 2)
		}
		
		ctx?.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: .drawsBeforeStartLocation)
		
		ctx?.restoreGState()
		
    }
}
