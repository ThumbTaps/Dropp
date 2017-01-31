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
	
	@IBInspectable var changesWithTheme: Bool = true {
		didSet {
			if self.changesWithTheme {
				PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
			} else {
				PreferenceManager.shared.themeDidChangeNotification.remove(self)
			}
		}
	}
	var placement: ScrollFadeViewPlacement = .bottom
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.backgroundColor = UIColor.clear
			
		if self.changesWithTheme {
			self.themeDidChange()
			PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
		}
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		self.backgroundColor = UIColor.clear
			
		if self.changesWithTheme {
			self.themeDidChange()
			PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
		}
	}
	func themeDidChange() {
		
		if PreferenceManager.shared.theme == .dark {
			self.tintColor = StyleKit.darkBackgroundColor
		} else {
			self.tintColor = StyleKit.lightBackgroundColor
		}
		self.setNeedsDisplay()
	}
    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.setNeedsDisplay()
    }
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
		
		if rect.width > rect.height {
			if self.frame.origin.y <= 20 {
				self.placement = .top
			} else {
				self.placement = .bottom
			}
		} else {
			if self.frame.origin.x <= 0 {
				self.placement = .left
			} else {
				self.placement = .right
			}
		}

        // Drawing code
		let ctx = UIGraphicsGetCurrentContext()
		ctx?.saveGState()
		
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		
		let firstColor = self.tintColor.withAlpha(0)
		let firstColorComponents = firstColor.cgColor.components
		let secondColor = self.tintColor.withAlpha(0.7)
		let secondColorComponents = secondColor.cgColor.components
		let thirdColor = self.tintColor.withAlpha(0.85)
		let thirdColorComponents = thirdColor.cgColor.components
		let fourthColor = self.tintColor.withAlpha(1)
		let fourthColorComponents = fourthColor.cgColor.components
		
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
