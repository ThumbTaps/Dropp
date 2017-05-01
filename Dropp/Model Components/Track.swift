//
//  Track.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 4/30/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class Track: NSObject, NSCoding {
	
	var itunesID: Int!
	var title: String!
	var trackNumber: Int!
	var itunesURL: URL!
	var duration: Int?
	var isStreamable: Bool? = false
	var previewURL: URL?
	
	init(itunesID: Int!, title: String!, trackNumber: Int!, itunesURL: URL!) {
		
		super.init()
		
		self.itunesID = itunesID
		self.title = title
		self.trackNumber = trackNumber
		self.itunesURL = itunesURL
	}
	
	
	// MARK: - NSCoding
	func encode(with aCoder: NSCoder) {
		
		aCoder.encode(self.itunesID, forKey: "itunesID")
		aCoder.encode(self.title, forKey: "title")
		aCoder.encode(self.trackNumber, forKey: "trackNumber")
		aCoder.encode(self.itunesURL, forKey: "itunesURL")
		if self.duration != nil {
			aCoder.encode(self.duration, forKey: "duration")
		}
		if self.isStreamable != nil {
			aCoder.encode(self.isStreamable, forKey: "isStreamable")
		}
		if self.previewURL != nil {
			aCoder.encode(self.previewURL, forKey: "previewURL")
		}
	}
	required init?(coder aDecoder: NSCoder) {
		
		self.itunesID = aDecoder.decodeInteger(forKey: "itunesID")
		self.title = aDecoder.decodeObject(forKey: "title") as! String
		self.trackNumber = aDecoder.decodeInteger(forKey: "trackNumber")
		self.itunesURL = aDecoder.decodeObject(forKey: "itunesURL") as! URL
		self.duration = aDecoder.decodeInteger(forKey: "duration")
		self.isStreamable = aDecoder.decodeBool(forKey: "isStreamable")
		self.previewURL = aDecoder.decodeObject(forKey: "previewURL") as? URL
	}

}
