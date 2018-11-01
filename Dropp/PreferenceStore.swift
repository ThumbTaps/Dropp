//
//  PreferenceStore.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 10/28/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import Foundation

class PreferenceStore {
	
	struct ReleaseHistoryThreshold {
		var amount: Int = 3
		var unit: Calendar.Component = .month
	}
	
	static var releaseHistoryThreshold: ReleaseHistoryThreshold {
		set {
			UserDefaults.standard.set(newValue, forKey: "releaseHistoryThreshold")
		}
		get {
			return UserDefaults.standard.value(forKey: "releaseHistoryThreshold") as? ReleaseHistoryThreshold ?? ReleaseHistoryThreshold()
		}
	}
}
