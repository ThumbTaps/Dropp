//
//  RequestManager.swift
//  Dropp
//
//  Created by Jeffery Jackson Jr. on 4/17/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit
import CoreLocation

enum RequestManagerError: Error {
	case
	artistLookup_Unavailable,
	artistLookup_NotFound,
	
	artistSearchUnavailable,
	artistSearch_NoResults,
	
	additionalArtistInfo_Unavailable,
	
	artistReleases_Unavailable,
	
	releaseTracks_Unavailable,
	
	sunriseSunset_Unavailable
}

class RequestManager: NSObject {
	
	// Variables
	static let shared = RequestManager()
	
	private let itunesSearchURL = "https://itunes.apple.com/search"
	private let itunesLookupURL = "https://itunes.apple.com/lookup"
	private let lastFMLookupURL = "https://ws.audioscrobbler.com/2.0/"
	private let lastFMAPIKey = "687a8d27b6f084256bd9b16f52ead6b1"
	
	private let sunriseSunsetURL = "http://api.sunrise-sunset.org/json"
	
	private var session: URLSession! = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
	private var locationManager: CLLocationManager?
	
	// MARK: Methods
	func lookup(artist itunesID: Int, completion: @escaping ((_ response: Artist?, _ error: Error?) -> Void)) -> URLSessionDataTask? {
		
		// create URL for data request
		guard let url = URL(string: "\(self.itunesLookupURL)?id=\(itunesID)&media=music") else {
			completion(nil, RequestManagerError.artistLookup_Unavailable)
			return nil
		}
		
		DispatchQueue.main.async {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
		}
		let task = self.session.dataTask(with: url) { (data, response, error) in
			DispatchQueue.main.async {
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
			}
			
			guard let data = data, error == nil else {
				completion(nil, RequestManagerError.artistLookup_Unavailable)
				return
			}
			
			do {
				
				// convert data into dictionary
				let results = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
				
				guard let actualResults = results?["results"] as? [[String: Any]] else {
					completion(nil, RequestManagerError.artistLookup_Unavailable)
					return
				}
				
				if actualResults.isEmpty {
					completion(nil, RequestManagerError.artistLookup_NotFound)
					return
				} else {
					
					let parsedArtist: [String: Any] = actualResults[0]
					
					guard let itunesID = parsedArtist["artistId"] as? Int,
						let name = parsedArtist["artistName"] as? String,
						let itunesURLString = parsedArtist["artistLinkUrl"] as? String else {
							
							completion(nil, RequestManagerError.artistLookup_Unavailable)
							return
					}
					
					let artist = Artist(itunesID: itunesID, name: name, itunesURL: URL(string: itunesURLString))
					
					artist.genre = parsedArtist["primaryGenreName"] as? String
					
					// trigger completion handler
					completion(artist, nil)
				}
				
			} catch _ {
				
				// trigger completion handler
				completion(nil, RequestManagerError.artistLookup_Unavailable)
				
			}
		}
		
		return task
	}
	func search(for artist: String, completion: @escaping ((_ response: [Artist]?, _ error: Error?) -> Void)) -> URLSessionDataTask? {
		
		let parsedArtistName = artist.replacingOccurrences(of: " ", with: "+").replacingOccurrences(of: "&", with: "and").trimmingCharacters(in: .whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)?.lowercased()
		
		// create URL for data request
		guard let url = URL(string: "\(self.itunesSearchURL)?term=\(parsedArtistName!)&media=music&entity=musicArtist&attribute=artistTerm&limit=10") else {
			completion(nil, RequestManagerError.artistSearchUnavailable)
			return nil
		}
		
		DispatchQueue.main.async {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
		}
		let task = self.session.dataTask(with: url) { (data, response, error) in
			DispatchQueue.main.async {
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
			}
			
			guard let data = data, error == nil else {
				completion(nil, RequestManagerError.artistSearchUnavailable)
				return
			}
			
			do {
				
				// convert data into dictionary
				let results = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
				
				guard let actualResults = results?["results"] as? [[String: Any]] else {
					completion(nil, RequestManagerError.artistSearchUnavailable)
					return
				}
				
				if actualResults.isEmpty {
					completion(nil, RequestManagerError.artistSearch_NoResults)
					return
				} else {
					
					let parsedToArtists = actualResults.map({ (parsedArtist) -> Artist? in
						
						let itunesID = parsedArtist["artistId"] as? Int
						let name = parsedArtist["artistName"] as? String
						let itunesURLString = parsedArtist["artistLinkUrl"] as? String
						let artist = Artist(itunesID: itunesID, name: name, itunesURL: URL(string: itunesURLString!))
						artist.genre = parsedArtist["primaryGenreName"] as? String
						
						return artist
					})
					
					// trigger completion handler
					completion(parsedToArtists.filter({ $0 != nil }) as? [Artist], nil)
					
				}
				
			} catch _ {
				
				// trigger completion handler
				completion(nil, RequestManagerError.artistSearchUnavailable)
				
			}
			
		}
		
		return task
	}
	func getAdditionalInfo(for artist: Artist, completion: @escaping ((_ completedArtist: Artist?, _ error: Error?) -> Void)) -> URLSessionDataTask? {
		
		let parsedArtistName = artist.name.replacingOccurrences(of: " ", with: "+").replacingOccurrences(of: "&", with: "and").trimmingCharacters(in: .whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)?.lowercased()
		
		guard let url = URL(string: "\(self.lastFMLookupURL)?method=artist.getinfo&artist=\(parsedArtistName!)&api_key=\(self.lastFMAPIKey)&format=json") else {
			completion(nil, RequestManagerError.additionalArtistInfo_Unavailable)
			return nil
		}
		
		DispatchQueue.main.async {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
		}
		let task = self.session.dataTask(with: url) { (data, response, error) in
			DispatchQueue.main.sync {
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
			}
			
			guard let data = data, error == nil else {
				completion(nil, RequestManagerError.additionalArtistInfo_Unavailable)
				return
			}
			
			do {
				
				// convert data into dictionary
				let results = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
				
				// extract artist info
				guard let artistInfo = results?["artist"] as? [String: Any] else {
					completion(nil, RequestManagerError.additionalArtistInfo_Unavailable)
					return
				}
				
				// get summary if possible
				if let summary = (artistInfo["bio"] as? [String: Any])?["content"] as? String {
					if !summary.isEmpty {
						artist.summary = summary
					}
				}
				
				// extract artist image URLs
				guard let artistImages = artistInfo["image"] as? [[String: Any]] else {
					completion(nil, RequestManagerError.additionalArtistInfo_Unavailable)
					return
				}
				
				
				// construct artwork URLs array
				artistImages.forEach({ (current) in
					
					if let urlString = current["#text"] as? String {
						
						if let currentSize = current["size"] as? String {
							
							if currentSize == "mega" {
								artist.artworkURL = URL(string: urlString)
							}
						}
					}
				})
				
				// trigger completion handler
				completion(artist, nil)
				
			} catch let error {
				
				completion(nil, error)
			}
		}
		
		return task
		
	}
	func getReleases(for artist: Artist, since date: Date?=nil, completion: @escaping ((_ releases: [Release]?, _ error: Error?) -> Void)) -> URLSessionDataTask? {
		
		// create URL for data request
		guard let url = URL(string: "\(self.itunesLookupURL)?id=\(artist.itunesID!)&media=music&entity=album&attribute=artistTerm&sort=recent") else {
			completion(nil, RequestManagerError.artistReleases_Unavailable)
			return nil
		}
		
		DispatchQueue.main.async {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
		}
		let task = self.session.dataTask(with: url) { (data, response, error) in
			DispatchQueue.main.async {
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
			}
			
			guard let data = data, error == nil else {
				completion(nil, RequestManagerError.artistReleases_Unavailable)
				return
			}
			
			do {
				
				// convert data into dictionary
				let initialResults = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
				
				guard let intermediateResults = initialResults!["results"] as? [[String : Any]] else {
					completion(nil, RequestManagerError.artistReleases_Unavailable)
					return
				}
				
				var finalResults = Array(intermediateResults[1..<intermediateResults.count])
				// filter out cleaned collections
				finalResults = finalResults.filter({ (result) -> Bool in
					
					guard let explicitness = result["collectionExplicitness"] as? String else {
						return false
					}
					
					return explicitness != "cleaned"
				})
				
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "YYYY-MM-dd"
				
				let releases = finalResults.map({ ( unparsedRelease ) -> Release? in
					
					guard let itunesID = unparsedRelease["collectionId"] as? Int,
						let title = unparsedRelease["collectionName"] as? String,
						let releaseDateString = unparsedRelease["releaseDate"] as? String,
						let itunesURLString = unparsedRelease["collectionViewUrl"] as? String else {
							return nil
					}
					
					let releaseDate = dateFormatter.date(from: releaseDateString.components(separatedBy: "T")[0])
					let release = Release(itunesID: itunesID, title: title, releaseDate: releaseDate, itunesURL: URL(string: itunesURLString))
					
					release.genre = unparsedRelease["primaryGenreName"] as? String
					
					if let artworkURLString = unparsedRelease["artworkUrl100"] as? String {
						release.artworkURL = URL(string: artworkURLString.replacingOccurrences(of: "100x100bb", with: "\(Int(PreferenceManager.shared.artworkSize.width))x\(Int(PreferenceManager.shared.artworkSize.height))"))
					}
					
					release.isFeature = (unparsedRelease["artistId"] as? Int) != artist.itunesID
					release.artist = artist
					
					return release
				})
					// filter out failed parses
					.filter({ (release) -> Bool in
						return release != nil
					})
				
				
				// trigger completion handler
				if date != nil {
					// pass off only releases after the specified date
					completion(releases.filter({ (release) -> Bool in
						return release!.releaseDate >= date!
					}) as? [Release], nil)
				} else {
					// pass off only valid releases
					completion(releases as? [Release], nil)
				}
				
			} catch _ {
				
				// trigger completion handler
				completion(nil, RequestManagerError.artistReleases_Unavailable)
				
			}
		}
		
		return task
	}
	func getTracks(for release: Release, completion: @escaping ((_ tracks: [Track]?, _ error: Error?) -> Void)) -> URLSessionDataTask? {
		
		// create URL for data request
		guard let url = URL(string: "\(self.itunesLookupURL)?id=\(release.itunesID!)&media=music&entity=song&attribute=albumTerm") else {
			completion(nil, RequestManagerError.artistReleases_Unavailable)
			return nil
		}
		
		DispatchQueue.main.async {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
		}
		let task = self.session.dataTask(with: url) { (data, response, error) in
			DispatchQueue.main.async {
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
			}
			
			guard let data = data, error == nil else {
				completion(nil, RequestManagerError.artistReleases_Unavailable)
				return
			}
			
			do {
				
				// convert data into dictionary
				let initialResults = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
				
				guard let intermediateResults = initialResults!["results"] as? [[String : Any]] else {
					completion(nil, RequestManagerError.artistReleases_Unavailable)
					return
				}
				
				let finalResults = Array(intermediateResults[1..<intermediateResults.count])
				
				let tracks = finalResults.map({ (unparsedTrack) -> Track? in
					
					guard let itunesID = unparsedTrack["trackId"] as? Int,
						let title = unparsedTrack["trackName"] as? String,
						let trackNumber = unparsedTrack["trackNumber"] as? Int,
						let itunesURLString = unparsedTrack["trackViewUrl"] as? String else {
							return nil
					}
					
					let track = Track(itunesID: itunesID, title: title, trackNumber: trackNumber, itunesURL: URL(string: itunesURLString))
					
					track.duration = unparsedTrack["trackTimeMillis"] as? Int
					track.isStreamable = unparsedTrack["isStreamable"] as? Bool
					if let previewURLString = unparsedTrack["previewURL"] as? String {
						track.previewURL = URL(string: previewURLString)
					}
					
					return track
				})
					// sort by track number
					.sorted(by: { (trackOne, trackTwo) -> Bool in
						
						return trackOne!.trackNumber > trackTwo!.trackNumber
					})
					// get rid of failed parses
					.filter({ (track) -> Bool in
						return track != nil
					})
				
				completion(tracks as? [Track], nil)
				
			} catch _ {
				
				// trigger completion handler
				completion(nil, RequestManagerError.releaseTracks_Unavailable)
			}
		}
		
		return task
	}
	func loadImage(from url: URL, completion: @escaping ((_ image: UIImage?, _ error: Error?) -> Void)) -> URLSessionDataTask? {
		
		DispatchQueue.main.async {
			UIApplication.shared.isNetworkActivityIndicatorVisible = true
		}
		
		let task = self.session.dataTask(with: url) { (data, response, error) in
			DispatchQueue.main.async {
				UIApplication.shared.isNetworkActivityIndicatorVisible = false
			}
			
			guard let data = data, let image = UIImage(data: data), error == nil else {
				completion(nil, error)
				print(error ?? "")
				return
			}
			
			completion(image, nil)
		}
		
		return task
	}
	func getSunriseAndSunset(for date: Date?=nil, completion: @escaping ((_ sunrise: Date?, _ sunset: Date?, _ error: Error?) -> Void)) -> URLSessionDataTask? {
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-DD"
		let dateString = dateFormatter.string(from: date ?? Date())
		var task: URLSessionDataTask?
		
		self.locationManager = CLLocationManager()
		
		if CLLocationManager.authorizationStatus() != .authorizedWhenInUse && CLLocationManager.authorizationStatus() != .authorizedAlways {
			self.locationManager?.requestWhenInUseAuthorization()
			self.locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
		} else {
			print("Couldn't get sunrise and sunset because location services are not enabled.")
			completion(nil, nil, RequestManagerError.sunriseSunset_Unavailable)
			return nil
		}
		
		guard let latitude = self.locationManager?.location?.coordinate.latitude,
			let longitude = self.locationManager?.location?.coordinate.longitude else {
				print("Couldn't get sunrise and sunset because the user's location could not be determined.")
				completion(nil, nil, RequestManagerError.sunriseSunset_Unavailable)
				return nil
		}
		
		self.locationManager?.stopUpdatingLocation()
		
		DispatchQueue.global().async {
			
			guard let url = URL(string: "\(self.sunriseSunsetURL)?lat=\(latitude)&lng=\(longitude)&date=\(dateString)") else {
				completion(nil, nil, RequestManagerError.sunriseSunset_Unavailable)
				return
			}
			
			DispatchQueue.main.async {
				UIApplication.shared.isNetworkActivityIndicatorVisible = true
			}
			task = self.session.dataTask(with: url) { (data, response, error) in
				DispatchQueue.main.async {
					UIApplication.shared.isNetworkActivityIndicatorVisible = false
				}
				
				guard let data = data, error == nil else {
					completion(nil, nil, RequestManagerError.sunriseSunset_Unavailable)
					return
				}
				
				do {
					
					let results = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
					
					guard let status = results?["status"] as? String else {
						completion(nil, nil, RequestManagerError.sunriseSunset_Unavailable)
						return
					}
					
					if status == "OK" {
						
						guard var actualResults = results?["results"] as? [String: Any],
							var sunriseString = actualResults["sunrise"] as? String,
							var sunsetString = actualResults["sunset"] as? String else {
								completion(nil, nil, RequestManagerError.sunriseSunset_Unavailable)
								return
						}
						
						dateFormatter.dateFormat = "YYYY-MM-DD'T'h:mm:ss a"
						dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
						
						guard var sunrise = dateFormatter.date(from: "\(dateString)T\(sunriseString)"),
							var sunset = dateFormatter.date(from: "\(dateString)T\(sunsetString)") else {
								completion(nil, nil, RequestManagerError.sunriseSunset_Unavailable)
								return
						}
						
						dateFormatter.dateFormat = "YYYY-MM-DD'T'h:mm:ss a"
						dateFormatter.timeZone = .current
						
						sunriseString = dateFormatter.string(from: sunrise)
						sunsetString = dateFormatter.string(from: sunset)
						
						sunrise = dateFormatter.date(from: sunriseString)!
						sunset = dateFormatter.date(from: sunsetString)!
						
						// trigger completion handler
						completion(sunrise, sunset, nil)
					}
				} catch _ {
					
					// trigger completion handler
					completion(nil, nil, RequestManagerError.sunriseSunset_Unavailable)
				}
				
			}
			
		}
		
		return task
	}
}
