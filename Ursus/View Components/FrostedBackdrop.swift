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
		PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.themeDidChange()
		PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
	}
	func themeDidChange() {
		
		DispatchQueue.main.async {
			
			if PreferenceManager.shared.theme == .dark {
				self.tintColor = StyleKit.darkTintColor
			} else {
				self.tintColor = StyleKit.lightTintColor
			}
			
			self.setNeedsDisplay()
		}
	}
	
	// Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
		// Drawing code
		
		self.layer.cornerRadius = 12
		
		if PreferenceManager.shared.theme == .dark {
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
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
        if self.changesWithTheme {
            self.themeDidChange()
            PreferenceManager.shared.themeDidChangeNotification.add(self, selector: #selector(self.themeDidChange))
        }
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
        self.setNeedsDisplay()
    }
	override func draw(_ rect: CGRect) {
		
		DispatchQueue.main.async {
			
			self.layer.backgroundColor = self.tintColor.cgColor
			self.backgroundColor = UIColor.clear
		}
	}
}
