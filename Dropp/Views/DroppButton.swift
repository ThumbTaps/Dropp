//
//  DroppButton.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 7/22/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

@IBDesignable
class DroppButton: UIButton {
	
	enum Glyph: Int {
		case
		none,
		close,
		plus,
		sort,
		more,
		checkmark,
		left,
		settings,
		artists,
		search,
		releases,
		right,
		down,
		share,
		minBrightness,
		maxBrightness,
		viewArtwork,
		up,
		calendar,
		play,
		stop,
		trackListing
	}
	
	var glyph: Glyph = .none {
		didSet {
			self.layoutIfNeeded()
		}
	}
	@IBInspectable var _glyph: Int {
		get {
			return self.glyph.rawValue
		}
		set (glyphIndex) {
			self.glyph = Glyph(rawValue: glyphIndex) ?? .none
		}
	}
	
	@IBInspectable var bordered: Bool = true {
		didSet {
			self.layoutIfNeeded()
		}
	}
	@IBInspectable var filled: Bool = true {
		didSet {
			self.layoutIfNeeded()
		}
	}
	@IBInspectable var round: Bool = true {
		didSet {
			self.layoutIfNeeded()
		}
	}
	
	override func tintColorDidChange() {
		super.tintColorDidChange()
		self.layoutIfNeeded()
	}
	
	// Only override draw() if you perform custom drawing.
	// An empty implementation adversely affects performance during animation.
	override func draw(_ rect: CGRect) {
		// Drawing code
		
		self.layer.masksToBounds = true
		
		if self.round {
			self.layer.cornerRadius = self.frame.height / 2
		} else {
			self.layer.cornerRadius = self.frame.height / 6
		}
		
		let glyphFrame = CGRect(x: self.contentEdgeInsets.left, y: self.contentEdgeInsets.top, width: self.frame.height, height: self.frame.height)
		let glyphResizing = StyleKit.ResizingBehavior.aspectFit
		var glyphColor = UIColor.white
		
		if self.filled {
			self.layer.backgroundColor = self.tintColor.cgColor
		} else {
			self.layer.backgroundColor = UIColor.clear.cgColor
			glyphColor = self.tintColor
		}
		
		self.setTitleColor(glyphColor, for: .normal)
		self.layer.borderColor = self.filled ? self.tintColor.withBrightness(0.75).cgColor : self.tintColor.cgColor
		
		if self.bordered {
			self.layer.borderWidth = 2
		} else {
			self.layer.borderWidth = 0
		}
		
		self.titleEdgeInsets = UIEdgeInsets(top: 0, left: self.glyph.rawValue > 0 ? glyphFrame.width : 4, bottom: 0, right: 4)
		if (self.glyph.rawValue > 0) {
			self.contentHorizontalAlignment = .left
		}
		
		// ditch the title if it won't fit
		if self.frame.width < (self.titleLabel?.frame.width ?? 0) + self.titleEdgeInsets.left + self.titleEdgeInsets.right {
			self.titleLabel?.alpha = 0
		}
		
		switch self.glyph {
		case .close:
			StyleKit.drawCloseIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .plus:
			StyleKit.drawPlusIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .sort:
			StyleKit.drawSortIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .more:
			StyleKit.drawMoreIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .checkmark:
			StyleKit.drawCheckmarkIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .left:
			StyleKit.drawLeftIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .settings:
			StyleKit.drawSettingsIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .artists:
			StyleKit.drawArtistsIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .search:
			StyleKit.drawSearchIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .releases:
			StyleKit.drawReleasesIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .right:
			StyleKit.drawRightIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .down:
			StyleKit.drawDownIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .share:
			StyleKit.drawShareIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .minBrightness:
			StyleKit.drawDisplayBrightnessMinIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .maxBrightness:
			StyleKit.drawDisplayBrightnessMaxIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .viewArtwork:
			StyleKit.drawViewArtworkIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .up:
			StyleKit.drawUpIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .calendar:
			StyleKit.drawCalendarIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .play:
			StyleKit.drawPlayIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .stop:
			StyleKit.drawStopIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		case .trackListing:
			StyleKit.drawTrackListingIcon(frame: glyphFrame, resizing: glyphResizing, iconColor: glyphColor);
			break
		default: return
		}
	}
}


