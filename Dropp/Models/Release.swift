//
//  Album.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 7/4/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

class Release: Codable, Hashable {
	
    enum Classification: Int {
		case album, ep, single
		
		var indicatorString: String {
			switch self {
			case .album:
				return "A"
			case .ep:
				return "EP"
			case .single:
				return "S"
			}
		}
	}
	
	let id: Int!
	let title: String!
	let releaseDate: Date!
	let artist: Artist!
	var genre: String?
    let classification: Classification!
    
    var isExplicit: Bool
	
	var artworkURL: String?
	private var thumbnail_url: String?
	var thumbnailURL: String? {
		get {
			return self.thumbnail_url ?? self.artworkURL
		}
		set {
			self.thumbnail_url = newValue
		}
	}
	
	private var cache = NSCache<NSString, NSData>()
	
    init(by artist: Artist!, titled title: String!, on releaseDate: Date!, withIdentifer id: Int!, genre: String?=nil, isExplicit: Bool?=false) {
		self.artist = artist
		self.releaseDate = releaseDate
		self.id = id
        
        // determine classification
        if title.contains(" - Single") {
            self.title = title.replacingOccurrences(of: " - Single", with: "")
            self.classification = .single
            
        } else if title.contains(" - EP") {
            self.title = title.replacingOccurrences(of: " - EP", with: "")
            self.classification = .ep
            
        } else {
            self.title = title
            self.classification = .album
        }
        
        self.isExplicit = isExplicit ?? false
    }
	
	func getArtwork(thumbnail: Bool = false, completion: ((_ image: UIImage?, _ error: Error?) -> Void)!) {
		var imageData: Data?
		if thumbnail {
			imageData = self.cache.object(forKey: "thumbnailImage") as Data?
		} else {
			imageData = self.cache.object(forKey: "artworkImage") as Data?
		}
		
		guard imageData == nil else {
			completion(UIImage(data: imageData!), nil)
			return
		}
		
		guard let urlString = thumbnail ? self.thumbnailURL : self.artworkURL,
			let imageURL = URL(string: urlString) else {
			completion(nil, nil)
			return
		}
		
		Utilities.loadImage(imageURL: imageURL) { (image, error) in
			guard error == nil else {
				completion(nil, error)
				return
			}
			
			if let imageData = image?.pngData() ?? image?.jpegData(compressionQuality: 1) {
				let cacheData = NSData(data: imageData)
				if thumbnail {
					self.cache.setObject(cacheData, forKey: "thumbnailImage", cost: cacheData.length)
				} else {
					self.cache.setObject(cacheData, forKey: "artworkImage", cost: cacheData.length)
				}
				print("Cached artwork for \(self.title!)...")
			}

			completion(image, nil)
		}
	}
	
	
	
	
	static func == (lhs: Release, rhs: Release) -> Bool {
		return lhs.id == rhs.id
	}
	
	var hashValue: Int {
		return self.id.hashValue
	}
	
	private enum CodingKeys: String, CodingKey {
		case id, title, releaseDate, artist, genre, classification, isExplicit, artworkURL, thumbnailURL
	}
	
	required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try values.decode(Int.self, forKey: .id)
		self.title = try values.decode(String.self, forKey: .title)
		let releaseDate_unix = try values.decode(TimeInterval.self, forKey: .releaseDate)
		self.releaseDate = Date(timeIntervalSince1970: releaseDate_unix)
		self.artist = try values.decode(Artist.self, forKey: .artist)
		self.genre = try values.decode(String?.self, forKey: .genre)
        let rawClassification = try values.decode(Int.self, forKey: .classification)
        self.classification = Classification.init(rawValue: rawClassification)
        self.isExplicit = try values.decode(Bool.self, forKey: .isExplicit)
		self.artworkURL = try values.decode(String?.self, forKey: .artworkURL)
		self.thumbnailURL = try values.decode(String?.self, forKey: .thumbnailURL)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.id, forKey: .id)
		try container.encode(self.title, forKey: .title)
		let releaseDate_unix = self.releaseDate.timeIntervalSince1970
		try container.encode(releaseDate_unix, forKey: .releaseDate)
		try container.encode(self.artist, forKey: .artist)
		try container.encode(self.genre, forKey: .genre)
        try container.encode(self.classification.rawValue, forKey: .classification)
        try container.encode(self.isExplicit, forKey: .isExplicit)
		try container.encode(self.artworkURL, forKey: .artworkURL)
		try container.encode(self.thumbnailURL, forKey: .thumbnailURL)
	}
}
