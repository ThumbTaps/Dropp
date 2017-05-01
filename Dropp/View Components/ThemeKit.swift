//
//  ThemeKit.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 4/22/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

@IBDesignable
class ThemeKit: NSObject {
	
	public dynamic class var tintColor: UIColor {
		return PreferenceManager.shared.theme == .dark ?
			StyleKit.darkTintColor :
			StyleKit.lightTintColor
	}
	public dynamic class var glyphColor: UIColor {
		return PreferenceManager.shared.theme == .dark ?
			StyleKit.darkGlyphColor :
			StyleKit.lightGlyphColor
	}
	public dynamic class var backdropOverlayColor: UIColor {
		return PreferenceManager.shared.theme == .dark ?
			StyleKit.darkBackdropOverlayColor :
			StyleKit.lightBackdropOverlayColor
	}
	public dynamic class var backgroundColor: UIColor {
		return PreferenceManager.shared.theme == .dark ?
			StyleKit.darkBackgroundColor :
			StyleKit.lightBackgroundColor
	}
	public dynamic class var strokeColor: UIColor {
		return PreferenceManager.shared.theme == .dark ?
			StyleKit.darkStrokeColor :
			StyleKit.lightStrokeColor
	}
	public dynamic class var primaryTextColor: UIColor {
		return PreferenceManager.shared.theme == .dark ?
			StyleKit.darkPrimaryTextColor :
			StyleKit.lightPrimaryTextColor
	}
	public dynamic class var secondaryTextColor: UIColor {
		return PreferenceManager.shared.theme == .dark ?
			StyleKit.darkSecondaryTextColor :
			StyleKit.lightSecondaryTextColor
	}
	public dynamic class var tertiaryTextColor: UIColor {
		return PreferenceManager.shared.theme == .dark ?
			StyleKit.darkTertiaryTextColor :
			StyleKit.lightTertiaryTextColor
	}
	public dynamic class var shadowColor: UIColor {
		return PreferenceManager.shared.theme == .dark ?
			StyleKit.darkShadowColor :
			StyleKit.lightShadowColor
	}
	
	
	public dynamic class var statusBarStyle: UIStatusBarStyle {
		return PreferenceManager.shared.theme == .dark ?
			.lightContent :
			.default
	}
	public dynamic class var indicatorStyle: UIScrollViewIndicatorStyle {
		return PreferenceManager.shared.theme == .dark ?
			.white :
			.default
	}
	public dynamic class var blurEffectStyle: UIBlurEffectStyle {
		return PreferenceManager.shared.theme == .dark ?
			.dark :
			.light
	}
	public dynamic class var barStyle: UIBarStyle {
		return PreferenceManager.shared.theme == .dark ?
			.black :
			.default
	}
	public dynamic class var keyboardAppearance: UIKeyboardAppearance {
		return PreferenceManager.shared.theme == .dark ?
			.dark :
			.default
	}
	
	
	public dynamic class func drawBackdrop(frame: CGRect, resizing: StyleKit.ResizingBehavior) {
		PreferenceManager.shared.theme == .dark ?
			StyleKit.drawDarkBackdrop(frame: frame, resizing: resizing) :
			StyleKit.drawLightBackdrop(frame: frame, resizing: resizing)
	}
	public dynamic class func drawPlaceholderReleaseArtwork(frame: CGRect, resizing: StyleKit.ResizingBehavior) {
		PreferenceManager.shared.theme == .dark ?
			StyleKit.drawDarkPlaceholderReleaseArtwork(frame: frame, resizing: .aspectFit) :
			StyleKit.drawLightPlaceholderReleaseArtwork(frame: frame, resizing: .aspectFit)
	}
	public dynamic class func drawPlaceholderArtistArtwork(frame: CGRect, resizing: StyleKit.ResizingBehavior) {
		PreferenceManager.shared.theme == .dark ?
			StyleKit.drawDarkPlaceholderArtistArtwork(frame: frame, resizing: .aspectFit) :
			StyleKit.drawLightPlaceholderArtistArtwork(frame: frame, resizing: .aspectFit)
	}
}
