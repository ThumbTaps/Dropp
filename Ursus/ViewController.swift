//
//  ViewController.swift
//  Ursus
//
//  Created by Jeffery Jackson Jr. on 4/17/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		
		print("Trying...")
		RequestManager.defaultManager.searchForArtist("Kendrick Lamar") { (response, error) in
			
			print(response)
		}
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

}

