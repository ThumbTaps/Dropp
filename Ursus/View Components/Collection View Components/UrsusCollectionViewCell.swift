//
//  UrsusCollectionViewCell.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/13/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class UrsusCollectionViewCell: UICollectionViewCell {
    
	@IBInspectable var changesWithTheme: Bool = true {
		didSet {
			if self.changesWithTheme {
				PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
				self.themeDidChange()
			} else {
				PreferenceManager.shared.themeDidChangeNotification.remove(self)
			}
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		if self.changesWithTheme {
			self.themeDidChange()
			PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
		}
		self.selectedBackgroundView = UIView(frame: self.bounds)
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		if self.changesWithTheme {
			self.themeDidChange()
			PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
		}
		self.selectedBackgroundView = UIView(frame: self.bounds)
	}
	func themeDidChange() {
		
		if PreferenceManager.shared.theme == .dark {
			self.tintColor = StyleKit.darkBackdropOverlayColor
			
		} else {
			self.tintColor = StyleKit.lightBackdropOverlayColor
		}
		
	}
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		DispatchQueue.main.async {
			
			if self.changesWithTheme {
				
				if self.tintColor.isDarkColor {
					self.selectedBackgroundView?.backgroundColor = StyleKit.darkTintColor.withAlphaComponent(0.1)
				} else {
					self.selectedBackgroundView?.backgroundColor = StyleKit.lightTintColor.withAlphaComponent(0.1)
				}

			} else {
				
				if self.tintColor.isDarkColor {
					self.selectedBackgroundView?.backgroundColor = StyleKit.darkStrokeColor
				} else {
					self.selectedBackgroundView?.backgroundColor = StyleKit.lightStrokeColor
				}
			}
			self.setNeedsDisplay()
		}
	}
	override func draw(_ rect: CGRect) {
		
		let path = UIBezierPath()
		path.move(to: CGPoint(x: 0, y: rect.height))
		path.addLine(to: CGPoint(x: rect.width, y: rect.height))
		path.close()
		
		if self.tintColor.isDarkColor {
			StyleKit.darkStrokeColor.set()
		} else {
			StyleKit.lightStrokeColor.set()
		}
		
		self.layer.backgroundColor = self.tintColor.cgColor
		
		path.stroke()
	}
}
