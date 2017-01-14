//
//  UrsusButton.swift
//  Ursus
//
//  Created by Jeffery Jackson on 11/13/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class UrsusButton: UIButton {
	
	@IBInspectable var changesWithTheme: Bool = true
    @IBInspectable var tapScale: CGFloat = 1.2
	
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
		if PreferenceManager.shared.themeMode == .dark {
			self.tintColor = StyleKit.darkTintColor
		} else {
			self.tintColor = StyleKit.lightTintColor
		}
	}
	override func tintColorDidChange() {
		super.tintColorDidChange()
        
		if self.tintColor.isDarkColor {
			self.titleLabel?.textColor = StyleKit.darkIconGlyphColor
		} else {
			self.titleLabel?.textColor = StyleKit.lightIconGlyphColor
		}
		self.setNeedsDisplay()
	}
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
		
        // Drawing code
        self.layer.cornerRadius = rect.height / 2

        self.layer.borderWidth = 2
		self.layer.borderColor = UIColor.black.withAlpha(0.15).cgColor
        self.layer.backgroundColor = self.tintColor.cgColor
		
    }
	func radiate() {
		
	}
	func collapse() {
		
	}
	
	
	
	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		let marginForError: CGFloat = 10
		let relativeFrame = self.bounds
		let hitTestEdgeInsets = UIEdgeInsetsMake(-marginForError, -marginForError, -marginForError, -marginForError)
		let hitFrame = UIEdgeInsetsInsetRect(relativeFrame, hitTestEdgeInsets)
		return hitFrame.contains(point)
	}
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		let feedbackGenerator = UISelectionFeedbackGenerator()
		feedbackGenerator.selectionChanged()
		
		UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
			self.alpha = 0.75
			self.transform = CGAffineTransform(scaleX: self.tapScale, y: self.tapScale)
		})
		
		super.touchesBegan(touches, with: event)
	}
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseOut, animations: {
			self.alpha = 1
			self.transform = CGAffineTransform(scaleX: 1, y: 1)
		})
		
		super.touchesEnded(touches, with: event)
	}

}
