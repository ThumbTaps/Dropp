//
//  Artist.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 7/4/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

class Artist: Codable, Hashable {
	
	var id: Int!
	var name: String!
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
	var isFollowed: Bool {
		get {
			return DataStore.followedArtists.contains(where: { (artist) -> Bool in
				return artist.id == self.id
			})
		}
	}

	private var cache = NSCache<NSString, NSData>()
	
	init(id: Int!, name: String!) {
		self.id = id
		self.name = name
		
		self.cache.evictsObjectsWithDiscardedContent = false
	}
	
	func follow() {
		if !DataStore.followedArtists.contains(where: { (artist) -> Bool in
			return artist.id == self.id
		}) {
			DataStore.followedArtists.append(self)
		}
	}
	func unfollow() {
		DataStore.followedArtists.removeAll { (artist) -> Bool in
			return artist.id == self.id
		}
	}
	func getReleases(from fromDate: Date = Date.distantPast, completion: ((_ releases: [Release]?, _ error: Error?) -> Void)!) {
		iTunesAPI.lookupReleases(byArtist: self.id) { (releases, error) in
			guard error == nil else {
				completion(nil, error); print(error!.localizedDescription)
				return
			}
			
			completion(releases?.compactMap({ (releaseJSON) -> Release? in
				guard let id = releaseJSON["collectionId"] as? String,
					let title = releaseJSON["collectionName"] as? String,
					let date = releaseJSON["releaseDate"] as? String else {
						print("Couldn't create release from JSON: ", releaseJSON)
						return nil
				}
				
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ssZ"
				let releaseDate = dateFormatter.date(from: date)
				
				let release = Release(by: self, titled: title, on: releaseDate, withIdentifer: Int(id))
				
				if let artworkURLString = releaseJSON["artworkUrl100"] as? String,
					let lastSlashIndex = artworkURLString.lastIndex(of: "/") {
	
					let urlPrefix = artworkURLString[...lastSlashIndex]
					release.artworkURL = urlPrefix + "1000x1000bb.jpg"
					release.thumbnailURL = urlPrefix + "200x200bb.jpg"
				}
				
				guard release.releaseDate?.compare(fromDate) == .orderedDescending else {
					return nil
				}
				
				return release
			}), nil)
		}
	}
	func getArtwork(thumbnail: Bool = false, completion: ((_ image: UIImage?, _ error: Error?) -> Void)? = nil) {
		var cacheData: NSData?
		if thumbnail {
			cacheData = self.cache.object(forKey: "thumbnailImage")
		} else {
			cacheData = self.cache.object(forKey: "artworkImage")
		}
		
		// try to load the artwork from cache
		guard cacheData == nil else {
			completion?(UIImage(data: cacheData! as Data), nil)
			print("Artwork was cached")
			return
		}
		
		print("Couldn't retrieve artwork for \(self.name!) from cache...")
		
		guard let urlString = thumbnail ? self.thumbnailURL : self.artworkURL,
			let imageURL = URL(string: urlString) else {
				
				print("Didn't have a url for artwork for \(self.name!), pulling from last.fm...")
				// get artwork from last.fm
				lastfmAPI.getArtwork(forArtist: self.name) { (artwork, error) in
					guard error == nil else {
						completion?(nil, error); print(error!.localizedDescription)
						return
					}
					
					self.thumbnailURL = artwork?.thumbnail
					self.artworkURL = artwork?.full
					
					self.getArtwork(thumbnail: thumbnail, completion: completion)
				}
				
				return
		}
		
		print("Loading artwork image for \(self.name!)...")
		// load artwork image
		Utilities.loadImage(imageURL: imageURL, completion: { (image, error) in
			guard error == nil else {
				completion?(nil, error); print(error!.localizedDescription)
				return
			}
			
			if let imageData = image?.pngData() ?? image?.jpegData(compressionQuality: 1) {
				let cacheData = NSData(data: imageData)
				if thumbnail {
					self.cache.setObject(cacheData, forKey: "thumbnailImage", cost: cacheData.length)
				} else {
					self.cache.setObject(cacheData, forKey: "artworkImage", cost: cacheData.length)
				}
				print("Cached artwork for \(self.name!)...")
			}

			completion?(image, nil)
		})
	}
	
	static func search(named name: String!, _ completion: ((_ results: [Artist]?, _ error: Error?) -> Void)!) {
		iTunesAPI.search(forArtist: name) { (artists, error) in
			guard error == nil else {
				completion?(nil, error)
				print(error!.localizedDescription)
				return
			}
			
			completion?(artists?.compactMap({ (artistJSON) -> Artist? in
				guard let id = artistJSON["artistId"] as? String,
					let name = artistJSON["artistName"] as? String else {
						print("Couldn't create artist locally from JSON:", artistJSON)
						return nil
				}
				
				return Artist(id: Int(id), name: name)
			}), nil)
		}
	}
	
	
	
	
	static func == (lhs: Artist, rhs: Artist) -> Bool {
		return lhs.id == rhs.id
	}
	var hashValue: Int {
		return self.id.hashValue
	}
	
	private enum CodingKeys: String, CodingKey {
		case id, name, artworkURL, thumbnailURL
	}
	
	required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		self.id = try values.decode(Int.self, forKey: .id)
		self.name = try values.decode(String.self, forKey: .name)
		self.artworkURL = try values.decode(String?.self, forKey: .artworkURL)
		self.thumbnailURL = try values.decode(String?.self, forKey: .thumbnailURL)
	}
	
	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.id, forKey: .id)
		try container.encode(self.name, forKey: .name)
		try container.encode(self.artworkURL, forKey: .artworkURL)
		try container.encode(self.thumbnailURL, forKey: .thumbnailURL)
	}
}
