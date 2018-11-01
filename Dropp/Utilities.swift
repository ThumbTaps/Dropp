//
//  Utilities.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 7/23/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

class Utilities {
	
	class func loadImage(imageURL: URL!, completion: ((_ image: UIImage?, _ error: Error?) -> Void)!) {
		URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
			guard error == nil else {
				completion(nil, error)
				return
			}
			
			completion(UIImage(data: data!), nil)
			}.resume()
	}
}
