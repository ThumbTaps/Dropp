//
//  UIPickerCollectionViewCell.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 1/22/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

protocol UIPickerCollectionViewCellDelegate {
	
	func pickerCell(_ pickerCell: UIPickerCollectionViewCell, didSelectItemAt indexPath: IndexPath)
}
class UIPickerCollectionViewCell: DroppCollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
	
	@IBOutlet weak var leftTextLabel: UILabel!
	@IBOutlet weak var pickerButton: UIPickerCollectionViewCellButton!
	@IBOutlet weak var rightTextLabel: UILabel!
	@IBOutlet weak var collectionView: UICollectionView!
	
	var delegate: UIPickerCollectionViewCellDelegate?
	
	var options = Array<Any>()
	var selectedIndex = 0
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		self.pickerButton.addTarget(self, action: #selector(self.enableSelection), for: .touchUpInside)
	}
	
	func enableSelection() {
		self.collectionView.isHidden = false
	}
	func disableSelection() {
		self.collectionView.isHidden = true
	}
	
	
	
	// MARK: UICollectionViewDataSource
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.options.count
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaxReleaseAgePickerCell", for: indexPath)
		
		(cell as! UIPickerCollectionViewCellPickerCell).textLabel?.text = String(describing: self.options[indexPath.row])
		
		if indexPath.row == selectedIndex {
			(cell as! UIPickerCollectionViewCellPickerCell).isSelected = true
		}
		
		return cell
	}
	
	// MARK: UICollectionViewDelegate
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		let feedbackGenerator = UISelectionFeedbackGenerator()
		feedbackGenerator.selectionChanged()
		
		self.collectionView.performBatchUpdates({ 
			self.collectionView.reloadData()
		})
		self.disableSelection()
		self.pickerButton.setTitle(String(indexPath.row+1), for: .normal)
		self.delegate?.pickerCell(self, didSelectItemAt: indexPath)
	}
}


class UIPickerCollectionViewCellButton: DroppButton {
	
	override func draw(_ rect: CGRect) {
		super.draw(rect)
		
		self.layer.cornerRadius = 4
	}
}


class UIPickerCollectionViewCellPickerCell: DroppCollectionViewCell {
	
	@IBOutlet weak var textLabel: UILabel?
	override var isSelected: Bool {
		didSet {
			self.setNeedsDisplay()
		}
	}
}
