//
//  Release.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 12/25/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

enum ReleaseType {
	case single, EP, album
}
class Release: NSObject, NSCoding {
	
	var itunesID: Int!
	var title: String!
	var releaseDate: Date!
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
				self.thumbnailImage = Utils.scaleImage(self.artworkImage!, to: PreferenceManager.shared.thumbnailSize)
				
				// save to filesystem if artist is being followed
				if self.artist.isBeingFollowed {
					PreferenceManager.shared.cacheArtwork(release: self)
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
	var tracks: [Track]?
	var isFeature = false
	private var _seenByUser: Bool?
	var seenByUser: Bool {
		get {
			
			if self._seenByUser == nil {
				
				// check user library + date + manual trigger
				if self.releaseDate < Calendar.current.date(byAdding: .day, value: -Int(PreferenceManager.shared.maxNewReleaseAge), to: Date())! {
					return true
				}
				
				return false
				
			} else {
				
				return self._seenByUser!
			}
		}
		set {
			self._seenByUser = newValue
		}
	}
	var type: ReleaseType {
		get {
			if self.title.lowercased().hasSuffix("- single") || self.tracks?.count == 1 {
				return .single
			} else if self.title.lowercased().hasSuffix(" ep") {
				return .EP
			} else {
				return .album
			}
		}
	}
	private var _artist: Artist?
	var artist: Artist! {
		set {
			self._artist = newValue
		}
		get {
			if self._artist == nil {
				self._artist = PreferenceManager.shared.followingArtists.first(where: { $0.releases.contains(where: { $0.itunesID == itunesID }) })
			}
			
			return self._artist
		}
	}
	
	
	init(itunesID: Int!, title: String!, releaseDate: Date!, itunesURL: URL!) {
		
		super.init()
		
		self.itunesID = itunesID
		self.title = title
		self.releaseDate = releaseDate
		self.itunesURL = itunesURL
	}
	
	
	// MARK: - NSCoding
	func encode(with aCoder: NSCoder) {
		
		aCoder.encode(self.itunesID, forKey: "itunesID")
		aCoder.encode(self.title, forKey: "title")
		aCoder.encode(self.releaseDate, forKey: "releaseDate")
		if self.summary != nil {
			aCoder.encode(self.summary, forKey: "summary")
		}
		if self.genre != nil {
			aCoder.encode(self.genre, forKey: "genre")
		}
		aCoder.encode(self.itunesURL, forKey: "itunesURL")
		if self.artworkURL != nil {
			aCoder.encode(self.artworkURL, forKey: "artworkURL")
		}
		if self.tracks != nil {
			aCoder.encode(self.tracks, forKey: "tracks")
		}
		aCoder.encode(self.isFeature, forKey: "isFeature")
		if self._seenByUser != nil {
			aCoder.encode(self._seenByUser, forKey: "seenByUser")
		}
	}
	required init?(coder aDecoder: NSCoder) {
		
		self.itunesID = aDecoder.decodeObject(forKey: "itunesID") as! Int
		self.title = aDecoder.decodeObject(forKey: "title") as! String
		self.releaseDate = aDecoder.decodeObject(forKey: "releaseDate") as! Date
		self.summary = aDecoder.decodeObject(forKey: "summary") as? String
		self.genre = aDecoder.decodeObject(forKey: "genre") as? String
		self.itunesURL = aDecoder.decodeObject(forKey: "itunesURL") as! URL
		self.artworkURL = aDecoder.decodeObject(forKey: "artworkURL") as? URL
		self.tracks = aDecoder.decodeObject(forKey: "tracks") as? [Track]
		self.isFeature = (aDecoder.decodeObject(forKey: "isFeature") as? Bool) ?? false
		self._seenByUser = aDecoder.decodeObject(forKey: "seenByUser") as? Bool
	}
	
	
	// MARK: - Custom Methods
	func isNewerThan(_ release: Release) -> Bool {
		return release.releaseDate > self.releaseDate
	}
	
	private var artworkLoadTask: URLSessionDataTask?
	private var artworkLoadListeners: [(() -> Void)] = []
	func loadArtwork(thumbnailOnly: Bool?=false, _ completion: (() -> Void)?=nil) -> URLSessionDataTask? {
		
		// only load artwork if it hasn't already been loaded and stored on the instance
		guard (!thumbnailOnly! && self.artworkImage == nil) || (thumbnailOnly! && self.thumbnailImage == nil) else {
			completion?()
			return nil
		}
		
		if let storedArtwork = PreferenceManager.shared.loadArtwork(release: self) {
			
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
					print("Failed to load artwork for \(self.title!): ", error ?? "")
					return
				}
				
				self.artworkImage = image
				self.artworkLoadTask = nil
				completion?()
				
				// execute any callbacks in waiting
				self.artworkLoadListeners.forEach({ $0() })
				self.artworkLoadListeners = []
				
			})
			
			self.artworkLoadTask?.resume()
		}
		
		return self.artworkLoadTask
	}
	private var trackLoadTask: URLSessionDataTask?
	private var trackLoadListeners: [(() -> Void)] = []
	func loadTracks(_ completion: (() -> Void)?=nil) -> URLSessionDataTask? {
		
		// only load tracks if they haven't already been loaded
		guard self.tracks == nil else {
			completion?()
			return nil
		}
		
		// make sure the task isn't already running
		if self.trackLoadTask != nil {
			if completion != nil {
				self.trackLoadListeners.append(completion!)
			}
			return nil
		}
		
		self.trackLoadTask = RequestManager.shared.getTracks(for: self) { (tracks, error) in
			guard let tracks = tracks, error == nil else {
				print("Failed to load tracks for \(self.title!): ", error ?? "")
				return
			}
			
			self.tracks = tracks
			self.trackLoadTask = nil
			completion?()
			
			// execute any callbacks in waiting
			self.trackLoadListeners.forEach({ $0() })
			self.trackLoadListeners = []
		}
		
		self.trackLoadTask?.resume()
		return self.trackLoadTask
	}
}
