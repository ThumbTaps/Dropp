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
	var artworkURLs: [String: URL]?
	var latestAlbum: Album?
	
	
	init(itunesID: Int!, name: String!, itunesURL: URL!, summary: String?, genre: String?, artworkURLs: [String: URL]?, latestAlbum: Album?) {
		
		super.init()
		
		self.itunesID = itunesID
		self.name = name
		self.itunesURL = itunesURL
		self.summary = summary
		self.genre = genre
		self.artworkURLs = artworkURLs
		self.latestAlbum = latestAlbum
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
			aCoder.encode(self.artworkURLs, forKey: "artworkURLs")
		}
		if self.latestAlbum != nil {
			aCoder.encode(self.latestAlbum, forKey: "latestAlbum")
		}
	}
	required init?(coder aDecoder: NSCoder) {
		
		super.init()
		
		self.itunesID = aDecoder.decodeObject(forKey: "itunesID") as! Int
		self.name = aDecoder.decodeObject(forKey: "name") as! String
		self.itunesURL = aDecoder.decodeObject(forKey: "itunesURL") as! URL
		self.summary = aDecoder.decodeObject(forKey: "summary") as? String
		self.genre = aDecoder.decodeObject(forKey: "genre") as? String
		self.artworkURLs = aDecoder.decodeObject(forKey: "artworkURLs") as? [String: URL]
		self.latestAlbum = aDecoder.decodeObject(forKey: "latestAlbum") as? Album
	}
}
