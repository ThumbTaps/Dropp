//
//  Release.swift
//  Lissic
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
	var artworkImage: UIImage?
	var thumbnailURL: URL?
	var thumbnailImage: UIImage?
	var trackCount: Int?
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
			if self.title.lowercased().hasSuffix("- single") || self.trackCount == 1 {
				return .single
			} else if self.title.lowercased().hasSuffix(" ep") {
				return .EP
			} else {
				return .album
			}
		}
	}
	var artist: Artist {
		get {
			return PreferenceManager.shared.followingArtists.first(where: {
				$0.releases.contains(where: {
					$0.itunesID == itunesID
				})
			})! // this can't return nil because the releases literally don't exist without the artists
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
		if self.thumbnailURL != nil {
			aCoder.encode(self.artworkURL, forKey: "thumbnailURL")
		}
		if self.trackCount != nil {
			aCoder.encode(self.trackCount, forKey: "trackCount")
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
		self.thumbnailURL = aDecoder.decodeObject(forKey: "thumbnailURL") as? URL
		self.trackCount = aDecoder.decodeObject(forKey: "trackCount") as? Int
		self.isFeature = (aDecoder.decodeObject(forKey: "isFeature") as? Bool) ?? false
		self._seenByUser = aDecoder.decodeObject(forKey: "seenByUser") as? Bool
	}
	
	
	// MARK: - Custom Methods
	func isNewerThan(_ release: Release) -> Bool {
		return release.releaseDate > self.releaseDate
	}

	func loadThumbnail(_ completion: (() -> Void)?=nil) -> URLSessionDataTask? {
		
		// only load artwork if it hasn't already been loaded and stored
		guard self.thumbnailImage != nil else {
			completion?()
			return nil
		}
		
		// make sure there's an artwork url first
		guard let thumbnailURL = self.thumbnailURL else {
			completion?()
			return nil
		}
		
		// load image from artwork url
		let task = RequestManager.shared.loadImage(from: thumbnailURL, completion: { (image, error) in
			guard let image = image, error == nil else {
				completion?()
				return
			}
			
			self.thumbnailImage = image
			completion?()
			
		})
		
		task?.resume()
		return task
	}
	func loadArtwork(_ completion: (() -> Void)?=nil) -> URLSessionDataTask? {
		
		// only load artwork if it hasn't already been loaded and stored
		guard self.artworkImage != nil else {
			completion?()
			return nil
		}
		
		// make sure there's an artwork url first
		guard let artworkURL = self.artworkURL else {
			completion?()
			return nil
		}
		
		// load image from artwork url
		let task = RequestManager.shared.loadImage(from: artworkURL, completion: { (image, error) in
			guard let image = image, error == nil else {
				completion?()
				return
			}
			
			self.artworkImage = image
			completion?()
			
		})
		
		task?.resume()
		return task
	}
}
