//
//  UrsusStoryboardSegue.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 12/1/16.
//  Copyright © 2016 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class UrsusStoryboardSegue: UIStoryboardSegue {
	
	private var animationController: UIViewControllerTransitioningDelegate?
	
    override func perform() {
		
		if self.identifier == "NewReleases->Release" {
			self.animationController = BlurAndOverlayAnimatedTransitionController()
			self.destination.transitioningDelegate = self.animationController
			self.source.present(self.destination, animated: true)
		
		} else if self.identifier == "Release->NewReleases" {
			self.animationController = BlurAndOverlayAnimatedTransitionController()
			self.source.transitioningDelegate = self.animationController
			self.source.dismiss(animated: true)
		}
			
			
			
			
		else if self.identifier == "NewReleases->ReleaseSorting" {
			self.animationController = SlideDownAnimatedTransitionController()
			self.destination.transitioningDelegate = self.animationController
			self.source.present(self.destination, animated: true)
			
		} else if self.identifier == "ReleaseSorting->NewReleases" {
			self.animationController = SlideDownAnimatedTransitionController()
			self.source.transitioningDelegate = self.animationController
			self.source.dismiss(animated: true)
		}
			
			
			
			
		else if self.identifier == "NewReleases->Settings" {
			self.source.present(self.destination, animated: true)
			
		} else if self.identifier == "Settings->NewReleases" {
			self.source.dismiss(animated: true)
		}
			
			
			
			
		else if self.identifier == "NewReleases->Artists" {
			self.source.present(self.destination, animated: true)
			
		} else if self.identifier == "Artists->NewReleases" {
			self.source.dismiss(animated: true)
		}
			
			
			
			
			
        else if self.identifier == "NewReleases->ArtistSearch" {
			self.animationController = BlurAndOverlayAnimatedTransitionController()
			self.destination.transitioningDelegate = self.animationController
            self.source.present(self.destination, animated: true)
			
		} else if self.identifier == "ArtistSearch->NewReleases" {
			self.animationController = BlurAndOverlayAnimatedTransitionController()
			self.source.transitioningDelegate = self.animationController
			self.source.dismiss(animated: true)
		}
			
			
			
			
			
        else if self.identifier == "ArtistSearch->ArtistSearchResults" {
			self.animationController = SlideDownAnimatedTransitionController()
			self.destination.transitioningDelegate = self.animationController
            self.source.present(self.destination, animated: true)

        } else if self.identifier == "ArtistSearchResults->ArtistSearch" {
			self.animationController = SlideDownAnimatedTransitionController()
			self.source.transitioningDelegate = self.animationController
            self.source.dismiss(animated: true)
        }
			
			
			
			
			
		else if self.identifier == "ArtistSearchResults->Artist" {
			self.animationController = PopInFromFrameAnimatedTransitionController()
			self.destination.transitioningDelegate = self.animationController
			self.source.present(self.destination, animated: true)
		} else if self.identifier == "Artist->ArtistSearchResults" {
			self.animationController = PopInFromFrameAnimatedTransitionController()
			self.source.transitioningDelegate = self.animationController
			self.source.dismiss(animated: true)
		}
        
        
			
			
        
        else if self.identifier == "ArtistSearch->Artist" {
			self.animationController = PopInAnimatedTransitionController()
			self.destination.transitioningDelegate = self.animationController
            self.source.present(self.destination, animated: true)
        } else if self.identifier == "Artist->ArtistSearch" {
			self.animationController = PopInAnimatedTransitionController()
			self.source.transitioningDelegate = self.animationController
            self.source.dismiss(animated: true)
        }
			
			
			
			
			
		else if self.identifier == "Artist->Release" {
			self.animationController = BlurAndOverlayAnimatedTransitionController()
			self.destination.transitioningDelegate = self.animationController
			self.source.present(self.destination, animated: true)
			
		} else if self.identifier == "Release->Artist" {
			self.animationController = BlurAndOverlayAnimatedTransitionController()
			self.source.transitioningDelegate = self.animationController
			self.source.dismiss(animated: true)
		}
		
		
		
		
		else if self.identifier == "Artist->Artists" {
			self.animationController = PopInAnimatedTransitionController()
			self.destination.transitioningDelegate = self.animationController
			self.source.present(self.destination, animated: true)
		} else if self.identifier == "Artists->Artist" {
			self.animationController = PopInAnimatedTransitionController()
			self.source.transitioningDelegate = self.animationController
			self.source.dismiss(animated: true)
		}
    }
	
}
