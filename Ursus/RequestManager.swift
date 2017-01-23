//
//  RequestManager.swift
//  Ursus
//
//  Created by Jeffery Jackson Jr. on 4/17/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit
import CoreLocation

enum RequestManagerSource {
	case iTunes, LastFM
}

class RequestManager: NSObject, URLSessionDataDelegate {
	
	// Variables
	static let shared = RequestManager()
	
	private let locationManager = CLLocationManager()
	private let itunesSearchURL = "https://itunes.apple.com/search"
	private let itunesLookupURL = "https://itunes.apple.com/lookup"
	private let lastFMLookupURL = "https://ws.audioscrobbler.com/2.0/"
	private let lastFMAPIKey = "687a8d27b6f084256bd9b16f52ead6b1"
	
	private let sunriseSunsetURL = "http://api.sunrise-sunset.org/json"

	private let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
    	
	// MARK: Initialization

	
	
	
	
	// MARK: Methods
	func search(for artist: String, on source: RequestManagerSource, completion: @escaping ((_ response: [Any]?, _ error: NSError?) -> Void)) {
		
		let parsedArtist = artist.replacingOccurrences(of: " ", with: "+").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
		
		switch source {
			
		case .iTunes:
			
			// create URL for data request
			if let url = URL(string: "\(self.itunesSearchURL)?term=\(parsedArtist)&media=music&entity=musicArtist&attributeType=aritstTerm") {
				
				let task = self.session.dataTask(with: url, completionHandler: { (data, response, error) in
					
					if error != nil {
						
						print(error!.localizedDescription)
						
                        completion(nil, error as? NSError)
						
					} else {
						
						do {
							
							// convert data into dictionary
							if let results = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any] {
								
								// trigger completion handler
								completion(results["results"] as? [Any], nil)
								
							}
							
						} catch _ {
							
							// trigger completion handler
							completion(nil, nil)
							
						}
					}
					
				})
				
				task.resume()
				
			}
			
			else {
				
				completion(nil, nil);
			}
			
			break
			
		case .LastFM:
			
			if let url = URL(string: "\(self.lastFMLookupURL)?method=artist.getinfo&artist=\(parsedArtist)&api_key=\(self.lastFMAPIKey)&format=json") {
				
				let task = self.session.dataTask(with: url, completionHandler: { (data, response, error) in
					
					if error != nil {
						
						print(error!.localizedDescription)
                        
                        completion(nil, error as? NSError)
                        
                        						
					} else {
						
						do {
							
							// convert data into dictionary
							if let results = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any] {
								
								if let artistObject = results["artist"] as? [String: Any] {
									
									// trigger completion handler
									completion([artistObject], nil)
								}
							}
							
						} catch _ {
							
							// trigger completion handler
							completion(nil, nil)
						}
					}
				})
				
				task.resume()
				
			} else {
				
				// trigger completion handler
				completion(nil, nil)
			}
			
			break
			
		}
		
	}
	func getReleases(for artistID: Int, since date: Date?=nil, completion: @escaping ((_ releases: [Release], _ error: NSError?) -> Void)) {
		
		// create URL for data request
		if let url = URL(string: "\(self.itunesLookupURL)?id=\(artistID)&media=music&entity=album&attribute=albumTerm&sort=recent") {
			
			let task = self.session.dataTask(with: url, completionHandler: { (data, response, error) in
				
				if error != nil {
					
					print(error!.localizedDescription)
                    
                    completion([], error as? NSError)
					
				} else {
					
					do {
						
						// convert data into dictionary
						let dataObject = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String : Any]
						
						let initialResults = dataObject!["results"] as! [[String : Any]]
						let count = initialResults.count
						let results = Array(initialResults[1..<count])
						
						let dateFormatter = DateFormatter()
						dateFormatter.dateFormat = "YYYY-MM-dd"
						
						let releases = results.map({ ( result ) -> Release in
							
							let itunesID = result["collectionId"] as! Int
							let title = result["collectionName"] as! String
							let releaseDate = dateFormatter.date(from: (result["releaseDate"] as! String).components(separatedBy: "T")[0])
							let genre = result["primaryGenreName"] as? String
							let itunesURL = URL(string: result["collectionViewUrl"] as! String)
							let artworkURL = URL(string: (result["artworkUrl100"] as! String).replacingOccurrences(of: "100x100bb", with: "1000x1000"))
							let thumbnailURL = URL(string: (result["artworkUrl100"] as! String).replacingOccurrences(of: "100x100bb", with: "200x200"))
							let release = Release(
								itunesID: itunesID,
								title: title,
								releaseDate: releaseDate,
								summary: nil,
								genre: genre,
								itunesURL: itunesURL,
								artworkURL: artworkURL,
								thumbnailURL: thumbnailURL,
								seenByUser: true
							)
							
							return release
						})
						
						
						// trigger completion handler
						completion(releases.filter({ (release) -> Bool in
							return release.releaseDate >= date!
						}), nil)
						
					} catch _ {
						
						// trigger completion handler
						completion([], nil)
						
					}
				}
				
			})
			
			task.resume()
		}
	}
	func getArtworkURLs(for artist: String, completion: @escaping ((_ response: [URL]?, _ error: NSError?) -> Void)) {
        
		let parsedArtist = artist.replacingOccurrences(of: " ", with: "+").trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
		
		if let url = URL(string: "\(self.lastFMLookupURL)?method=artist.getinfo&artist=\(parsedArtist)&api_key=\(self.lastFMAPIKey)&format=json") {
			
			let task = self.session.dataTask(with: url, completionHandler: { (data, response, error) in
				
				if error != nil {
					
					print(error!.localizedDescription)
                    
                    completion(nil, error as? NSError)
                    
					
				} else {
					
					do {
						
						// convert data into dictionary
						if let results = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: Any] {
							
							if let artistObject = results["artist"] as? [String: Any] {
								
								if let artistImages = artistObject["image"] as? [[String: Any]] {
									
									// construct array
									let urlArray: [URL] = artistImages.flatMap({ (current) -> URL? in
										return URL(string: (current["#text"] as! String))
									})
									
									// trigger completion handler
									completion(urlArray, nil)
								}
							}
						}
												
					} catch _ {
						
						// trigger completion handler
						completion(nil, nil)
					}
				}
			})
			
			task.resume()
			
		} else {
			
			// trigger completion handler
			completion(nil, nil)
		}
	}
	func loadImage(from url: URL, completion: @escaping ((_ image: UIImage?, _ error: NSError?) -> Void)) {
		
		let task = self.session.dataTask(with: url) { (data, response, error) in
			
			guard let data = data, error == nil else {
				
				print(error!.localizedDescription)
                
				completion(nil, error as? NSError)
                
                return
			}
			
			if let image = UIImage(data: data) {
				
				completion(image, nil)
			}
		}
		
		task.resume()
	}
	func getSunriseAndSunset(for date: Date?=nil, completion: @escaping ((_ sunrise: Date?, _ sunset: Date?, _ error: NSError?) -> Void)) {
		
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "YYYY-MM-DD"
//		dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
		let dateString = dateFormatter.string(from: date ?? Date())
		
		if CLLocationManager.authorizationStatus() != .authorizedWhenInUse && CLLocationManager.authorizationStatus() != .authorizedAlways {
			locationManager.requestWhenInUseAuthorization()
			locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
		}
		
		if let latitude = locationManager.location?.coordinate.latitude,
			let longitude = locationManager.location?.coordinate.longitude {
			
			if let url = URL(string: "\(self.sunriseSunsetURL)?lat=\(latitude)&lng=\(longitude)&date=\(dateString)") {
				
				let task = self.session.dataTask(with: url) { (data, response, error) in
					
					guard let data = data, error == nil else {
						
						print(error!.localizedDescription)
						
						completion(nil, nil, error as? NSError)
						
						return
					}
					
					do {
						
						if let results = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
							
							if results["status"] as? String == "OK" {
								
								var actualResults = results["results"] as! [String: Any]
								if var sunriseString = actualResults["sunrise"] as? String, var sunsetString = actualResults["sunset"] as? String {
									dateFormatter.dateFormat = "YYYY-MM-DD'T'h:mm:ss a"
									dateFormatter.timeZone = TimeZone(abbreviation: "UTC")

									guard var sunrise = dateFormatter.date(from: "\(dateString)T\(sunriseString)"), var sunset = dateFormatter.date(from: "\(dateString)T\(sunsetString)") else {
										completion(nil, nil, nil)
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
							} else {
								completion(nil, nil, nil)
							}
						}
					} catch _ {
						
						// trigger completion handler
						completion(nil, nil, nil)
					}
					
				}
				
				task.resume()
			} else {
				completion(nil, nil, nil)
			}
		}
		
		
	}
	
}
