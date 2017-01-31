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
	case artistSearchUnavailable, additionalArtistInfoUnavailable, artistReleasesUnavailable, artistArtworkUnavailable, sunriseSunsetUnavailable
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
	func search(for artist: String, completion: @escaping ((_ response: [Artist]?, _ error: Error?) -> Void)) {
		
		let parsedArtistName = artist.replacingOccurrences(of: " ", with: "+").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
		
		// create URL for data request
		guard let url = URL(string: "\(self.itunesSearchURL)?term=\(parsedArtistName)&media=music&entity=musicArtist&attributeType=aritstTerm") else {
			completion(nil, RequestManagerError.artistSearchUnavailable)
			return
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
				
				let parsedToArtists = actualResults.map({ (artist) -> Artist in
					return Artist(
						itunesID: artist["artistId"] as! Int,
						name: artist["artistName"] as! String,
						itunesURL: URL(string: artist["artistLinkUrl"] as! String),
						summary: nil,
						genre: artist["primaryGenreName"] as? String,
						artworkURLs: nil,
						releases: nil
					)
				})
				
				// trigger completion handler
				completion(parsedToArtists, nil)
				
			} catch _ {
			
				// trigger completion handler
				completion(nil, RequestManagerError.artistSearchUnavailable)
				
			}
			
		})

		task.resume()
	}
	func getAdditionalInfo(for artist: Artist, completion: @escaping ((_ completedArtist: Artist?, _ error: Error?) -> Void)) {
		
		let parsedArtistName = artist.name!.replacingOccurrences(of: " ", with: "+").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
		
		guard let url = URL(string: "\(self.lastFMLookupURL)?method=artist.getinfo&artist=\(parsedArtistName)&api_key=\(self.lastFMAPIKey)&format=json") else {
			completion(nil, RequestManagerError.additionalArtistInfoUnavailable)
			return
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
				
				guard let artistImages = artistInfo["image"] as? [[String: Any]] else {
					completion(nil, RequestManagerError.additionalArtistInfoUnavailable)
					return
				}
				
				// construct array
				var artistArtworkURLs: [ArtworkSize: URL] = [:]
				artistImages.forEach({ (current) in
					let url = current["#text"] as! String
					switch current["size"] as! String {
					case "small": artistArtworkURLs[.small] = URL(string: url)!
						break
					case "medium": artistArtworkURLs[.medium] = URL(string: url)!
						break
					case "large": artistArtworkURLs[.large] = URL(string: url)!
						break
					case "extralarge": artistArtworkURLs[.extraLarge] = URL(string: url)!
						break
					case "mega": artistArtworkURLs[.mega] = URL(string: url)!
						break
					default: artistArtworkURLs[.thumbnail] = URL(string: url)!
					}
				})
				
				artist.artworkURLs = artistArtworkURLs
				artist.summary = (artistInfo["bio"] as? [String: Any])?["content"] as? String
				
				// trigger completion handler
				completion(artist, nil)
				
			} catch let error {
				
				completion(nil, error)
			}
		})
		
		task.resume()
		
	}
	func getReleases(for artist: Artist, since date: Date?=nil, completion: @escaping ((_ releases: [Release]?, _ error: Error?) -> Void)) {

		// create URL for data request
		guard let url = URL(string: "\(self.itunesLookupURL)?id=\(artist.itunesID!)&media=music&entity=album&attribute=albumTerm&sort=recent") else {
			completion(nil, RequestManagerError.artistReleasesUnavailable)
			return
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
				
				let finalResults = Array(intermediateResults[1..<intermediateResults.count])
				let dateFormatter = DateFormatter()
				dateFormatter.dateFormat = "YYYY-MM-dd"
				
				let releases = finalResults.map({ ( result ) -> Release in
					
					let itunesID = result["collectionId"] as! Int
					let title = result["collectionName"] as! String
					let releaseDate = dateFormatter.date(from: (result["releaseDate"] as! String).components(separatedBy: "T")[0])
					let genre = result["primaryGenreName"] as? String
					let itunesURL = URL(string: result["collectionViewUrl"] as! String)
					let artworkURL = URL(string: (result["artworkUrl100"] as! String).replacingOccurrences(of: "100x100bb", with: "1000x1000"))
					let thumbnailURL = URL(string: (result["artworkUrl100"] as! String).replacingOccurrences(of: "100x100bb", with: "132x132"))
					let release = Release(
						itunesID: itunesID,
						title: title,
						releaseDate: releaseDate,
						summary: nil,
						genre: genre,
						itunesURL: itunesURL,
						artworkURL: artworkURL,
						thumbnailURL: thumbnailURL
					)
					
					return release
				})
				
				
				// trigger completion handler
				if date != nil {
					completion(releases.filter({ (release) -> Bool in
						return release.releaseDate >= date!
					}), nil)
				} else {
					completion(releases, nil)
				}
				
			} catch _ {
				
				// trigger completion handler
				completion(nil, RequestManagerError.artistReleasesUnavailable)
				
			}
		})
		
		task.resume()
	}
	func getArtworkURLs(for artist: Artist, completion: @escaping ((_ response: [ArtworkSize: URL]?, _ error: Error?) -> Void)) {
		
		guard let url = URL(string: "\(self.lastFMLookupURL)?method=artist.getinfo&artist=\(artist.name.replacingOccurrences(of: " ", with: "+"))&api_key=\(self.lastFMAPIKey)&format=json") else {
			completion(nil, RequestManagerError.artistArtworkUnavailable)
			return
		}
		
		let task = self.session.dataTask(with: url, completionHandler: { (data, response, error) in
			
			guard let data = data, error == nil else {
				completion(nil, RequestManagerError.artistArtworkUnavailable)
				return
				
			}
			
			do {
				
				// convert data into dictionary
				let results = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
				
				guard let artistObject = results?["artist"] as? [String: Any],
					let artistImages = artistObject["image"] as? [[String: Any]] else {
					completion(nil, RequestManagerError.artistArtworkUnavailable)
					return
				}
				
				var artistArtworkURLs: [ArtworkSize: URL] = [:]
				
				artistImages.forEach({ (current) in
					let url = current["#text"] as! String
					switch current["size"] as! String {
					case "small": artistArtworkURLs[.small] = URL(string: url)!
						break
					case "medium": artistArtworkURLs[.medium] = URL(string: url)!
						break
					case "large": artistArtworkURLs[.large] = URL(string: url)!
						break
					case "extralarge": artistArtworkURLs[.extraLarge] = URL(string: url)!
						break
					case "mega": artistArtworkURLs[.mega] = URL(string: url)!
						break
					default: artistArtworkURLs[.thumbnail] = URL(string: url)!
					}
				})
				
				// trigger completion handler
				completion(artistArtworkURLs, nil)
				
			} catch _ {
				
				// trigger completion handler
				completion(nil, RequestManagerError.artistArtworkUnavailable)
			}
		})
		
		task.resume()
	
	}
	func loadImage(from url: URL, completion: @escaping ((_ image: UIImage?, _ error: Error?) -> Void)) {
		
		let task = self.session.dataTask(with: url) { (data, response, error) in
			
			guard let data = data, let image = UIImage(data: data), error == nil else {
				completion(nil, error)
				return
			}
			
			completion(image, nil)
		}
		
		task.resume()
	}
	func getSunriseAndSunset(for date: Date?=nil, completion: @escaping ((_ sunrise: Date?, _ sunset: Date?, _ error: Error?) -> Void)) {
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-DD"
		let dateString = dateFormatter.string(from: date ?? Date())
		
		DispatchQueue.main.async {
			
			self.locationManager = CLLocationManager()
			
			if CLLocationManager.authorizationStatus() != .authorizedWhenInUse && CLLocationManager.authorizationStatus() != .authorizedAlways {
				self.locationManager?.requestWhenInUseAuthorization()
				self.locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
			} else {
				
				completion(nil, nil, RequestManagerError.sunriseSunsetUnavailable)
				return
			}
			
			guard let latitude = self.locationManager?.location?.coordinate.latitude,
				let longitude = self.locationManager?.location?.coordinate.longitude else {
					completion(nil, nil, RequestManagerError.sunriseSunsetUnavailable)
					return
			}
			
			self.locationManager?.stopUpdatingLocation()
			
			DispatchQueue.global().async {
				
				guard let url = URL(string: "\(self.sunriseSunsetURL)?lat=\(latitude)&lng=\(longitude)&date=\(dateString)") else {
					completion(nil, nil, RequestManagerError.sunriseSunsetUnavailable)
					return
				}
				
				let task = self.session.dataTask(with: url) { (data, response, error) in
					
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
				
				task.resume()
			}
		}
	}
}
