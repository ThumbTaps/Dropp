//
//  Artist.swift
//  Ursus
//
//  Created by Jeffery Jackson on 5/4/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

enum ArtworkSize: Int {
	case small = 0, medium = 1, large = 2, extraLarge = 3, mega = 4, thumbnail = 5
}

class Artist: NSObject, NSCoding {

	var itunesID: Int!
	var name: String!
	var itunesURL: URL!
	var summary: String?
	var genre: String?
	var artworkURLs: [ArtworkSize: URL]! = [:]
	var releases: [Release]! = []
	var latestRelease: Release? {
		get {
			return self.releases.max(by: { $0.isNewerThan($1) })
		}
	}
	
	
	init(itunesID: Int!, name: String!, itunesURL: URL!, summary: String?, genre: String?, artworkURLs: [ArtworkSize: URL]?, releases: [Release]?) {
		
		super.init()
		
		self.itunesID = itunesID
		self.name = name
		self.itunesURL = itunesURL
		self.summary = summary
		self.genre = genre
		self.artworkURLs = artworkURLs
		self.releases = releases
		
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
		if self.artworkURLs != nil {
			aCoder.encode(self.artworkURLs.flatMap({ $0.value }), forKey: "artworkURLs")
		}
		if self.releases != nil {
			aCoder.encode(self.releases, forKey: "releases")
		}
	}
	required init?(coder aDecoder: NSCoder) {
		
		super.init()
		
		self.itunesID = aDecoder.decodeObject(forKey: "itunesID") as! Int
		self.name = aDecoder.decodeObject(forKey: "name") as! String
		self.itunesURL = aDecoder.decodeObject(forKey: "itunesURL") as! URL
		self.summary = aDecoder.decodeObject(forKey: "summary") as? String
		self.genre = aDecoder.decodeObject(forKey: "genre") as? String
		if let artworkArray = aDecoder.decodeObject(forKey: "artworkURLs") as? [URL] {
			for (index, element) in artworkArray.enumerated() {
				self.artworkURLs[ArtworkSize(rawValue: index)!] = element
			}
		}
		self.releases = aDecoder.decodeObject(forKey: "releases") as! [Release]
	}
}
