//
//  RequestManager.swift
//  Ursus
//
//  Created by Jeffery Jackson Jr. on 4/17/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit
import CoreLocation

enum RequestManagerError: Error {
	case artistSearchUnavailable, additionalArtistInfoUnavailable, artistReleasesUnavailable, sunriseSunsetUnavailable
}

class RequestManager: NSObject, URLSessionDataDelegate {
	
	// Variables
	static let shared = RequestManager()
	
	private let itunesSearchURL = "https://itunes.apple.com/search"
	private let itunesLookupURL = "https://itunes.apple.com/lookup"
	private let lastFMLookupURL = "https://ws.audioscrobbler.com/2.0/"
	private let lastFMAPIKey = "687a8d27b6f084256bd9b16f52ead6b1"
	
	private let sunriseSunsetURL = "http://api.sunrise-sunset.org/json"

	private let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
	private var locationManager: CLLocationManager?
    	
	
	// MARK: Methods
	func search(for artist: String, completion: @escaping ((_ response: [Artist]?, _ error: Error?) -> Void)) -> URLSessionDataTask? {
		
		let parsedArtistName = artist.replacingOccurrences(of: " ", with: "+").trimmingCharacters(in: .whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)?.lowercased()
		
		// create URL for data request
		guard let url = URL(string: "\(self.itunesSearchURL)?term=\(parsedArtistName!)&media=music&entity=musicArtist&attribute=artistTerm&limit=10") else {
			completion(nil, RequestManagerError.artistSearchUnavailable)
			return nil
		}
		
		let task = self.session.dataTask(with: url, completionHandler: { (data, response, error) in
			
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
				
			} catch _ {
			
				// trigger completion handler
				completion(nil, RequestManagerError.artistSearchUnavailable)
				
			}
			
		})

		task.resume()
		return task
	}
	func getAdditionalInfo(for artist: Artist, completion: @escaping ((_ completedArtist: Artist?, _ error: Error?) -> Void)) -> URLSessionDataTask? {
		
		let parsedArtistName = artist.name.replacingOccurrences(of: " ", with: "+").trimmingCharacters(in: .whitespacesAndNewlines).addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)?.lowercased()
		
		guard let url = URL(string: "\(self.lastFMLookupURL)?method=artist.getinfo&artist=\(parsedArtistName!)&api_key=\(self.lastFMAPIKey)&format=json") else {
			completion(nil, RequestManagerError.additionalArtistInfoUnavailable)
			return nil
		}
		
		let task = self.session.dataTask(with: url, completionHandler: { (data, response, error) in
			
			guard let data = data, error == nil else {
				completion(nil, RequestManagerError.additionalArtistInfoUnavailable)
				return
			}
			
			do {
				
				// convert data into dictionary
				let results = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
				
				guard let artistInfo = results?["artist"] as? [String: Any] else {
					completion(nil, RequestManagerError.additionalArtistInfoUnavailable)
					return
				}
								
				if let summary = (artistInfo["bio"] as? [String: Any])?["content"] as? String {
					if !summary.isEmpty {
						artist.summary = summary
					}
				}
				
				guard let artistImages = artistInfo["image"] as? [[String: Any]] else {
					completion(nil, RequestManagerError.additionalArtistInfoUnavailable)
					return
				}
				
				// construct array
				var artistArtworkURLs: [ArtworkSize: URL] = [:]
				artistImages.forEach({ (current) in
					
					if let urlString = current["#text"] as? String {
						
						if let currentSize = current["size"] as? String {
							
							switch currentSize {
							case "small": artistArtworkURLs[.small] = URL(string: urlString)
								break
							case "medium": artistArtworkURLs[.medium] = URL(string: urlString)
								break
							case "large": artistArtworkURLs[.large] = URL(string: urlString)
								break
							case "extralarge": artistArtworkURLs[.extraLarge] = URL(string: urlString)
								break
							case "mega": artistArtworkURLs[.mega] = URL(string: urlString)
								break
							default: artistArtworkURLs[.thumbnail] = URL(string: urlString)
							}
						}
					}
				})
				
				artist.artworkURLs = artistArtworkURLs
				
				// trigger completion handler
				completion(artist, nil)
				
			} catch let error {
				
				completion(nil, error)
			}
		})
		
		task.resume()
		return task
		
	}
	func getReleases(for artist: Artist, since date: Date?=nil, completion: @escaping ((_ releases: [Release]?, _ error: Error?) -> Void)) -> URLSessionDataTask? {

		// create URL for data request
		guard let url = URL(string: "\(self.itunesLookupURL)?id=\(artist.itunesID!)&media=music&entity=album&attribute=artistTerm&sort=recent") else {
			completion(nil, RequestManagerError.artistReleasesUnavailable)
			return nil
		}
		
		let task = self.session.dataTask(with: url, completionHandler: { (data, response, error) in
			
			guard let data = data, error == nil else {
				completion(nil, RequestManagerError.artistReleasesUnavailable)
				return
			}
			
			do {

				// convert data into dictionary
				let initialResults = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
				
				guard let intermediateResults = initialResults!["results"] as? [[String : Any]] else {
					completion(nil, RequestManagerError.artistReleasesUnavailable)
					return
				}
				
				var finalResults = Array(intermediateResults[1..<intermediateResults.count])
				finalResults = finalResults.filter({ (result) -> Bool in
					
					guard let explicitness = result["collectionExplicitness"] as? String else {
						return false
					}
					
					return explicitness != "cleaned"
				})

				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "YYYY-MM-dd"
				
				let releases = finalResults.map({ ( parsedRelease ) -> Release? in
					
					guard let itunesID = parsedRelease["collectionId"] as? Int,
						let title = parsedRelease["collectionName"] as? String,
						let releaseDateString = parsedRelease["releaseDate"] as? String,
						let itunesURLString = parsedRelease["collectionViewUrl"] as? String else {
							return nil
					}
					
					let releaseDate = dateFormatter.date(from: releaseDateString.components(separatedBy: "T")[0])
					let release = Release(itunesID: itunesID, title: title, releaseDate: releaseDate, itunesURL: URL(string: itunesURLString))
					
					if let genre = parsedRelease["primaryGenreName"] as? String {
						release.genre = genre
					}
					
					if let artworkURLString = parsedRelease["artworkUrl100"] as? String {
						release.artworkURL = URL(string: artworkURLString.replacingOccurrences(of: "100x100bb", with: "1000x1000"))
					}
					
					if let thumbnailURLString = parsedRelease["artworkUrl100"] as? String {
						release.thumbnailURL = URL(string: thumbnailURLString.replacingOccurrences(of: "100x100bb", with: "132x132"))
					}
					
					if let trackCount = parsedRelease["trackCount"] as? Int {
						release.trackCount = trackCount
					}
					
					release.isFeature = (parsedRelease["artistId"] as? Int) != artist.itunesID
					
					return release
				})
				
				
				// trigger completion handler
				if date != nil {
					completion(releases.filter({ (release) -> Bool in
						return release != nil && release!.releaseDate >= date!
					}) as? [Release], nil)
				} else {
					completion(releases.filter({ $0 != nil }) as? [Release], nil)
				}
				
			} catch _ {
				
				// trigger completion handler
				completion(nil, RequestManagerError.artistReleasesUnavailable)
				
			}
		})
		
		task.resume()
		return task
	}	
	func loadImage(from url: URL, completion: @escaping ((_ image: UIImage?, _ error: Error?) -> Void)) -> URLSessionDataTask? {
		
		let task = self.session.dataTask(with: url) { (data, response, error) in

			guard let data = data, let image = UIImage(data: data), error == nil else {
				completion(nil, error)
				return
			}
			
			completion(image, nil)
		}
		
		task.resume()
		return task
	}
	func getSunriseAndSunset(for date: Date?=nil, completion: @escaping ((_ sunrise: Date?, _ sunset: Date?, _ error: Error?) -> Void)) -> URLSessionDataTask? {
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-DD"
		let dateString = dateFormatter.string(from: date ?? Date())
		var task: URLSessionDataTask?
		
		DispatchQueue.main.async {
			
			self.locationManager = CLLocationManager()
			print(CLLocationManager.authorizationStatus())
			if CLLocationManager.authorizationStatus() != .authorizedWhenInUse && CLLocationManager.authorizationStatus() != .authorizedAlways {
				self.locationManager?.requestWhenInUseAuthorization()
				self.locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
			} else {
				print("Couldn't get sunrise and sunset because location services are not enabled.")
				completion(nil, nil, RequestManagerError.sunriseSunsetUnavailable)
				return
			}
			
			guard let latitude = self.locationManager?.location?.coordinate.latitude,
				let longitude = self.locationManager?.location?.coordinate.longitude else {
					print("Couldn't get sunrise and sunset because the user's location could not be determined.")
					completion(nil, nil, RequestManagerError.sunriseSunsetUnavailable)
					return
			}
			
			self.locationManager?.stopUpdatingLocation()
			
			DispatchQueue.global().async {
				
				guard let url = URL(string: "\(self.sunriseSunsetURL)?lat=\(latitude)&lng=\(longitude)&date=\(dateString)") else {
					completion(nil, nil, RequestManagerError.sunriseSunsetUnavailable)
					return
				}
				
				task = self.session.dataTask(with: url) { (data, response, error) in
					
					guard let data = data, error == nil else {
						completion(nil, nil, RequestManagerError.sunriseSunsetUnavailable)
						return
					}
					
					do {
						
						let results = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
						
						guard let status = results?["status"] as? String else {
							completion(nil, nil, RequestManagerError.sunriseSunsetUnavailable)
							return
						}
						
						if status == "OK" {
							
							guard var actualResults = results?["results"] as? [String: Any],
								var sunriseString = actualResults["sunrise"] as? String,
								var sunsetString = actualResults["sunset"] as? String else {
									completion(nil, nil, RequestManagerError.sunriseSunsetUnavailable)
									return
							}
							
							dateFormatter.dateFormat = "YYYY-MM-DD'T'h:mm:ss a"
							dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
							
							guard var sunrise = dateFormatter.date(from: "\(dateString)T\(sunriseString)"),
								var sunset = dateFormatter.date(from: "\(dateString)T\(sunsetString)") else {
									completion(nil, nil, RequestManagerError.sunriseSunsetUnavailable)
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
						completion(nil, nil, RequestManagerError.sunriseSunsetUnavailable)
					}
					
				}
				
				task?.resume()
			}
		}
		
		return task
	}
}
