//
//  Artist.swift
//  Dropp
//
//  Created by Jeffery Jackson on 5/4/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class Artist: NSObject, NSCoding {

	var itunesID: Int!
	var name: String!
	var itunesURL: URL!
	var summary: String?
	var genre: String?
	var artworkURL: URL?
	private var _artworkImage: UIImage?
	var artworkImage: UIImage? {
		set {
			if newValue != nil {
				
				// scale to appropriate resolution
				self._artworkImage = Utils.scaleImage(newValue!, to: PreferenceManager.shared.artworkSize)
				if self.artworkImage != nil {
					self.thumbnailImage = Utils.scaleImage(self.artworkImage!, to: PreferenceManager.shared.thumbnailSize)
				}
				
				// save to filesystem if artist is being followed
				if self.isBeingFollowed {
					PreferenceManager.shared.cacheArtwork(artist: self)
				}
			} else {
				self._artworkImage = newValue
			}
		}
		get {
			return self._artworkImage
		}
	}
	var thumbnailImage: UIImage?
	var releases: [Release] = []
	var isBeingFollowed: Bool {
		return PreferenceManager.shared.followingArtists.contains(where: { $0.itunesID == self.itunesID })
	}
	var latestRelease: Release? {
		get {
			return self.releases.max(by: { $0.isNewerThan($1) })
		}
	}
	var includeSingles: Bool? {
		didSet {
			if self.includeSingles != oldValue {
				PreferenceManager.shared.updateNewReleases(for: [self])
			}
		}
	}
	var ignoreFeatures: Bool? {
		didSet {
			if self.ignoreFeatures != oldValue {
				PreferenceManager.shared.updateNewReleases(for: [self])
			}
		}
	}
	var includeEPs: Bool? {
		didSet {
			if self.includeEPs != oldValue {
				PreferenceManager.shared.updateNewReleases(for: [self])
			}
		}
	}
	var lastUpdate: Date? = nil {
		didSet {
			guard let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) else {
				return
			}

			if (self.lastUpdate ?? oneWeekAgo) < oneWeekAgo {
				// update artist info
				RequestManager.shared.getAdditionalInfo(for: self, completion: { (artist, error) in
					guard let artist = artist, error == nil else {
						return
					}
					
					self.summary = artist.summary
					self.genre = artist.genre
					self.artworkURL = artist.artworkURL
					self.artworkImage = nil
					self.thumbnailImage = nil
					
					self.lastUpdate = Date()
					
				})?.resume()
			}
		}
	}
	
	init(itunesID: Int!, name: String!, itunesURL: URL!) {
		
		super.init()
		
		self.itunesID = itunesID
		self.name = name
		self.itunesURL = itunesURL
	}
	
	
	
	// MARK: - NSCoding
	func encode(with aCoder: NSCoder) {
		
		aCoder.encode(self.itunesID, forKey: "itunesID")
		aCoder.encode(self.name, forKey: "name")
		aCoder.encode(self.itunesURL, forKey: "itunesURL")
		
		if self.summary != nil {
			aCoder.encode(self.summary, forKey: "summary")
		}
		if self.genre != nil {
			aCoder.encode(self.genre, forKey: "genre")
		}
		if self.artworkURL != nil {
			aCoder.encode(self.artworkURL, forKey: "artworkURL")
		}
//		aCoder.encode(self.releases, forKey: "releases")
		
		if self.includeSingles != nil {
			aCoder.encode(self.includeSingles, forKey: "includeSingles")
		}
		if self.ignoreFeatures != nil {
			aCoder.encode(self.ignoreFeatures, forKey: "ignoreFeatures")
		}
		if self.includeEPs != nil {
			aCoder.encode(self.includeEPs, forKey: "includeEPs")
		}
		if self.lastUpdate != nil {
			print("Saving last update")
			aCoder.encode(self.lastUpdate, forKey: "lastUpdate")
		}
	}
	required init?(coder aDecoder: NSCoder) {
		
		super.init()
		
		self.itunesID = aDecoder.decodeObject(forKey: "itunesID") as! Int
		self.name = aDecoder.decodeObject(forKey: "name") as! String
		self.itunesURL = aDecoder.decodeObject(forKey: "itunesURL") as! URL
		self.summary = aDecoder.decodeObject(forKey: "summary") as? String
		self.genre = aDecoder.decodeObject(forKey: "genre") as? String
		self.artworkURL = aDecoder.decodeObject(forKey: "artworkURL") as? URL
//		self.releases = aDecoder.decodeObject(forKey: "releases") as! [Release]
		self.includeSingles = aDecoder.decodeObject(forKey: "includeSingles") as? Bool
		self.ignoreFeatures = aDecoder.decodeObject(forKey: "ignoreFeatures") as? Bool
		self.includeEPs = aDecoder.decodeObject(forKey: "includeEPs") as? Bool
		defer {
			print("Setting last update")
			self.lastUpdate = aDecoder.decodeObject(forKey: "lastUpdate") as? Date
		}
	}
	
	private var artworkLoadTask: URLSessionDataTask?
	private var artworkLoadListeners: [(() -> Void)] = []
	func loadArtwork(thumbnailOnly: Bool?=false, _ completion: (() -> Void)?=nil) -> URLSessionDataTask? {
		
		// only load artwork if it hasn't already been loaded and stored on the instance
		guard (!thumbnailOnly! && self.artworkImage == nil) || (thumbnailOnly! && self.thumbnailImage == nil) else {
			completion?()
			return nil
		}
		
		if let storedArtwork = PreferenceManager.shared.loadArtwork(artist: self) {
			
			if thumbnailOnly! {
				self.thumbnailImage = Utils.scaleImage(storedArtwork, to: PreferenceManager.shared.thumbnailSize)
				completion?()
				return nil
			}
			
			self.artworkImage = storedArtwork
			completion?()
			
		} else {
			
			// make sure there's a URL to load and that the task isn't already running
			guard let artworkURL = self.artworkURL else {
				return nil
			}
			
			if self.artworkLoadTask != nil {
				if completion != nil {
					self.artworkLoadListeners.append(completion!)
				}
				return nil
			}
			
			// load image from artwork url
			self.artworkLoadTask = RequestManager.shared.loadImage(from: artworkURL, completion: { (image, error) in
				guard let image = image, error == nil else {
					print("Failed to load artwork for \(self.name): ", error ?? "")
					return
				}
				
				self.artworkImage = image
				self.artworkLoadTask = nil
				completion?()
				
				// execute any callbacks in waiting
				self.artworkLoadListeners.forEach({ $0() })
				
				// empty artwork callback array
				self.artworkLoadListeners = []
				
			})
			
			self.artworkLoadTask?.resume()
		}
		
		return self.artworkLoadTask
	}
}
