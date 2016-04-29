//
//  RequestManager.swift
//  Ursus
//
//  Created by Jeffery Jackson Jr. on 4/17/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class RequestManager: NSObject, NSURLSessionDataDelegate {
	
	// Variables
	static let defaultManager = RequestManager()
	
	private let searchURL = "https://itunes.apple.com/search"
	private let lookupURL = "https://itunes.apple.com/lookup"

	private let session = NSURLSession(configuration: .defaultSessionConfiguration(), delegate: defaultManager, delegateQueue: nil)
	
	
	// MARK: Initialization
	override init() {
		
		super.init()
		
	}
	
	
	// MARK: Methods
	func searchForArtist(artist: String, completion: ((response: NSArray?, error: NSError?) -> Void)) {
		
		print("Trying harder...")
		// create URL for data request
		if let url = NSURL(string: "\(searchURL)?term=\(artist)&media=music&entity=musicArtist&attribute=aritstTerm") {
			
			let task = session.dataTaskWithURL(url, completionHandler: { (data, response, error) in
				
				if error != nil {
					
					print(error!.localizedDescription)
					
				} else {
					
					do {
						
						// convert data into array
						let results = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers)
						
						// trigger completion handler
						completion(response: results as? NSArray, error: nil)
						
					} catch _ {
						
						// trigger completion handler
						completion(response: nil, error: /* TODO: need to create error here */ nil)
						
					}
				}
				
			})
			
			task.resume()

		}
	}
	
}
