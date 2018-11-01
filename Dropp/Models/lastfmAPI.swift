//
//  lastfmAPI.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 7/23/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import Foundation

class lastfmAPI {
	
	struct Artwork {
		
		var thumbnail: String?
		var full: String?
	}

	private static let apiKey = "d2c054b7fa77748a2b1adc44a9601774"
	private static let apiSecret = "99bfd5ca44f6d9402c14e514918389ae"
	
	private static let baseURL = "https://ws.audioscrobbler.com/2.0/?api_key=\(lastfmAPI.apiKey)&format=json"
	
	
	private class func parse(_ data: Data) -> [String: Any]? {
		do {
			guard let results = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
				// TODO: Need an error here
				return nil
			}
			
			return results
		} catch {
			return nil
		}
	}
	
	class func getArtwork(forArtist name: String!, completion: ((_ artwork: lastfmAPI.Artwork?, _ error: Error?) -> Void)!) {
		
		URLSession.shared.dataTask(with: URL(string: "\(baseURL)&method=artist.getinfo&artist=\(name.replacingOccurrences(of: " ", with: "+"))")!) { (data, response, error) in
			guard error == nil else {
				completion(nil, error); print(error!.localizedDescription)
				return
			}
			
			guard let results = self.parse(data!) else {
				completion(nil, nil)
				return
			}
			
			guard let artistInfo = results["artist"] as? [String: Any],
				let images = artistInfo["image"] as? [[String: Any]]  else {
					completion(nil, nil)
					return
			}
			
			// get thumbnail url
			guard let thumbnailURL = images.filter({ (image) -> Bool in
				return (image["size"] as? String) == "large"
			}).first?["#text"] as? String,
				
				// get full url
				let artworkURL = images.filter({ (image) -> Bool in
				return (image["size"] as? String) == "mega"
				}).first?["#text"] as? String else {
					
					completion(nil, nil)
					return
			}
						
			completion(lastfmAPI.Artwork(thumbnail: thumbnailURL, full: artworkURL), nil)
			
		}.resume()
	}
}
