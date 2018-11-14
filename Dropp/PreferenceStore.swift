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
        
        static func integerValue(forComponent component: Calendar.Component) -> Int {
            switch component {
            case .day:
                return 0
            case .weekOfMonth:
                return 1
            case .year:
                return 3
            case .month: fallthrough
            default:
                return 2
            }
        }
        
        static func calendarComponent(forInt intValue: Int) -> Calendar.Component {
            switch intValue {
            case 0:
                return .day
            case 1:
                return .weekOfMonth
            case 3:
                return .year
            case 2: fallthrough
            default:
                return .month
            }
        }
	}
	
	static var releaseHistoryThreshold: ReleaseHistoryThreshold {
		set {
			UserDefaults.standard.set(newValue.amount, forKey: "releaseHistoryThreshold_amount")
            UserDefaults.standard.set(ReleaseHistoryThreshold.integerValue(forComponent: newValue.unit), forKey: "releaseHistoryThreshold_unit")
		}
		get {
			let amount = UserDefaults.standard.integer(forKey: "releaseHistoryThreshold_amount")
            let unit = UserDefaults.standard.integer(forKey: "releaseHistoryThreshold_unit")
            
            return ReleaseHistoryThreshold(amount: amount, unit: ReleaseHistoryThreshold.calendarComponent(forInt: unit))
		}
	}
    
    static var preferExplicitVersions: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "preferExplicitVersions")
        }
        get {
            return UserDefaults.standard.bool(forKey: "preferExplicitVersions")
        }
    }
}
