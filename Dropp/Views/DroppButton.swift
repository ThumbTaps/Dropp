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
    @IBInspectable var haptic: Bool = false

	
    override func setTitle(_ title: String?, for state: UIControl.State) {
        super.setTitle(title, for: state)
        
        self.setNeedsDisplay()
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
		
		var glyphFrame = CGRect(x: 0, y: 0, width: self.frame.height, height: self.frame.height)
		let glyphResizing = StyleKit.ResizingBehavior.aspectFit
		var glyphColor = self.titleColor(for: .normal) ?? UIColor.white
		
		if self.filled {
			self.layer.backgroundColor = self.tintColor.cgColor
		} else {
			self.layer.backgroundColor = UIColor.clear.cgColor
			glyphColor = self.tintColor
		}
		
		self.setTitleColor(glyphColor, for: .normal)
		self.layer.borderColor = self.filled ? self.tintColor.shadow(withLevel: 0.1).cgColor : self.tintColor.cgColor
		
		if self.bordered {
			self.layer.borderWidth = 2
		} else {
			self.layer.borderWidth = 0
		}
		
		self.titleEdgeInsets = UIEdgeInsets(top: 0, left: self.glyph != .none ? glyphFrame.width : 0, bottom: 0, right: 0)
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: (self.frame.width - glyphFrame.width) / 2, bottom: 0, right: 0)
        if self.glyph != .none && !(self.titleLabel?.text?.isEmpty ?? true) {
            self.contentEdgeInsets.left = (self.frame.width - glyphFrame.width - (self.titleLabel?.frame.width ?? 0)) / 3
        }
        glyphFrame.origin = CGPoint(x: self.contentEdgeInsets.left, y: self.contentEdgeInsets.top)
        
		if (self.glyph != .none) {
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
    
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let marginForError: CGFloat = 10
        let relativeFrame = self.bounds
        let hitTestEdgeInsets = UIEdgeInsets(top: -marginForError, left: -marginForError, bottom: -marginForError, right: -marginForError)
        let hitFrame = relativeFrame.inset(by: hitTestEdgeInsets)
        return hitFrame.contains(point)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if self.haptic {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            feedbackGenerator.impactOccurred()
        }
        
        UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.5) {
            self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }.startAnimation()
        
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if let touchLocation = touches.first?.location(in: self) {
            
            if !self.point(inside: touchLocation, with: event) {
                self.touchesCancelled(touches, with: event)
            }
        }
        
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.5) {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
            }.startAnimation()
        
        super.touchesEnded(touches, with: event)
    }
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.touchesEnded(touches, with: event)
    }
}



