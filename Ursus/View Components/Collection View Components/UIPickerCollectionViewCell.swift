//
//  UIPickerCollectionViewCell.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/22/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

protocol UIPickerCollectionViewCellDelegate {
	
	func pickerCell(_ pickerCell: UIPickerCollectionViewCell, didSelectItemAt indexPath: IndexPath)
}
class UIPickerCollectionViewCell: UrsusCollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
	
	@IBOutlet weak var leftTextLabel: UILabel!
	@IBOutlet weak var pickerButton: UIPickerCollectionViewCellButton!
	@IBOutlet weak var rightTextLabel: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	
	var delegate: UIPickerCollectionViewCellDelegate?
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.pickerButton.addTarget(self, action: #selector(self.enableSelection), for: .touchUpInside)
		self.tintColorDidChange()
	}
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		DispatchQueue.main.async {
			
			if self.tintColor.isDarkColor {
				self.leftTextLabel?.textColor = StyleKit.darkPrimaryTextColor
				self.rightTextLabel?.textColor = StyleKit.darkPrimaryTextColor
			} else {
				self.leftTextLabel?.textColor = StyleKit.lightPrimaryTextColor
				self.rightTextLabel?.textColor = StyleKit.lightPrimaryTextColor
			}
			
			self.setNeedsDisplay()
			self.setNeedsLayout()
		}
	}
	
	func enableSelection() {
		self.collectionView.isHidden = false
	}
	func disableSelection() {
		self.collectionView.isHidden = true
	}
	
	
	
	// MARK: UICollectionViewDataSource
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 12
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaxReleaseAgePickerCell", for: indexPath)
		
		(cell as! UIPickerCollectionViewCellPickerCell).textLabel?.text = String(indexPath.row+1)
		
		if PreferenceManager.shared.maxReleaseAge == Int64(indexPath.row)+1 {
			(cell as! UIPickerCollectionViewCellPickerCell).isSelected = true
		}
		
		return cell
	}
	
	// MARK: UICollectionViewDelegate
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		let feedbackGenerator = UISelectionFeedbackGenerator()
		feedbackGenerator.selectionChanged()
		
		self.collectionView.reloadData()
		self.disableSelection()
		self.pickerButton.setTitle(String(indexPath.row+1), for: .normal)
		self.delegate?.pickerCell(self, didSelectItemAt: indexPath)
	}
}


class UIPickerCollectionViewCellButton: UrsusButton {
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		self.layer.cornerRadius = 4
	}
}


class UIPickerCollectionViewCellPickerCell: UrsusCollectionViewCell {
	
	@IBOutlet weak var textLabel: UILabel?
	override var isSelected: Bool {
		didSet {
			self.setNeedsDisplay()
		}
	}
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		self.layer.cornerRadius = 4
		self.layer.masksToBounds = true
		
		if self.tintColor.isDarkColor {
			self.layer.backgroundColor = StyleKit.darkTertiaryTextColor.cgColor
		} else {
			self.layer.backgroundColor = StyleKit.lightTertiaryTextColor.cgColor
		}
		
	}
	override func tintColorDidChange() {
		super.tintColorDidChange()
		
		DispatchQueue.main.async {
			
			if self.tintColor.isDarkColor {
				self.textLabel?.textColor = StyleKit.darkIconGlyphColor
				self.selectedBackgroundView?.backgroundColor = StyleKit.darkTintColor
			} else {
				self.textLabel?.textColor = StyleKit.lightIconGlyphColor
				self.selectedBackgroundView?.backgroundColor = StyleKit.lightTintColor
			}
			
			self.setNeedsLayout()
			self.setNeedsDisplay()
		}
	}
}
