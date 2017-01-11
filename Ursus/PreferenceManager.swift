//
//  PreferenceManager.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 12/28/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

enum ThemeMode: Int {
	case light = 0, dark = 1
}
enum ThemeModeDeterminer: Int {
	case displayBrightness = 0, twilight = 1, ambientLight = 2
}

extension Notification.Name {
	func post(object:Any? = nil, userInfo:[AnyHashable: Any]? = nil) {
		NotificationCenter.default.post(name: self, object: object, userInfo: userInfo)
	}
	func add(_ observer:Any!, selector: Selector!, object: Any?=nil) {
		NotificationCenter.default.addObserver(observer, selector: selector, name: self, object: object)
	}
	func remove(_ observer:Any!) {
		NotificationCenter.default.removeObserver(observer, name: self, object: nil)
	}

	static let UrsusThemeDidChange = Notification.Name(rawValue: "UrsusThemeDidChange")
}

class PreferenceManager: NSObject {
	
	static let shared = PreferenceManager()
	
	var followingArtists: [Artist] = []
	func follow(artist: Artist) {
		self.followingArtists.append(artist)
		
		self.saveFollowingArtists()
	}
	func unfollow(artist: Artist) {
		self.followingArtists.remove(at: self.followingArtists.index(where: { (followed: Artist) -> Bool in
			return followed.itunesID == artist.itunesID
		})!)
		
		self.saveFollowingArtists()
	}
	func saveFollowingArtists() {
		let encodedFollowingArtists = NSKeyedArchiver.archivedData(withRootObject: self.followingArtists)
		UserDefaults.standard.set(encodedFollowingArtists, forKey: "followingArtists")
		UserDefaults.standard.synchronize()
	}
	
	
	private var _newAlbums: [Album] = []
	var newAlbums: [Album] {
		set {
			self._newAlbums = newValue
		}
		get {
			return self.followingArtists.flatMap({ $0.latestAlbum })
		}
	}
	var lastUpdate: Date? = nil
	func updateNewAlbums(completion: (() -> Void)?=nil) {
		
		if self.followingArtists.count > 0 {
			
			self.followingArtists.forEach { (followed) in
				
				RequestManager.shared.getLatestAlbum(for: followed.itunesID, completion: { (album: Album?, error: NSError?) in
					
					if error == nil {
						
						if album != nil {
							
							if followed.latestAlbum != nil {
								
								if album!.itunesID != followed.latestAlbum!.itunesID && album!.isNewerThan(album: followed.latestAlbum!) {
									
									followed.latestAlbum = album!
								}
							} else {
								
								followed.latestAlbum = album!
							}
							
						}
					}
					
					if self.followingArtists.last?.itunesID == followed.itunesID {
						
						self.saveFollowingArtists()
						self.lastUpdate = Date()
						completion?()
						
					}
				})
			}
		} else {
			self.lastUpdate = Date()
			completion?()
		}
		
		
	}
	
	
	
	private var _autoThemeMode = true
	var autoThemeMode: Bool {
		set {

			self._autoThemeMode = newValue
			if self._autoThemeMode {
				self.themeMode = self.determineThemeMode()
			}
			UserDefaults.standard.set(self.autoThemeMode, forKey: "autoThemeMode")
			UserDefaults.standard.synchronize()
		}
		get {
			return self._autoThemeMode
		}
	}
	private var _themeMode: ThemeMode = .light
	var themeMode: ThemeMode {
		set {
			
			let shouldTriggerChange = self._themeMode != newValue
			self._themeMode = newValue
			if shouldTriggerChange {
				Notification.Name.UrsusThemeDidChange.post()
			}
			UserDefaults.standard.set(self._themeMode.rawValue, forKey: "themeMode")
			UserDefaults.standard.synchronize()
		}
		get {
			return self._themeMode
		}
	}
	private var _themeModeDeterminer: ThemeModeDeterminer = .displayBrightness
	var themeModeDeterminer: ThemeModeDeterminer {
		set {
			
			// stop observing display brightness
			Notification.Name.UIScreenBrightnessDidChange.remove(self)
			
			switch newValue {
			case .twilight:
				break
				
			case .displayBrightness:
				// start observing display brightness
				Notification.Name.UIScreenBrightnessDidChange.add(self, selector: #selector(self.displayBrightnessDidChange))
				break
				
			case .ambientLight:
				break
			}

			self._themeModeDeterminer = newValue
			UserDefaults.standard.set(self._themeModeDeterminer.rawValue, forKey: "themeModeDeterminer")
			UserDefaults.standard.synchronize()
			self.themeMode = self.determineThemeMode()
		}
		get {
			return self._themeModeDeterminer
		}
	}
	
	func determineThemeMode() -> ThemeMode {
		switch self.themeModeDeterminer {
			
		case .ambientLight:
			return self.themeModeBasedOnAmbientLight()
			
		case .displayBrightness:
			return self.themeModeBasedOnDisplayBrightness()
			
		case .twilight:
			return self.themeModeBasedOnTwilight()
		}
	}
	
	func themeModeBasedOnAmbientLight() -> ThemeMode {
		return .light
	}
	
	func themeModeBasedOnDisplayBrightness() -> ThemeMode {
		
		var themeMode: ThemeMode = .light
		let brightness = UIScreen.main.brightness
		
		if brightness <= self.themeModeBrightnessThreshold {
			themeMode = .dark
		}
		
		return themeMode
	}
	var themeModeBrightnessThreshold: CGFloat = 0.5
	func displayBrightnessDidChange() {
		self.themeMode = self.determineThemeMode()
	}

	func themeModeBasedOnTwilight() -> ThemeMode {
		var themeMode: ThemeMode = .light
		
		// sunrise and sunset haven't been determined or are outdated
		if self.sunriseTime == nil || self.sunsetTime == nil {
			
			if !self.determiningTwilightTimes {
				
				self.determiningTwilightTimes = true
								
				RequestManager.shared.getSunriseAndSunset { (sunrise, sunset, error) in
					
					if sunrise != nil && sunset != nil && error == nil {
						
						self.sunriseTime = sunrise
						self.sunsetTime = sunset
						
						self.themeMode = self.themeModeBasedOnTwilight()
					}
				}
			}
		} else {
			
			let calendar = NSCalendar(identifier: .gregorian)
			if !calendar!.isDateInToday(self.sunriseTime!) || !calendar!.isDateInToday(self.sunsetTime!) {
				
				self.sunriseTime = nil
				self.sunsetTime = nil
				self.themeMode = self.themeModeBasedOnTwilight()
				
			} else {
				
				let dateFormatter = DateFormatter()
				dateFormatter.timeZone = .current
				dateFormatter.dateFormat = "YYYY-MM-DD'T'hh:mm:ss a"
				let now = dateFormatter.date(from: dateFormatter.string(from: Date()))

				if now! < self.sunriseTime! || now! > self.sunsetTime! {
					themeMode = .dark
				}
			}
			
		}
		
		return themeMode
	}
	private var sunriseTime: Date?
	private var sunsetTime: Date?
	private var determiningTwilightTimes = false
	
	var keyboardStyle: UIKeyboardAppearance = .light
	
	var ignoreSingles: Bool = true
	var ignoreEPs: Bool = true
	
	
	
	
	
	
	
	override init() {
		
		super.init()
		
		self.load()
	}
	
	func save(completion: (() -> Void)?=nil) {
		self.saveFollowingArtists()
		
		UserDefaults.standard.set(self.autoThemeMode, forKey: "autoThemeMode")
		UserDefaults.standard.set(self.themeMode.rawValue, forKey: "themeMode")
		UserDefaults.standard.set(self._themeModeDeterminer.rawValue, forKey: "themeModeDeterminer")
		
		UserDefaults.standard.set(self.ignoreSingles, forKey: "ignoreSingles")
		UserDefaults.standard.set(self.ignoreEPs, forKey: "ignoreEPs")
		
		UserDefaults.standard.synchronize()
	}
	func load(completion: (() -> Void)?=nil) {
		if let encodedFollowingArtists = UserDefaults.standard.object(forKey: "followingArtists") as? Data {
			self.followingArtists = NSKeyedUnarchiver.unarchiveObject(with: encodedFollowingArtists) as! [Artist]
		}
		
		if let themeMode = UserDefaults.standard.value(forKey: "themeMode") as? ThemeMode {
			self.themeMode = themeMode
		}
		self.autoThemeMode = UserDefaults.standard.bool(forKey: "autoThemeMode")
		
		if self.autoThemeMode {
			
			if let themeModeDeterminer = UserDefaults.standard.value(forKey: "themeModeDeterminer") as? ThemeModeDeterminer {
				self.themeModeDeterminer = themeModeDeterminer
			} else {
				self.themeModeDeterminer = self._themeModeDeterminer
			}
		}
		
		self.ignoreSingles = UserDefaults.standard.bool(forKey: "ignoreSingles")
		self.ignoreEPs = UserDefaults.standard.bool(forKey: "ignoreEPs")
		
		completion?()
	}
}
