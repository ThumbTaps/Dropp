//
//  PreferenceManager.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 12/28/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

enum ThemeMode: Int64 {
	case manual = 0, auto = 1
}
enum Theme: Int64 {
	case light = 0, dark = 1
}
enum ThemeDeterminer: Int64 {
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
	private let adaptiveArtistViewKey = "adaptiveArtistView"
	
	private let includeSinglesKey = "includeSingles"
	private let ignoreFeaturesKey = "ignoreFeatures"
	private let includeEPsKey = "includeEPs"
	private let showPreviousReleasesKey = "showPreviousReleases"
	private let maxReleaseAgeKey = "maxReleaseAgeKey"
	
	public let themeDidChangeNotification = Notification.Name(rawValue: "themeDidChangeNotification")
	public let themeDeterminerDidChangeNotification = Notification.Name(rawValue: "themeDeterminerDidChangeNotification")
	public let didUpdateReleasesNotification = Notification.Name(rawValue: "didUpdateReleasesNotification")
	public let failedToUpdateReleasesNotification = Notification.Name(rawValue: "failedToUpdateReleasesNotification")
	public let didChangeReleaseOptionsNotification = Notification.Name(rawValue: "didChangeReleaseOptionsNotification")
	
	var firstLaunch = true {
		didSet {
			self.iCloudKeyStore.set(self.firstLaunch, forKey: self.firstLaunchKey)
			self.iCloudKeyStore.synchronize()
			UserDefaults.standard.set(self.firstLaunch, forKey: self.firstLaunchKey)
		}
	}
	
	
	
	
	
	
	// MARK: - DISPLAY OPTIONS
	var themeMode: ThemeMode = .manual {
		didSet {

			if self.themeMode == .auto {
				self.theme = self.determineTheme()
			}
			if self.themeMode != oldValue {
				self.iCloudKeyStore.set(self.themeMode.rawValue, forKey: self.themeModeKey)
				UserDefaults.standard.set(self.themeMode.rawValue, forKey: self.themeModeKey)
			}
		}
	}
	var theme: Theme = .light {
		didSet {
			
			if self.theme != oldValue {
				self.themeDidChangeNotification.post()
				self.iCloudKeyStore.set(self.theme.rawValue, forKey: self.themeKey)
				UserDefaults.standard.set(self.theme.rawValue, forKey: self.themeKey)
			}
		}
	}
	var themeTransitionDuration = 0.6
	var themeDeterminer: ThemeDeterminer = .displayBrightness {
		didSet {
			
			// stop observing display brightness
			Notification.Name.UIScreenBrightnessDidChange.remove(self)
			// stop watching for twilight
			self.stopWatchingForTwilight()
			
			switch self.themeDeterminer {
			case .twilight:
				// start monitoring time here
				self.watchForTwilight()
				break
				
			case .displayBrightness:
				// start observing display brightness
				Notification.Name.UIScreenBrightnessDidChange.add(self, selector: #selector(self.displayBrightnessDidChange))
				break
				
			case .ambientLight:
				break
			}
			
			if self.themeDeterminer != oldValue {
				
				self.themeDeterminerDidChangeNotification.post()
				self.iCloudKeyStore.set(self.themeDeterminer.rawValue, forKey: self.themeDeterminerKey)
				UserDefaults.standard.set(self.themeDeterminer.rawValue, forKey: self.themeDeterminerKey)
				self.theme = self.determineTheme()
			}
		}
	}
	
	func determineTheme() -> Theme {
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
		let brightness = Double(UIScreen.main.brightness)
		
		if brightness <= self.themeBrightnessThreshold {
			theme = .dark
		}
		
		return theme
	}
	var themeBrightnessThreshold: Double = 0.5 {
		didSet {
			self.iCloudKeyStore.set(self.themeBrightnessThreshold, forKey: self.themeBrightnessThresholdKey)
			UserDefaults.standard.set(self.themeBrightnessThreshold, forKey: self.themeBrightnessThresholdKey)
			
			self.theme = self.determineTheme()
		}
	}
	func displayBrightnessDidChange() {
		self.theme = self.determineTheme()
	}

	func themeBasedOnTwilight() -> Theme {
		var theme: Theme = .light
		
		// sunrise and sunset haven't been determined or are outdated
		if self.sunriseTime == nil || self.sunsetTime == nil {
			
			if !self.determiningTwilightTimes {
				
				self.determiningTwilightTimes = true
				
				UIApplication.shared.isNetworkActivityIndicatorVisible = true
				RequestManager.shared.getSunriseAndSunset { (sunrise, sunset, error) in
					UIApplication.shared.isNetworkActivityIndicatorVisible = false
					
					if sunrise != nil && sunset != nil && error == nil {
						
						self.sunriseTime = sunrise
						self.sunsetTime = sunset
						
						self.theme = self.themeBasedOnTwilight()
						self.determiningTwilightTimes = false
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
				
				let now = Date()

				if now < self.sunriseTime! || now > self.sunsetTime! {
					theme = .dark
				}
			}
			
		}
		
		return theme
	}
	private var sunriseTime: Date? {
		didSet {
			// set trigger
			if self.sunriseTime != nil && self.sunsetTime != nil {
				self.watchForTwilight()
			}
			
			if self.sunriseTime != oldValue {
				
				self.iCloudKeyStore.set(self.sunriseTime, forKey: self.sunriseTimeKey)
				UserDefaults.standard.set(self.sunriseTime, forKey: self.sunriseTimeKey)
			}
		}
	}
	private var sunriseTimer: Timer?
	private var sunsetTime: Date? {
		didSet {
			// set trigger
			if self.sunsetTime != nil && self.sunriseTime != nil {
				self.watchForTwilight()
			}
			
			if self.sunsetTime != oldValue {
				self.iCloudKeyStore.set(self.sunsetTime, forKey: self.sunsetTimeKey)
				UserDefaults.standard.set(self.sunsetTime, forKey: self.sunsetTimeKey)
			}
		}
	}
	private var sunsetTimer: Timer?
	private var determiningTwilightTimes = false
	private func watchForTwilight() {
		if self.sunriseTime == nil || self.sunsetTime == nil {
			return
		}
		
		self.stopWatchingForTwilight()
		
		let now = Date()
		
		if now < self.sunriseTime! || now > self.sunsetTime! {
			
			self.sunriseTimer = Timer(fire: self.sunriseTime!, interval: 0, repeats: false) { (timer) in
				self.theme = self.determineTheme()
			}
			RunLoop.main.add(self.sunriseTimer!, forMode: .commonModes)
		} else {
			
			self.sunsetTimer = Timer(fire: self.sunsetTime!, interval: 0, repeats: false) { (timer) in
				self.theme = self.determineTheme()
			}
			RunLoop.main.add(self.sunsetTimer!, forMode: .commonModes)
		}

	}
	private func stopWatchingForTwilight() {
		self.sunriseTimer?.invalidate()
		self.sunsetTimer?.invalidate()
	}
	

	
	
	
	
	
	
	// MARK: - RELEASE OPTIONS
	var followingArtists: [Artist] = []
	func follow(artist: Artist) {
		if self.followingArtists.index(where: { $0.itunesID == artist.itunesID }) == nil {
			self.followingArtists.append(artist)
		}
		
		let encodedFollowingArtists = NSKeyedArchiver.archivedData(withRootObject: self.followingArtists)
		UserDefaults.standard.set(encodedFollowingArtists, forKey: self.followingArtistsKey)
		self.iCloudKeyStore.set(encodedFollowingArtists, forKey: self.followingArtistsKey)
	}
	func unfollow(artist: Artist) {
		self.followingArtists.remove(at: self.followingArtists.index(where: { (followed: Artist) -> Bool in
			return followed.itunesID == artist.itunesID
		})!)
		
		let encodedFollowingArtists = NSKeyedArchiver.archivedData(withRootObject: self.followingArtists)
		UserDefaults.standard.set(encodedFollowingArtists, forKey: self.followingArtistsKey)
		self.iCloudKeyStore.set(encodedFollowingArtists, forKey: self.followingArtistsKey)
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
						
						if !self.includeEPs && release.type == .EP {
							return false
							
						} else if !self.includeSingles && release.type == .single {
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
	private var _previousReleases: [Release] = []
	var previousReleases: [Release] {
		set {
			self._previousReleases = newValue
		}
		get {
			return self.followingArtists.flatMap({
				$0.releases.filter({ (release) -> Bool in
					
					if release.seenByUser {
						
						if !self.includeEPs && release.type == .EP {
							return false
							
						} else if !self.includeSingles && release.type == .single {
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
	func updateNewReleases() {
		
		if !self.followingArtists.isEmpty {
			
			self.followingArtists.forEach { (followed) in
				
				UIApplication.shared.isNetworkActivityIndicatorVisible = true
				
				guard let getReleasesTask = RequestManager.shared.getReleases(for: followed, since: Calendar.current.date(byAdding: .day, value: -Int(self.maxReleaseAge), to: Date()), completion: { (releases: [Release]?, error: Error?) in
					UIApplication.shared.isNetworkActivityIndicatorVisible = false
					
					guard let releases = releases, error == nil else {
						print(error!)
						return
					}
					
					releases.forEach({ (release) in
						print(release.title)
					})

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
				
					if self.followingArtists.last?.itunesID == followed.itunesID {
						
						let encodedFollowingArtists = NSKeyedArchiver.archivedData(withRootObject: self.followingArtists)
						UserDefaults.standard.set(encodedFollowingArtists, forKey: self.followingArtistsKey)
						self.iCloudKeyStore.set(encodedFollowingArtists, forKey: self.followingArtistsKey)
						
						self.lastUpdate = Date()
						self.didUpdateReleasesNotification.post()
						
					}
				}) else {
					
					return
				}
			}
		} else {
			self.lastUpdate = Date()
		}
		
	}
	
	var showPreviousReleases: Bool = false {
		didSet {
			if self.showPreviousReleases != oldValue {
				
				self.iCloudKeyStore.set(self.showPreviousReleases, forKey: self.showPreviousReleasesKey)
				UserDefaults.standard.set(self.showPreviousReleases, forKey: self.showPreviousReleasesKey)
				self.didChangeReleaseOptionsNotification.post()
			}
		}
	}
	var includeSingles: Bool = false {
		didSet {
			if self.includeSingles != oldValue {
				
				self.iCloudKeyStore.set(self.includeSingles, forKey: self.includeSinglesKey)
				UserDefaults.standard.set(self.includeSingles, forKey: self.includeSinglesKey)
				self.didChangeReleaseOptionsNotification.post()
			}
		}
	}
	var ignoreFeatures: Bool = true {
		didSet {
			if self.ignoreFeatures != oldValue {
				self.iCloudKeyStore.set(self.ignoreFeatures, forKey: self.ignoreFeaturesKey)
				UserDefaults.standard.set(self.ignoreFeatures, forKey: self.ignoreFeaturesKey)
				self.didChangeReleaseOptionsNotification.post()
			}
		}
	}
	var includeEPs: Bool = true {
		didSet {
			if self.includeEPs != oldValue {
				
				self.iCloudKeyStore.set(self.includeEPs, forKey: self.includeEPsKey)
				UserDefaults.standard.set(self.includeEPs, forKey: self.includeEPsKey)
				self.didChangeReleaseOptionsNotification.post()
			}
		}
	}
	var adaptiveArtistView: Bool = true {
		didSet {
			if self.adaptiveArtistView != oldValue {
				self.iCloudKeyStore.set(self.adaptiveArtistView, forKey: self.adaptiveArtistViewKey)
				UserDefaults.standard.set(self.adaptiveArtistView, forKey: self.adaptiveArtistViewKey)
			}
		}
	}
	var maxReleaseAge: Int64 = 1 { // in months
		didSet {
			if self.maxReleaseAge > 0 {
				if self.maxReleaseAge != oldValue {
					self.iCloudKeyStore.set(self.maxReleaseAge, forKey: self.maxReleaseAgeKey)
					UserDefaults.standard.set(self.maxReleaseAge, forKey: self.maxReleaseAgeKey)
				
				}
			} else {
				self.maxReleaseAge = 1
			}
		}
	}

	
	
	
	
	
	// MARK: - DATA MANAGEMENT
	var lastSync: Date?
	let iCloudKeyStore = NSUbiquitousKeyValueStore.default()
	override init() {
		
		super.init()
		
		UserDefaults.standard.register(defaults: [
			self.firstLaunchKey: false,
			self.themeModeKey: ThemeMode.manual.rawValue,
			self.themeKey: Theme.light.rawValue,
			self.themeDeterminerKey: ThemeDeterminer.displayBrightness.rawValue,
			self.themeBrightnessThresholdKey: 0.5,
			self.adaptiveArtistViewKey: true,
			self.includeSinglesKey: false,
			self.ignoreFeaturesKey: true,
			self.includeEPsKey: true,
			self.showPreviousReleasesKey: true,
			self.maxReleaseAgeKey: 1
		])
		
		NSUbiquitousKeyValueStore.didChangeExternallyNotification.add(self, selector: #selector(self.load))
		self.syncFromiCloud()

		self.load()
	}
	func syncFromiCloud() {
		self.firstLaunch = self.iCloudKeyStore.bool(forKey: self.firstLaunchKey)
		
		if let encodedFollowingArtists = self.iCloudKeyStore.object(forKey: self.followingArtistsKey) as? Data {
			self.followingArtists = NSKeyedUnarchiver.unarchiveObject(with: encodedFollowingArtists) as! [Artist]
		}
		
		self.themeMode = ThemeMode(rawValue: self.iCloudKeyStore.longLong(forKey: self.themeModeKey)) ?? self.themeMode
		
		if self.themeMode == .auto {
			
			self.themeBrightnessThreshold = self.iCloudKeyStore.double(forKey: self.themeBrightnessThresholdKey)
			self.sunriseTime = self.iCloudKeyStore.object(forKey: self.sunriseTimeKey) as? Date
			self.sunsetTime = self.iCloudKeyStore.object(forKey: self.sunsetTimeKey) as? Date
			
			self.themeDeterminer = ThemeDeterminer(rawValue: self.iCloudKeyStore.longLong(forKey: self.themeDeterminerKey)) ?? self.themeDeterminer
			
		} else {
			
			self.theme = Theme(rawValue: self.iCloudKeyStore.longLong(forKey: self.themeKey)) ?? self.theme
		}
		
		self.includeSingles = self.iCloudKeyStore.bool(forKey: self.includeSinglesKey)
		self.ignoreFeatures = self.iCloudKeyStore.bool(forKey: self.ignoreFeaturesKey)
		self.includeEPs = self.iCloudKeyStore.bool(forKey: self.includeEPsKey)
		self.showPreviousReleases = self.iCloudKeyStore.bool(forKey: self.showPreviousReleasesKey)
		self.maxReleaseAge = self.iCloudKeyStore.longLong(forKey: self.maxReleaseAgeKey)
		
		self.adaptiveArtistView = self.iCloudKeyStore.bool(forKey: self.adaptiveArtistViewKey)
		
		self.save {
			self.lastSync = Date()
		}
	}
	func syncToiCloud() {
		
		DispatchQueue.global().async {
			
			self.iCloudKeyStore.set(self.firstLaunch, forKey: self.firstLaunchKey)
			
			self.iCloudKeyStore.set(self.themeMode.rawValue, forKey: self.themeModeKey)
			self.iCloudKeyStore.set(self.theme.rawValue, forKey: self.themeKey)
			self.iCloudKeyStore.set(self.themeDeterminer.rawValue, forKey: self.themeDeterminerKey)
			self.iCloudKeyStore.set(self.themeBrightnessThreshold, forKey: self.themeBrightnessThresholdKey)
			self.iCloudKeyStore.set(self.sunriseTime, forKey: self.sunriseTimeKey)
			self.iCloudKeyStore.set(self.sunsetTime, forKey: self.sunsetTimeKey)
			
			self.iCloudKeyStore.set(self.includeSingles, forKey: self.includeSinglesKey)
			self.iCloudKeyStore.set(self.ignoreFeatures, forKey: self.ignoreFeaturesKey)
			self.iCloudKeyStore.set(self.includeEPs, forKey: self.includeEPsKey)
			self.iCloudKeyStore.set(self.showPreviousReleases, forKey: self.showPreviousReleasesKey)
			self.iCloudKeyStore.set(self.maxReleaseAge, forKey: self.maxReleaseAgeKey)
			
			self.iCloudKeyStore.set(self.adaptiveArtistView, forKey: self.adaptiveArtistViewKey)
			
			let encodedFollowingArtists = NSKeyedArchiver.archivedData(withRootObject: self.followingArtists)
			self.iCloudKeyStore.set(encodedFollowingArtists, forKey: self.followingArtistsKey)
			
			self.iCloudKeyStore.synchronize()
		}
	}
	func save(completion: (() -> Void)?=nil) {
		
		DispatchQueue.global().async {
			
			UserDefaults.standard.set(self.firstLaunch, forKey: self.firstLaunchKey)
			
			UserDefaults.standard.set(self.themeMode.rawValue, forKey: self.themeModeKey)
			UserDefaults.standard.set(self.theme.rawValue, forKey: self.themeKey)
			UserDefaults.standard.set(self.themeDeterminer.rawValue, forKey: self.themeDeterminerKey)
			UserDefaults.standard.set(self.themeBrightnessThreshold, forKey: self.themeBrightnessThresholdKey)
			UserDefaults.standard.set(self.sunriseTime, forKey: self.sunriseTimeKey)
			UserDefaults.standard.set(self.sunsetTime, forKey: self.sunsetTimeKey)
			
			UserDefaults.standard.set(self.includeSingles, forKey: self.includeSinglesKey)
			UserDefaults.standard.set(self.ignoreFeatures, forKey: self.ignoreFeaturesKey)
			UserDefaults.standard.set(self.includeEPs, forKey: self.includeEPsKey)
			UserDefaults.standard.set(self.showPreviousReleases, forKey: self.showPreviousReleasesKey)
			UserDefaults.standard.set(NSNumber(value: self.maxReleaseAge), forKey: self.maxReleaseAgeKey)
			
			UserDefaults.standard.set(self.adaptiveArtistView, forKey: self.adaptiveArtistViewKey)
			
			let encodedFollowingArtists = NSKeyedArchiver.archivedData(withRootObject: self.followingArtists)
			UserDefaults.standard.set(encodedFollowingArtists, forKey: self.followingArtistsKey)
			
			UserDefaults.standard.synchronize()
		}
		
		completion?()
		self.syncToiCloud()
	}
	func load(completion: (() -> Void)?=nil) {
		
		self.syncFromiCloud()
		
		self.firstLaunch = UserDefaults.standard.bool(forKey: self.firstLaunchKey)
		
		if let encodedFollowingArtists = UserDefaults.standard.object(forKey: self.followingArtistsKey) as? Data {
			self.followingArtists = NSKeyedUnarchiver.unarchiveObject(with: encodedFollowingArtists) as! [Artist]
		}
		
		self.themeMode = ThemeMode(rawValue: UserDefaults.standard.value(forKey: self.themeModeKey) as! Int64) ?? self.themeMode
		
		if self.themeMode == .auto {
			
			self.themeBrightnessThreshold = UserDefaults.standard.double(forKey: self.themeBrightnessThresholdKey)
			self.sunriseTime = UserDefaults.standard.object(forKey: self.sunriseTimeKey) as? Date
			self.sunsetTime = UserDefaults.standard.object(forKey: self.sunsetTimeKey) as? Date
			
			self.themeDeterminer = ThemeDeterminer(rawValue: UserDefaults.standard.value(forKey: self.themeDeterminerKey) as! Int64) ?? self.themeDeterminer
			
		} else {
			
			self.theme = Theme(rawValue: UserDefaults.standard.value(forKey: self.themeKey) as! Int64) ?? self.theme
		}
		
		self.includeSingles = UserDefaults.standard.bool(forKey: self.includeSinglesKey)
		self.ignoreFeatures = UserDefaults.standard.bool(forKey: self.ignoreFeaturesKey)
		self.includeEPs = UserDefaults.standard.bool(forKey: self.includeEPsKey)
		self.showPreviousReleases = UserDefaults.standard.bool(forKey: self.showPreviousReleasesKey)
		self.maxReleaseAge = (UserDefaults.standard.object(forKey: self.maxReleaseAgeKey) as! NSNumber).int64Value
		
		self.adaptiveArtistView = UserDefaults.standard.bool(forKey: self.adaptiveArtistViewKey)
		
		UserDefaults.standard.synchronize()
		
		completion?()
	}
}
