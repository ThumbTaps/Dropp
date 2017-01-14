//
//  FrostedBackdrop.swift
//  Ursus
//
//  Created by Jeffery Jackson on 11/16/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class FrostedBackdrop: UIView {
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var overlay: FrostedBackdropOverlay!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.themeDidChange()
		Notification.Name.UrsusThemeDidChange.add(self, selector: #selector(self.themeDidChange))
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.themeDidChange()
		Notification.Name.UrsusThemeDidChange.add(self, selector: #selector(self.themeDidChange))
	}
	func themeDidChange() {
		self.setNeedsDisplay()
		
		if PreferenceManager.shared.themeMode == .dark {
			self.tintColor = StyleKit.darkTintColor
		} else {
			self.tintColor = StyleKit.lightTintColor
		}
		
	}
	
	// Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
		// Drawing code
		
		self.layer.cornerRadius = 12
		
		if PreferenceManager.shared.themeMode == .dark {
			self.layer.backgroundColor = StyleKit.darkBackgroundColor.cgColor
			StyleKit.drawDarkBackdrop(frame: CGRect(x: 0, y: rect.height - rect.width, width: rect.width, height: rect.width), resizing: .aspectFit)
		} else {
			self.layer.backgroundColor = StyleKit.lightBackgroundColor.cgColor
			StyleKit.drawLightBackdrop(frame: CGRect(x: 0, y: rect.height - rect.width, width: rect.width, height: rect.width), resizing: .aspectFit)
		}
		
	}
	
}

@IBDesignable
class FrostedBackdropOverlay: UIView {
	
    @IBInspectable var changesWithTheme: Bool = true
    
	override init(frame: CGRect) {
		super.init(frame: frame)
        
        if self.changesWithTheme {
            self.themeDidChange()
            Notification.Name.UrsusThemeDidChange.add(self, selector: #selector(self.themeDidChange))
        }
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
        if self.changesWithTheme {
            self.themeDidChange()
            Notification.Name.UrsusThemeDidChange.add(self, selector: #selector(self.themeDidChange))
        }
	}
	func themeDidChange() {
		self.setNeedsDisplay()		
	}
    override func tintColorDidChange() {
        super.tintColorDidChange()
        self.setNeedsDisplay()
    }
	override func draw(_ rect: CGRect) {
		
        if self.changesWithTheme {
            if PreferenceManager.shared.themeMode == .dark {
                self.layer.backgroundColor = StyleKit.darkBackdropOverlayColor.cgColor
            } else {
                self.layer.backgroundColor = StyleKit.lightBackdropOverlayColor.cgColor
            }
        } else {
            self.layer.backgroundColor = self.tintColor.cgColor
			self.backgroundColor = UIColor.clear
        }
	}
}
