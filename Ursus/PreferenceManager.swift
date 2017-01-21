//
//  PreferenceManager.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 12/28/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

enum ThemeMode: Int {
	case manual = 0, auto = 1
}
enum Theme: Int {
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
	static let UrsusThemeDeterminerDidChange = Notification.Name(rawValue: "UrsusThemeDeterminerDidChange")
}

class PreferenceManager: NSObject {
	
	static let shared = PreferenceManager()
	
	private let firstLaunchKey = "firstLaunch"
	private let followingArtistsKey = "followingArtists"
	private let themeModeKey = "themeMode"
	private let themeKey = "themeKey"
	private let themeDeterminerKey = "themeDeterminer"
	private let themeBrightnessThresholdKey = "themeBrightnessThreshold"
	private let sunriseTimeKey = "sunriseTime"
	private let sunsetTimeKey = "sunsetTime"
	private let ignoreSinglesKey = "ignoreSingles"
	private let ignoreEPsKey = "ignoreEPs"
	
	var firstLaunch = true {
		didSet {
			UserDefaults.standard.set(self.firstLaunch, forKey: self.firstLaunchKey)
			UserDefaults.standard.synchronize()
		}
	}
	
	var followingArtists: [Artist] = []
	func follow(artist: Artist) {
        if self.followingArtists.index(where: { $0.itunesID == artist.itunesID }) == nil {
            self.followingArtists.append(artist)
        }
		
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
		UserDefaults.standard.set(encodedFollowingArtists, forKey: self.followingArtistsKey)
		UserDefaults.standard.synchronize()
	}
	
	
	private var _newReleases: [Release] = []
	var newReleases: [Release] {
		set {
			self._newReleases = newValue
		}
		get {
			return self.followingArtists.flatMap({
				$0.releases.filter({ (release) -> Bool in
					if !release.seenByUser {

						if self.ignoreEPs && release.type == .EP {
							return false

						} else if self.ignoreSingles && release.type == .single {
							return false
							
						} else {
							return true
						}
						
					} else {
						return false
					}
				})
			})
		}
	}
	var lastUpdate: Date? = nil
	func updateNewReleases(completion: (() -> Void)?=nil) {
		
		if self.followingArtists.count > 0 {
			
			self.followingArtists.forEach { (followed) in
				
				RequestManager.shared.getReleases(for: followed.itunesID, completion: { (releases: [Release], error: NSError?) in
					
					if error == nil {
//						let newReleases: [Release] = releases.filter({ (release) -> Bool in
//							return followed.releases.contains(where: { (otherRelease) -> Bool in
//								otherRelease.itunesID != release.itunesID
//							})
//						})
//						
//						followed.releases.append(contentsOf: newReleases)
						releases.forEach({ (release) in
							if followed.releases.filter({ $0.seenByUser }).contains(where: { (existingRelease) -> Bool in
								return release.itunesID == existingRelease.itunesID
							}) {
								release.seenByUser = true
							} else {
								release.seenByUser = false
							}
						})
						
						followed.releases = releases
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
	
	
	
	
	var themeMode: ThemeMode = .manual {
		didSet {

			if self.themeMode == .auto {
				self.theme = self.determineThemeMode()
			}
			if self.themeMode != oldValue {
				
				UserDefaults.standard.set(self.themeMode.rawValue, forKey: self.themeModeKey)
			}
		}
	}
	var theme: Theme = .light {
		didSet {
			
			if self.theme != oldValue {
				Notification.Name.UrsusThemeDidChange.post()
				UserDefaults.standard.set(self.theme.rawValue, forKey: self.themeKey)
			}
		}
	}
	var themeDeterminer: ThemeModeDeterminer = .displayBrightness {
		didSet {
			
			// stop observing display brightness
			Notification.Name.UIScreenBrightnessDidChange.remove(self)
			
			switch self.themeDeterminer {
			case .twilight:
				// start monitoring time here
				break
				
			case .displayBrightness:
				// start observing display brightness
				Notification.Name.UIScreenBrightnessDidChange.add(self, selector: #selector(self.displayBrightnessDidChange))
				break
				
			case .ambientLight:
				break
			}
			
			if self.themeDeterminer != oldValue {
				
				Notification.Name.UrsusThemeDeterminerDidChange.post()
				UserDefaults.standard.set(self.themeDeterminer.rawValue, forKey: self.themeDeterminerKey)
				self.theme = self.determineThemeMode()
			}
		}
	}
	
	func determineThemeMode() -> Theme {
		switch self.themeDeterminer {
			
		case .ambientLight:
			return self.themeBasedOnAmbientLight()
			
		case .displayBrightness:
			return self.themeBasedOnDisplayBrightness()
			
		case .twilight:
			return self.themeBasedOnTwilight()
		}
	}
	
	func themeBasedOnAmbientLight() -> Theme {
		return .light
	}
	
	func themeBasedOnDisplayBrightness() -> Theme {
		
		var theme: Theme = .light
		let brightness = Float(UIScreen.main.brightness)
		
		if brightness <= self.themeBrightnessThreshold {
			theme = .dark
		}
		
		return theme
	}
	var themeBrightnessThreshold: Float = 0.5 {
		didSet {
			UserDefaults.standard.set(self.themeBrightnessThreshold, forKey: self.themeBrightnessThresholdKey)
			UserDefaults.standard.synchronize()
			
			self.theme = self.determineThemeMode()
		}
	}
	func displayBrightnessDidChange() {
		self.theme = self.determineThemeMode()
	}

	func themeBasedOnTwilight() -> Theme {
		var theme: Theme = .light
		
		// sunrise and sunset haven't been determined or are outdated
		if self.sunriseTime == nil || self.sunsetTime == nil {
			
			if !self.determiningTwilightTimes {
				
				self.determiningTwilightTimes = true
				
				RequestManager.shared.getSunriseAndSunset { (sunrise, sunset, error) in
					
					if sunrise != nil && sunset != nil && error == nil {
						
						self.sunriseTime = sunrise
						self.sunsetTime = sunset
						
						self.theme = self.themeBasedOnTwilight()
					}
				}
			}
		} else {
			
			let calendar = NSCalendar(identifier: .gregorian)
			if !calendar!.isDateInToday(self.sunriseTime!) || !calendar!.isDateInToday(self.sunsetTime!) {
				
				self.sunriseTime = nil
				self.sunsetTime = nil
				self.theme = self.themeBasedOnTwilight()
				
			} else {
				
				let dateFormatter = DateFormatter()
				dateFormatter.timeZone = .current
				dateFormatter.dateFormat = "YYYY-MM-DD'T'hh:mm:ss a"
				let now = dateFormatter.date(from: dateFormatter.string(from: Date()))

				if now! < self.sunriseTime! || now! > self.sunsetTime! {
					theme = .dark
				}
			}
			
		}
		
		return theme
	}
	private var sunriseTime: Date? {
		didSet {
			// set trigger
			if self.sunriseTime != nil {
				
				let timer = Timer(fire: self.sunriseTime!, interval: 0, repeats: false) { (timer) in
					self.theme = self.determineThemeMode()
				}
				RunLoop.main.add(timer, forMode: .commonModes)
				
			}
			
			if self.sunriseTime != oldValue {
				
				UserDefaults.standard.set(self.sunriseTime, forKey: self.sunriseTimeKey)
			}
		}
	}
	private var sunsetTime: Date? {
		didSet {
			// set trigger
			if self.sunriseTime != nil {
				
				let timer = Timer(fire: self.sunsetTime!, interval: 0, repeats: false) { (timer) in
					self.theme = self.determineThemeMode()
				}
				RunLoop.main.add(timer, forMode: .commonModes)
				
			}
			
			if self.sunsetTime != oldValue {
				
				UserDefaults.standard.set(self.sunsetTime, forKey: self.sunsetTimeKey)
			}
		}
	}
	private var determiningTwilightTimes = false
	
	var keyboardStyle: UIKeyboardAppearance = .light
	
	var ignoreSingles: Bool = true {
		didSet {
			if self.ignoreSingles != oldValue {
				
				UserDefaults.standard.set(self.ignoreSingles, forKey: self.ignoreSinglesKey)
			}
		}
	}
	var ignoreEPs: Bool = true {
		didSet {
			if self.ignoreEPs != oldValue {
				
				UserDefaults.standard.set(self.ignoreEPs, forKey: self.ignoreEPsKey)
			}
		}
	}
	
	
	
	
	
	
	
	override init() {
		
		super.init()
		
		self.load()
	}
	
	func save(completion: (() -> Void)?=nil) {
		self.saveFollowingArtists()
		
		UserDefaults.standard.set(self.firstLaunch, forKey: self.firstLaunchKey)
		
		UserDefaults.standard.set(self.themeMode.rawValue, forKey: self.themeModeKey)
		UserDefaults.standard.set(self.theme.rawValue, forKey: self.themeKey)
		UserDefaults.standard.set(self.themeDeterminer.rawValue, forKey: self.themeDeterminerKey)
		UserDefaults.standard.set(self.themeBrightnessThreshold, forKey: self.themeBrightnessThresholdKey)
		UserDefaults.standard.set(self.sunriseTime, forKey: self.sunriseTimeKey)
		UserDefaults.standard.set(self.sunsetTime, forKey: self.sunsetTimeKey)
		
		UserDefaults.standard.set(self.ignoreSingles, forKey: self.ignoreSinglesKey)
		UserDefaults.standard.set(self.ignoreEPs, forKey: self.ignoreEPsKey)
		
		UserDefaults.standard.synchronize()
	}
	func load(completion: (() -> Void)?=nil) {
		self.firstLaunch = UserDefaults.standard.bool(forKey: self.firstLaunchKey)
		
		if let encodedFollowingArtists = UserDefaults.standard.object(forKey: self.followingArtistsKey) as? Data {
			self.followingArtists = NSKeyedUnarchiver.unarchiveObject(with: encodedFollowingArtists) as! [Artist]
		}
		
		self.themeMode = ThemeMode(rawValue: UserDefaults.standard.integer(forKey: self.themeModeKey)) ?? self.themeMode
		
		if self.themeMode == .auto {
			
			self.themeDeterminer = ThemeModeDeterminer(rawValue: UserDefaults.standard.integer(forKey: self.themeDeterminerKey)) ?? self.themeDeterminer
			
			if self.themeDeterminer == .displayBrightness {
				
				self.themeBrightnessThreshold = UserDefaults.standard.float(forKey: self.themeBrightnessThresholdKey)
			} else if self.themeDeterminer == .twilight {
				
				self.sunriseTime = UserDefaults.standard.object(forKey: self.sunriseTimeKey) as? Date
				self.sunsetTime = UserDefaults.standard.object(forKey: self.sunsetTimeKey) as? Date
			}
		} else {

			self.theme = Theme(rawValue: UserDefaults.standard.integer(forKey: self.themeKey)) ?? self.theme
		}
		
		self.ignoreSingles = UserDefaults.standard.bool(forKey: self.ignoreSinglesKey)
		self.ignoreEPs = UserDefaults.standard.bool(forKey: self.ignoreEPsKey)
		
		completion?()
	}
}
