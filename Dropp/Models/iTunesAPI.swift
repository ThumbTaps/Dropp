//
//  File.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 7/16/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import Foundation

class iTunesAPI {
	
	private class func parse(_ data: Data) -> [[String: Any]]? {
		do {
			guard let results = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
				// TODO: Need an error here
                print("Parsing iTunes API results failed.")
				return nil
			}
			
			return results["results"] as? [[String: Any]]
		} catch {
			return nil
		}
	}
	
	class func search(forArtist artistName: String!, completion: ((_ results: [[String: Any]]?, _ error: Error?) -> Void)!) {
		
		URLSession.shared.dataTask(with: URL(string: "https://itunes.apple.com/search?term=\(artistName.replacingOccurrences(of: " ", with: "+"))&media=music&entity=musicArtist&attribute=artistTerm")!) { (data, response, error) in
			guard error == nil else {
				completion(nil, error)
				return
			}
			
			guard let results = self.parse(data!) else {
				completion(nil, nil)
				return
			}
			
			completion(results, nil)
			}.resume()
	}
	
	class func search(forRelease releaseName: String!, completion: ((_ results: [[String: Any]]?, _ error: Error?) -> Void)!) {
		
		URLSession.shared.dataTask(with: URL(string: "https://itunes.apple.com/search?term=\(releaseName.replacingOccurrences(of: " ", with: "+"))&media=music&entity=album&attribute=albumTerm")!) { (data, response, error) in
			guard error == nil else {
				completion(nil, error)
				return
			}
			
			guard let results = self.parse(data!) else {
				completion(nil, nil)
				return
			}
			
			completion(results, nil)
			}.resume()
	}
	
	class func lookup(artist artistID: Int!, completion: ((_ result: [String: Any]?, _ error: Error?) -> Void)!) {
		
		URLSession.shared.dataTask(with: URL(string: "https://itunes.apple.com/lookup?id=\(String(artistID))&media=music&entity=artist")!) { (data, response, error) in
			guard error == nil else {
				completion(nil, error)
				return
			}
			
			guard let results = self.parse(data!) else {
				completion(nil, nil)
				return
			}
			
			completion(results.first, nil)
			}.resume()
	}
	
	class func lookup(release releaseID: Int!, completion: ((_ result: [String: Any]?, _ error: Error?) -> Void)!) {
		
		URLSession.shared.dataTask(with: URL(string: "https://itunes.apple.com/lookup?id=\(String(releaseID))&media=music&entity=album")!) { (data, response, error) in
			guard error == nil else {
				completion(nil, error)
				return
			}
			
			guard let results = self.parse(data!) else {
				completion(nil, nil)
				return
			}
			
			completion(results.first, nil)
			}.resume()
	}
	
	class func lookupReleases(byArtist artistID: Int!, completion: ((_ results: [[String: Any]]?, _ error: Error?) -> Void)!) {
		
		URLSession.shared.dataTask(with: URL(string: "https://itunes.apple.com/lookup?id=\(String(artistID))&media=music&entity=album")!) { (data, response, error) in
			guard error == nil else {
				completion(nil, error)
				return
			}
			
			guard let results = self.parse(data!) else {
				completion(nil, nil)
				return
			}
			
			let releases = results.filter({ (result) -> Bool in
				return result["wrapperType"] as? String == "collection"
			})
			
			completion(releases, nil)
			}.resume()
	}
}
