//
//  PreferenceManager.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 12/28/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit
import MediaPlayer

enum ThemeMode: Int64 {
	case manual = 0, auto = 1
}
enum Theme: Int64 {
	case light = 0, dark = 1
}
enum ThemeDeterminer: Int64 {
	case displayBrightness = 0, twilight = 1, ambientLight = 2
}
enum ReleaseSorting: Int64 {
	case releaseDate = 0, releaseTitle = 1, artistName = 2
}
enum ArtworkSize: Int {
	case small = 0, medium = 1, large = 2, extraLarge = 3, mega = 4, thumbnail = 5
}

public let ANIMATION_SPEED_MODIFIER = 1.0

extension Notification.Name {
	func post(object: Any? = nil, userInfo:[AnyHashable: Any]? = nil) {
		NotificationCenter.default.post(name: self, object: object, userInfo: userInfo)
	}
	func add(_ observer:Any!, selector: Selector!, object: Any?=nil) {
		NotificationCenter.default.addObserver(observer, selector: selector, name: self, object: object)
	}
	func remove(_ observer: Any!) {
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
	private let autoMarkAsSeenKey = "autoMarkAsSeenKey"
	private let maxNewReleaseAgeKey = "maxNewReleaseAgeKey"
	private let showPreviousReleasesKey = "showPreviousReleases"
	private let maxPreviousReleaseAgeKey = "maxPreviousReleaseAgeKey"
	private let releaseSortingKey = "releaseSortingKey"
	
	public let themeDidChangeNotification = Notification.Name(rawValue: "themeDidChangeNotification")
	public let themeDeterminerDidChangeNotification = Notification.Name(rawValue: "themeDeterminerDidChangeNotification")
	public let didUpdateReleasesNotification = Notification.Name(rawValue: "didUpdateReleasesNotification")
	public let failedToUpdateReleasesNotification = Notification.Name(rawValue: "failedToUpdateReleasesNotification")
	public let didChangeReleaseOptionsNotification = Notification.Name(rawValue: "didChangeReleaseOptionsNotification")
	public let nowPlayingArtistDidChangeNotification = Notification.Name(rawValue: "nowPlayingArtistDidChangeNotification")
	
	var firstLaunch = true {
		didSet {
//			self.iCloudKeyStore.set(self.firstLaunch, forKey: self.firstLaunchKey)
//			self.iCloudKeyStore.synchronize()
			UserDefaults.standard.set(self.firstLaunch, forKey: self.firstLaunchKey)
		}
	}
	
	
	
	
	
	
	// MARK: - THEME OPTIONS
	var themeMode: ThemeMode = .manual {
		didSet {

			if self.themeMode == .auto {
				self.theme = self.determineTheme()
			}
			if self.themeMode != oldValue {
//				self.iCloudKeyStore.set(self.themeMode.rawValue, forKey: self.themeModeKey)
				UserDefaults.standard.set(self.themeMode.rawValue, forKey: self.themeModeKey)
			}
		}
	}
	var theme: Theme = .light {
		didSet {
			
			if self.theme != oldValue {
				self.themeDidChangeNotification.post()
//				self.iCloudKeyStore.set(self.theme.rawValue, forKey: self.themeKey)
				UserDefaults.standard.set(self.theme.rawValue, forKey: self.themeKey)
			}
		}
	}
	var themeTransitionDuration = 0.3
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
//				self.iCloudKeyStore.set(self.themeDeterminer.rawValue, forKey: self.themeDeterminerKey)
				UserDefaults.standard.set(self.themeDeterminer.rawValue, forKey: self.themeDeterminerKey)
				self.theme = self.determineTheme()
			}
		}
	}
	
	public func determineTheme() -> Theme {
		switch self.themeDeterminer {
			
		case .ambientLight:
			return self.themeBasedOnAmbientLight()
			
		case .displayBrightness:
			return self.themeBasedOnDisplayBrightness()
			
		case .twilight:
			return self.themeBasedOnTwilight()
		}
	}
	
	private func themeBasedOnAmbientLight() -> Theme {
		return .light
	}
	
	private func themeBasedOnDisplayBrightness() -> Theme {
		
		var theme: Theme = .light
		let brightness = Double(UIScreen.main.brightness)
		
		if brightness <= self.themeBrightnessThreshold {
			theme = .dark
		}
		
		return theme
	}
	var themeBrightnessThreshold: Double = 0.5 {
		didSet {
//			self.iCloudKeyStore.set(self.themeBrightnessThreshold, forKey: self.themeBrightnessThresholdKey)
			UserDefaults.standard.set(self.themeBrightnessThreshold, forKey: self.themeBrightnessThresholdKey)
			
			self.theme = self.determineTheme()
		}
	}
	@objc private func displayBrightnessDidChange() {
		self.theme = self.determineTheme()
	}

	private func themeBasedOnTwilight() -> Theme {
		var theme: Theme = .light
		
		// sunrise and sunset haven't been determined or are outdated
		if self.sunriseTime == nil || self.sunsetTime == nil {
			
			if !self.determiningTwilightTimes {
				
				self.determiningTwilightTimes = true
				
				RequestManager.shared.getSunriseAndSunset(completion: { (sunrise, sunset, error) in

					guard let sunrise = sunrise, let sunset = sunset, error == nil else {
						print("Couldn't get sunrise and sunset", error!)
						self.themeDeterminer = .displayBrightness
						self.determiningTwilightTimes = false
						return
					}
					
					self.sunriseTime = sunrise
					self.sunsetTime = sunset
					
					self.theme = self.themeBasedOnTwilight()
					self.determiningTwilightTimes = false
					
				})?.resume()
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
	var adaptiveArtistView: Bool = true {
		didSet {
			if self.adaptiveArtistView != oldValue {
//				self.iCloudKeyStore.set(self.adaptiveArtistView, forKey: self.adaptiveArtistViewKey)
				UserDefaults.standard.set(self.adaptiveArtistView, forKey: self.adaptiveArtistViewKey)
			}
		}
	}


	
	
	
	
	
	
	// MARK: - RELEASE OPTIONS
	private var _followingArtists: [Artist] = []
	var followingArtists: [Artist] {
		set {
			self._followingArtists = newValue
		}
		get {
			return self._followingArtists.sorted(by: { (first, second) -> Bool in
				return first.name < second.name
			})
		}
	}
	func follow(artist: Artist) {
		if !self.followingArtists.contains(where: { $0.itunesID == artist.itunesID }) {
			self.followingArtists.append(artist)
		}
		
		let encodedFollowingArtists = NSKeyedArchiver.archivedData(withRootObject: self.followingArtists)
		UserDefaults.standard.set(encodedFollowingArtists, forKey: self.followingArtistsKey)
//		self.iCloudKeyStore.set(encodedFollowingArtists, forKey: self.followingArtistsKey)
	}
	func unfollow(artist: Artist) {
		self.followingArtists.remove(at: self.followingArtists.index(where: { (followed: Artist) -> Bool in
			return followed.itunesID == artist.itunesID
		})!)
		
		let encodedFollowingArtists = NSKeyedArchiver.archivedData(withRootObject: self.followingArtists)
		UserDefaults.standard.set(encodedFollowingArtists, forKey: self.followingArtistsKey)
//		self.iCloudKeyStore.set(encodedFollowingArtists, forKey: self.followingArtistsKey)
	}
	
	private var _newReleases: [Release] = []
	var newReleases: [Release] {
		set {
			self._newReleases = newValue
		}
		get {
			let returnValue = self.followingArtists.flatMap({ (artist) -> [Release] in

				artist.releases.filter({ (release) -> Bool in
					
					if !release.seenByUser { // if release hasn't already been seen by user
						
						switch release.type {
						case .EP:
							if !(artist.includeEPs ?? self.includeEPs) { // user doesn't want to see EPs
								return false
							} else {
								return true
							}
						case .single:
							if !(artist.includeSingles ?? self.includeSingles) { // user doesn't want to see singles
								return false
							} else {
								if (artist.ignoreFeatures ?? self.ignoreFeatures) && release.isFeature { // user doesn't want to see features
									return false
								} else {
									return true
								}
							}
						default: return true
						}
						
					} else {
						return false
					}
				})
			})
			
			// sort according to user preference
			switch PreferenceManager.shared.releaseSorting {
			case .releaseDate: return returnValue.sorted(by: { $0.releaseDate > $1.releaseDate })
			case .releaseTitle: return returnValue.sorted(by: { $0.title < $1.title })
			case .artistName: return returnValue.sorted(by: { $0.title < $1.title }).sorted(by: { $0.artist.name < $1.artist.name })
			}

		}
	}
	private var _previousReleases: [Release] = []
	var previousReleases: [Release] {
		set {
			self._previousReleases = newValue
		}
		get {
			
            if PreferenceManager.shared.showPreviousReleases {
                
                let returnValue = self.followingArtists.flatMap({ (artist) -> [Release] in
                    
                    artist.releases.filter({ (release) -> Bool in
                        
                        if release.releaseDate < Calendar.current.date(byAdding: .month, value: -Int(self.maxPreviousReleaseAge), to: Date())! {
                            
                            return false
                            
                        } else {
                            
                            if release.seenByUser {
                                
								switch release.type {
								case .EP:
									if !(artist.includeEPs ?? self.includeEPs) { // user doesn't want to see EPs
										return false
									} else {
										return true
									}
								case .single:
									if !(artist.includeSingles ?? self.includeSingles) { // user doesn't want to see singles
										return false
									} else {
										if (artist.ignoreFeatures ?? self.ignoreFeatures) && release.isFeature { // user doesn't want to see features
											return false
										} else {
											return true
										}
									}
								default: return true
								}

							} else {
                                return false
                            }
                        }
                    })
                })

				// sort according to user preference
				switch PreferenceManager.shared.releaseSorting {
				case .releaseDate: return returnValue.sorted(by: { $0.releaseDate > $1.releaseDate })
				case .releaseTitle: return returnValue.sorted(by: { $0.title < $1.title })
				case .artistName: return returnValue.sorted(by: { $0.title < $1.title }).sorted(by: { $0.artist.name < $1.artist.name })
				}
				
            } else {
                
                return []
            }
        }
	}
	var lastReleasesUpdate: Date?
	func updateNewReleases(for artists: [Artist]?=nil, force: Bool?=false) {
		
		// don't update new releases if no artists are being followed or releases have been updated in the past last ten seconds
		if self.followingArtists.isEmpty {
			print("No artists being followed.")
			return
		}
		
		// check if updated recently
		if let lastUpdate = self.lastReleasesUpdate,
			let fiveMinutesAgo = Calendar.current.date(byAdding: .minute, value: -5, to: Date()),
			!force! {
			if lastUpdate >= fiveMinutesAgo {
				print("Releases update not needed.")
				return
			}
		}
		
		let artistsToUpdate = artists ?? self.followingArtists
		artistsToUpdate.forEach { (followed) in
			
			// request new releases for artists that need to be updated
			RequestManager.shared.getReleases(for: followed, since: Calendar.current.date(byAdding: .month, value: -Int(self.maxPreviousReleaseAge), to: Date()), completion: { (releases, error) in
				
				guard let releases = releases, error == nil else {
					print(error!)
					return
				}
				
				// only add releases that don't already exist
				followed.releases = releases.map({ (release) -> Release in
					
					if followed.releases.contains(where: { $0.itunesID == release.itunesID }) {
						guard let existingCorrespondingRelease = followed.releases.first(where: { $0.itunesID == release.itunesID }) else {
							return release
						}
						release.seenByUser = existingCorrespondingRelease.seenByUser
						release.thumbnailImage = existingCorrespondingRelease.thumbnailImage
						release.artworkImage = existingCorrespondingRelease.artworkImage
					}
					
					return release
				})
				
				// if on last artist
				if artistsToUpdate.last?.itunesID == followed.itunesID {
					
					// save following artists
					let encodedFollowingArtists = NSKeyedArchiver.archivedData(withRootObject: self.followingArtists)
					UserDefaults.standard.set(encodedFollowingArtists, forKey: self.followingArtistsKey)
					// self.iCloudKeyStore.set(encodedFollowingArtists, forKey: self.followingArtistsKey)
					
					// update last releases update
					self.lastReleasesUpdate = Date()
					
					// post notification
					self.didUpdateReleasesNotification.post()
					
				}
			})?.resume()
		}
	}
	var includeSingles: Bool = false {
		didSet {
			if self.includeSingles != oldValue {
				
//				self.iCloudKeyStore.set(self.includeSingles, forKey: self.includeSinglesKey)
				UserDefaults.standard.set(self.includeSingles, forKey: self.includeSinglesKey)
				self.didUpdateReleasesNotification.post()
			}
		}
	}
	var ignoreFeatures: Bool = true {
		didSet {
			if self.ignoreFeatures != oldValue {
//				self.iCloudKeyStore.set(self.ignoreFeatures, forKey: self.ignoreFeaturesKey)
				UserDefaults.standard.set(self.ignoreFeatures, forKey: self.ignoreFeaturesKey)
				self.didUpdateReleasesNotification.post()
			}
		}
	}
	var includeEPs: Bool = true {
		didSet {
			if self.includeEPs != oldValue {
				
//				self.iCloudKeyStore.set(self.includeEPs, forKey: self.includeEPsKey)
				UserDefaults.standard.set(self.includeEPs, forKey: self.includeEPsKey)
				self.didUpdateReleasesNotification.post()
			}
		}
	}
	var autoMarkAsSeen: Bool = true {
		didSet {
			if self.autoMarkAsSeen != oldValue {
			
//				self.iCloudKeyStore.set(self.autoMarkAsSeen, forKey: self.autoMarkAsSeenKey)
				UserDefaults.standard.set(self.autoMarkAsSeen, forKey: self.autoMarkAsSeenKey)
				self.didUpdateReleasesNotification.post()
			}
		}
	}
	var maxNewReleaseAge: Int64 = 4 { // in days
		didSet {
			if self.maxNewReleaseAge != oldValue {
				if self.maxNewReleaseAge <= 0 {
					self.maxNewReleaseAge = 1
				}
//				self.iCloudKeyStore.set(self.maxNewReleaseAge, forKey: self.maxNewReleaseAgeKey)
				UserDefaults.standard.set(self.maxNewReleaseAge, forKey: self.maxNewReleaseAgeKey)
				self.didUpdateReleasesNotification.post()
			}
		}
	}
	var showPreviousReleases: Bool = false {
		didSet {
			if self.showPreviousReleases != oldValue {
				
//				self.iCloudKeyStore.set(self.showPreviousReleases, forKey: self.showPreviousReleasesKey)
				UserDefaults.standard.set(self.showPreviousReleases, forKey: self.showPreviousReleasesKey)
				self.didUpdateReleasesNotification.post()
			}
		}
	}
	var maxPreviousReleaseAge: Int64 = 3 { // in months
		didSet {
			if self.maxPreviousReleaseAge != oldValue {
				if self.maxPreviousReleaseAge <= 0 {
					self.maxPreviousReleaseAge = 1
				}
//				self.iCloudKeyStore.set(self.maxPreviousReleaseAge, forKey: self.maxPreviousReleaseAgeKey)
				UserDefaults.standard.set(self.maxPreviousReleaseAge, forKey: self.maxPreviousReleaseAgeKey)
				self.didUpdateReleasesNotification.post()
			}
		}
	}
	var releaseSorting: ReleaseSorting = .releaseDate {
		didSet {
			if self.releaseSorting != oldValue {
			}
			UserDefaults.standard.set(self.releaseSorting.rawValue, forKey: self.releaseSortingKey)
			self.didUpdateReleasesNotification.post()
		}
	}
	
	
	
	
	var nowPlayingArtistLookupTask: URLSessionDataTask?
	var nowPlayingArtist: Artist? {
		didSet {
			if self.nowPlayingArtist?.itunesID != oldValue?.itunesID {
				self.nowPlayingArtistDidChangeNotification.post()
			}
		}
	}
	func nowPlayingItemDidChange() {
		
		// kill current lookup if exists
		self.nowPlayingArtistLookupTask?.cancel()
		self.nowPlayingArtistLookupTask = nil
		
		DispatchQueue.main.async { // Apple says MPMusicPlayerController interactions need to happen on the main thread. Not sure this qualifies, but meh.
			
			if let nowPlayingItem = MPMusicPlayerController.systemMusicPlayer().nowPlayingItem {
				
				guard let artistName = nowPlayingItem.albumArtist else {
					self.nowPlayingArtist = nil
					return
				}
				
				// get info for artist from iTunes
				print("Searching for now playing artist: \(artistName)")
				self.nowPlayingArtistLookupTask = RequestManager.shared.search(for: artistName, completion: { (artists, error) in
					
					// FIXME: This isn't a viable verification that the currently playing artist is the one that was found in the search
					guard let artist = artists?[0], error == nil else {
						print("Couldn't find the currently playing artist: ", error!)
						self.nowPlayingArtist = nil
						return
					}
					
					// load all info for artist
					self.nowPlayingArtistLookupTask = RequestManager.shared.getAdditionalInfo(for: artist, completion: { (artistWithInfo, error) in
						
						guard let artistWithInfo = artistWithInfo, error == nil else {
							print("Couldn't get additional info for the currently playing artist: ", error!)
							self.nowPlayingArtist = artist // set the artist anyway, artwork isn't mandatory
							return
						}
						
						_ = artistWithInfo.loadThumbnail {
							
							self.nowPlayingArtist = artistWithInfo
							_ = self.nowPlayingArtist?.loadArtwork()
						}
						
						
					})
						self.nowPlayingArtistLookupTask?.resume()
					
				})
					self.nowPlayingArtistLookupTask?.resume()

			} else {
				
				self.nowPlayingArtist = nil
			}
		}
	}






	// MARK: - DATA MANAGEMENT
	var lastSync: Date?
	let iCloudKeyStore = NSUbiquitousKeyValueStore.default()
	func isiCloudContainerAvailable() -> Bool {
		if FileManager.default.ubiquityIdentityToken != nil {
			return true
		}
		else {
			return false
		}
	}
	override init() {
		
		super.init()
		
		UserDefaults.standard.register(defaults: [
			self.firstLaunchKey: true,
			self.themeModeKey: ThemeMode.manual.rawValue,
			self.themeKey: Theme.light.rawValue,
			self.themeDeterminerKey: ThemeDeterminer.displayBrightness.rawValue,
			self.themeBrightnessThresholdKey: 0.5,
			self.adaptiveArtistViewKey: true,
			self.includeSinglesKey: false,
			self.ignoreFeaturesKey: true,
			self.includeEPsKey: true,
			self.autoMarkAsSeenKey: true,
			self.maxNewReleaseAgeKey: 4,
			self.showPreviousReleasesKey: true,
			self.maxPreviousReleaseAgeKey: 3,
			self.releaseSortingKey: 0
		])
		
//		NSUbiquitousKeyValueStore.didChangeExternallyNotification.add(self, selector: #selector(self.load))
		Notification.Name.MPMusicPlayerControllerNowPlayingItemDidChange.add(self, selector: #selector(self.nowPlayingItemDidChange))
		MPMusicPlayerController.systemMusicPlayer().beginGeneratingPlaybackNotifications()
		
	}
	func syncFromiCloud() {
		
		if let encodedFollowingArtists = self.iCloudKeyStore.object(forKey: self.followingArtistsKey) as? Data {
			self.followingArtists = NSKeyedUnarchiver.unarchiveObject(with: encodedFollowingArtists) as! [Artist]
		}
		
		self.themeMode = ThemeMode(rawValue: self.iCloudKeyStore.longLong(forKey: self.themeModeKey)) ?? self.themeMode
		
		if self.themeMode == .auto {
			
			self.themeBrightnessThreshold = self.iCloudKeyStore.double(forKey: self.themeBrightnessThresholdKey)
			
			self.themeDeterminer = ThemeDeterminer(rawValue: self.iCloudKeyStore.longLong(forKey: self.themeDeterminerKey)) ?? self.themeDeterminer
			
		} else {
			
			self.theme = Theme(rawValue: self.iCloudKeyStore.longLong(forKey: self.themeKey)) ?? self.theme
		}
		self.adaptiveArtistView = self.iCloudKeyStore.bool(forKey: self.adaptiveArtistViewKey)
		
		self.includeSingles = self.iCloudKeyStore.bool(forKey: self.includeSinglesKey)
		self.ignoreFeatures = self.iCloudKeyStore.bool(forKey: self.ignoreFeaturesKey)
		self.includeEPs = self.iCloudKeyStore.bool(forKey: self.includeEPsKey)
		self.autoMarkAsSeen = self.iCloudKeyStore.bool(forKey: self.autoMarkAsSeenKey)
		self.maxNewReleaseAge = self.iCloudKeyStore.longLong(forKey: self.maxNewReleaseAgeKey)
		self.showPreviousReleases = self.iCloudKeyStore.bool(forKey: self.showPreviousReleasesKey)
		self.maxPreviousReleaseAge = self.iCloudKeyStore.longLong(forKey: self.maxPreviousReleaseAgeKey)
		self.releaseSorting = ReleaseSorting(rawValue: self.iCloudKeyStore.longLong(forKey: self.releaseSortingKey)) ?? self.releaseSorting
		
		self.save {
			self.lastSync = Date()
		}
	}
	func syncToiCloud() {
		
		DispatchQueue.global().async {
						
			self.iCloudKeyStore.set(self.themeMode.rawValue, forKey: self.themeModeKey)
			self.iCloudKeyStore.set(self.theme.rawValue, forKey: self.themeKey)
			self.iCloudKeyStore.set(self.themeDeterminer.rawValue, forKey: self.themeDeterminerKey)
			self.iCloudKeyStore.set(self.themeBrightnessThreshold, forKey: self.themeBrightnessThresholdKey)
			self.iCloudKeyStore.set(self.adaptiveArtistView, forKey: self.adaptiveArtistViewKey)
			
			self.iCloudKeyStore.set(self.includeSingles, forKey: self.includeSinglesKey)
			self.iCloudKeyStore.set(self.ignoreFeatures, forKey: self.ignoreFeaturesKey)
			self.iCloudKeyStore.set(self.includeEPs, forKey: self.includeEPsKey)
			self.iCloudKeyStore.set(self.autoMarkAsSeen, forKey: self.autoMarkAsSeenKey)
			self.iCloudKeyStore.set(self.maxNewReleaseAge, forKey: self.maxNewReleaseAgeKey)
			self.iCloudKeyStore.set(self.showPreviousReleases, forKey: self.showPreviousReleasesKey)
			self.iCloudKeyStore.set(self.maxPreviousReleaseAge, forKey: self.maxPreviousReleaseAgeKey)
			self.iCloudKeyStore.set(self.releaseSorting.rawValue, forKey: self.releaseSortingKey)
			
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
			UserDefaults.standard.set(self.adaptiveArtistView, forKey: self.adaptiveArtistViewKey)
			
			UserDefaults.standard.set(self.includeSingles, forKey: self.includeSinglesKey)
			UserDefaults.standard.set(self.ignoreFeatures, forKey: self.ignoreFeaturesKey)
			UserDefaults.standard.set(self.includeEPs, forKey: self.includeEPsKey)
			UserDefaults.standard.set(self.autoMarkAsSeen, forKey: self.autoMarkAsSeenKey)
			UserDefaults.standard.set(NSNumber(value: self.maxNewReleaseAge), forKey: self.maxNewReleaseAgeKey)
			UserDefaults.standard.set(self.showPreviousReleases, forKey: self.showPreviousReleasesKey)
			UserDefaults.standard.set(NSNumber(value: self.maxPreviousReleaseAge), forKey: self.maxPreviousReleaseAgeKey)
			UserDefaults.standard.set(self.releaseSorting.rawValue, forKey: self.releaseSortingKey)
			
			let encodedFollowingArtists = NSKeyedArchiver.archivedData(withRootObject: self.followingArtists)
			UserDefaults.standard.set(encodedFollowingArtists, forKey: self.followingArtistsKey)
			
			UserDefaults.standard.synchronize()
		}
		
		completion?()
//		self.syncToiCloud()
	}
	func load(completion: (() -> Void)?=nil) {
		
		DispatchQueue.global().async {
			
			self.firstLaunch = UserDefaults.standard.bool(forKey: self.firstLaunchKey)
			
			if !self.firstLaunch {
//				self.syncFromiCloud()
			}
			
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
			self.adaptiveArtistView = UserDefaults.standard.bool(forKey: self.adaptiveArtistViewKey)
			
			self.includeSingles = UserDefaults.standard.bool(forKey: self.includeSinglesKey)
			self.ignoreFeatures = UserDefaults.standard.bool(forKey: self.ignoreFeaturesKey)
			self.includeEPs = UserDefaults.standard.bool(forKey: self.includeEPsKey)
			self.autoMarkAsSeen = UserDefaults.standard.bool(forKey: self.autoMarkAsSeenKey)
			self.maxNewReleaseAge = (UserDefaults.standard.object(forKey: self.maxNewReleaseAgeKey) as! NSNumber).int64Value
			self.showPreviousReleases = UserDefaults.standard.bool(forKey: self.showPreviousReleasesKey)
			self.maxPreviousReleaseAge = (UserDefaults.standard.object(forKey: self.maxPreviousReleaseAgeKey) as! NSNumber).int64Value
			self.releaseSorting = ReleaseSorting(rawValue: UserDefaults.standard.value(forKey: self.releaseSortingKey) as! Int64) ?? self.releaseSorting
			
			UserDefaults.standard.synchronize()

			completion?()
		}
	}
}
