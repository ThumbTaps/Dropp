//
//  DroppStoryboardSegue.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 12/1/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class DroppStoryboardSegue: UIStoryboardSegue {
	
	private var animationController: UIViewControllerTransitioningDelegate?
	
    override func perform() {
		
		guard let parent = self.source.parent as? DroppNavigationController,
			let destinationAsDropp = self.destination as? DroppViewController else {
				return
		}
		
		parent.push(destinationAsDropp)
    }
	
}
