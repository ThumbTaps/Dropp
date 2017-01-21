//
//  ArtistSearchBar.swift
//  Ursus
//
//  Created by Jeffery Jackson on 11/12/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class ArtistSearchBar: UIView, UITextFieldDelegate {
	
	var delegate: ArtistSearchBarDelegate?
	
	@IBOutlet weak var searchIcon: SearchButton!
	@IBOutlet weak var searchTermLabel: UILabel!
	@IBOutlet weak var textField: ArtistSearchBarTextField!
	@IBOutlet weak var searchIconVisibleConstraint: NSLayoutConstraint!
	@IBOutlet weak var searchIconHiddenConstraint: NSLayoutConstraint!
	@IBOutlet weak var textFieldFullWidthConstraint: NSLayoutConstraint!
	var textFieldShrunkenConstraint: NSLayoutConstraint?
	
	private var _isSearchIconVisible: Bool = true
	var isSearchIconVisible: Bool {
		set {
			self._isSearchIconVisible = newValue
			if self._isSearchIconVisible {
				// show search icon
				self.removeConstraint(self.searchIconHiddenConstraint)
				self.addConstraint(self.searchIconVisibleConstraint)
				
				UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
					self.layoutIfNeeded()
				})
			} else {
				// hide search icon
				self.removeConstraint(self.searchIconVisibleConstraint)
				self.addConstraint(self.searchIconHiddenConstraint)
				
				UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
					self.layoutIfNeeded()
				})
			}
		}
		get {
			return self._isSearchIconVisible
		}
	}
    
    private var _isSearching: Bool = false
    var isSearching: Bool {
        set {
            self._isSearching = newValue
            if self._isSearching {
                self.showSearching()
            }
        }
        get {
            return self._isSearching
        }
    }
	
	
	
	
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
		self.textField.addTarget(self, action: #selector(self.textFieldDidChange), for: .editingChanged)
		
	}
	
	
	
	
	
	// MARK: - Custom Methods
	private func showSearching() {
        // shrink text field to width of search term label
        self.searchTermLabel.sizeToFit()
        self.textFieldShrunkenConstraint = NSLayoutConstraint(item: self.textField, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.searchTermLabel.frame.width + 40)
        self.removeConstraint(self.textFieldFullWidthConstraint)
        self.addConstraint(self.textFieldShrunkenConstraint!)
        self.searchTermLabel.isHidden = false
        
        // fade out text field text
        UIView.transition(with: self.textField, duration: 0.35, options: .curveEaseOut, animations: {
            self.textField.textColor = self.textField.textColor?.withAlphaComponent(0)
        })
        
        // fade out textField and pop in search term label (also apply layout changes)
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.2, options: .curveEaseOut, animations: {
            self.textField.alpha = 0
            self.searchTermLabel.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            self.layoutIfNeeded()
        })
        
        // begin search icon pendulate and search term label color fading
        func swingSearchIcon() {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseIn, animations: {
                self.searchIcon.transform = CGAffineTransform(rotationAngle: -30)
                self.searchIcon.alpha = 1
            }, completion: { (finished) in
                if finished {
                    
                    self.searchTermLabel.textColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 1)
                    
                    if self.delegate?.searchBarShouldShowCompletedSearch?(self) ?? false {
                        
                        self.layer.masksToBounds = false
						UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseIn, animations: {
							self.searchIcon.transform = CGAffineTransform(rotationAngle: -360)
							self.searchIcon.alpha = 0
							
						}, completion: { (finished) in
							if finished {
								self.delegate?.searchBarDidShowCompletedSearch?(self)
							}
						})
                        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                            self.searchTermLabel.transform = CGAffineTransform(scaleX: 1, y: 1)
						})
                    } else {
						
                        DispatchQueue.main.async {
                            UIView.transition(with: self.searchTermLabel, duration: 0.35, options: [.curveEaseOut, .transitionCrossDissolve], animations: {
                                self.searchTermLabel.textColor = UIColor(red: 33/255, green: 33/255, blue: 33/255, alpha: 0.2)
                            })
                        }
                        UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
                            self.searchIcon.transform = CGAffineTransform(rotationAngle: 0)
                            self.searchIcon.alpha = 0.2
                        }, completion: { (finished) in
                            if finished {
                                swingSearchIcon()
                            }
                        })
                    }
                }
            })
        }
        
        swingSearchIcon()
	}
    

	
	
	
	// MARK: - UITextFieldDelegate
	func textFieldDidBeginEditing(_ textField: UITextField) {
		self.delegate?.searchBarDidBeginEditing?(self)
	}
	func textFieldDidChange(textField: UITextField) {
		
		// update search term label to match
		self.searchTermLabel.text = self.textField.text
		
		if textField.text!.characters.count > 0 {
			// self.isSearchIconVisible = false
			
		} else {
			// self.isSearchIconVisible = true
		}
		
		self.delegate?.searchBarTextFieldDidChange?(self)
	}
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		return self.delegate?.searchBar?(self, shouldChangeCharactersIn: range, replacementString: string) ?? true
	}
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		return self.delegate?.searchBarShouldReturn?(self) ?? true
	}
	func textFieldDidEndEditing(_ textField: UITextField) {
		self.delegate?.searchBarDidEndEditing?(self)
	}
}

@IBDesignable
class ArtistSearchBarTextField: RoundedTextField {
	
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
		
		if PreferenceManager.shared.theme == .dark {
			self.keyboardAppearance = .dark
		} else {
			self.keyboardAppearance = .light
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

@objc protocol ArtistSearchBarDelegate {
	
	@objc optional func searchBarDidBeginEditing(_ searchBar: ArtistSearchBar)
	@objc optional func searchBarTextFieldDidChange(_ searchBar: ArtistSearchBar)
	@objc optional func searchBar(_ searchBar: ArtistSearchBar, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
	@objc optional func searchBarShouldReturn(_ searchBar: ArtistSearchBar) -> Bool
	@objc optional func searchBarDidEndEditing(_ searchBar: ArtistSearchBar)
    @objc optional func searchBarShouldShowCompletedSearch(_ searchBar: ArtistSearchBar) -> Bool
    @objc optional func searchBarDidShowCompletedSearch(_ searchBar: ArtistSearchBar)
}
