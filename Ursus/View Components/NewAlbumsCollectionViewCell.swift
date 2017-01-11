//
//  NewAlbumsCollectionViewCell.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 12/25/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class NewAlbumsCollectionViewCell: UICollectionViewCell {
	
	@IBOutlet weak var albumArtView: AlbumArtView!
	@IBOutlet weak var albumTitleLabel: NewAlbumsCollectionViewCellAlbumTitleLabel!
	@IBOutlet weak var albumArtistNameLabel: NewAlbumsCollectionViewCellAlbumArtistNameLabel!
	
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
		
	}
	override func draw(_ rect: CGRect) {
		
		let path = UIBezierPath()
		path.move(to: CGPoint(x: 0, y: rect.height))
		path.addLine(to: CGPoint(x: rect.width, y: rect.height))
		path.close()
		
		if PreferenceManager.shared.themeMode == .dark {
			StyleKit.darkStrokeColor.set()
			self.layer.backgroundColor = StyleKit.darkBackdropOverlayColor.withAlpha(0.2).cgColor
		} else {
			StyleKit.lightStrokeColor.set()
			self.layer.backgroundColor = StyleKit.lightBackdropOverlayColor.cgColor
		}
		
		path.stroke()
	}
	
}



@IBDesignable
class NewAlbumsCollectionViewCellAlbumTitleLabel: UILabel {
	
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
			self.textColor = StyleKit.darkPrimaryTextColor
		} else {
			self.textColor = StyleKit.lightPrimaryTextColor
		}
	}
}



@IBDesignable
class NewAlbumsCollectionViewCellAlbumArtistNameLabel: UILabel {
	
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
			self.textColor = StyleKit.darkSecondaryTextColor
		} else {
			self.textColor = StyleKit.lightSecondaryTextColor
		}
	}
}
