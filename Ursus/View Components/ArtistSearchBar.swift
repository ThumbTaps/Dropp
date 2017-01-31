//
//  ArtistSearchBar.swift
//  Ursus
//
//  Created by Jeffery Jackson on 11/12/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class ArtistSearchBar: UIView {
	
	@IBOutlet weak var searchIcon: SearchButton!
	@IBOutlet weak var searchTermLabel: UILabel!
	@IBOutlet weak var textField: ArtistSearchBarTextField!
	@IBOutlet weak var searchIconVisibleConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchIconHiddenConstraint: NSLayoutConstraint!
	@IBOutlet weak var textFieldFullWidthConstraint: NSLayoutConstraint!
	var textFieldShrunkenConstraint: NSLayoutConstraint?
	
	
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
		
		if PreferenceManager.shared.theme == .dark {
			self.tintColor = StyleKit.darkPrimaryTextColor
		} else {
			self.tintColor = StyleKit.lightPrimaryTextColor
		}
		self.setNeedsDisplay()
	}
	override func awakeFromNib() {
		super.awakeFromNib()

		// configure text field
		self.textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: self.textField.frame.height, height: self.textField.frame.height))
		self.textField.leftViewMode = .always
		self.textField.rightView = self.textField.leftView
		self.textField.rightViewMode = .always
		
	}
	
	
	
	
	
	// MARK: - Custom Methods
	private func heartbeat(completion: (() -> Void)?=nil) {
	
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
				self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
			}, completion: { (completed) in
				
				UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseInOut, animations: {
					self.transform = CGAffineTransform(scaleX: 1, y: 1)
				}, completion: { (completed) in
					
					// trigger completion handler
					completion?()
				})
			})
		}
	}
	private var searchCompletion: (() -> Void)?
	func startSearching() {
		heartbeat {
			if self.shouldEndSearching {
				self.searchCompletion?()
			} else {
				self.startSearching()
			}
		}
	}
	private var shouldEndSearching = false
	func endSearching(completion: (() -> Void)?=nil) {
		self.searchCompletion = completion
		self.shouldEndSearching = true
	}
}

@IBDesignable
class ArtistSearchBarTextField: RoundedTextField {
	
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
		self.setNeedsDisplay()
		
		if PreferenceManager.shared.theme == .dark {
			self.keyboardAppearance = .dark
			self.tintColor = StyleKit.darkTintColor
		} else {
			self.keyboardAppearance = .light
			self.tintColor = StyleKit.lightTintColor
		}
		
	}
	override func draw(_ rect: CGRect) {
		
		super.draw(rect)
		
		if PreferenceManager.shared.theme == .dark {
			self.layer.backgroundColor = StyleKit.darkBackgroundColor.withAlpha(0.5).cgColor
			self.layer.borderColor = StyleKit.darkStrokeColor.cgColor
			self.textColor = StyleKit.darkPrimaryTextColor
			self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSForegroundColorAttributeName: StyleKit.darkTertiaryTextColor])
		} else {
			self.layer.backgroundColor = StyleKit.lightBackgroundColor.withAlpha(0.5).cgColor
			self.layer.borderColor = StyleKit.lightStrokeColor.cgColor
			self.textColor = StyleKit.lightPrimaryTextColor
			self.attributedPlaceholder = NSAttributedString(string: self.placeholder!, attributes: [NSForegroundColorAttributeName: StyleKit.lightTertiaryTextColor])
			
		}
	}

}
