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
        private var _amount: Int = 3
        var amount: Int {
            set {
                self._amount = max(1, newValue)
            }
            get {
                return self._amount
            }
        }
        
        private var _unit: Calendar.Component = .month
        var unit: Calendar.Component {
            set {
                self._unit = newValue
            }
            get {
                return self._unit
            }
        }
        
        static func integerValue(forComponent component: Calendar.Component) -> Int {
            switch component {
            case .day:
                return 1
            case .weekOfMonth:
                return 2
            case .year:
                return 4
            case .month: fallthrough
            default:
                return 3
            }
        }
        
        static func calendarComponent(forInt intValue: Int) -> Calendar.Component {
            switch intValue {
            case 1:
                return .day
            case 2:
                return .weekOfMonth
            case 4:
                return .year
            case 3: fallthrough
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
            
            var releaseHistoryThreshold = ReleaseHistoryThreshold()
            releaseHistoryThreshold.amount = amount
            releaseHistoryThreshold.unit = ReleaseHistoryThreshold.calendarComponent(forInt: unit)
            
            return releaseHistoryThreshold
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
    
    static var showFeatures: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "showFeatures")
        }
        get {
            return UserDefaults.standard.bool(forKey: "showFeatures")
        }
    }
    
    static var showEPs: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "showEPs")
        }
        get {
            return UserDefaults.standard.bool(forKey: "showEPs")
        }
    }
    
    static var showSingles: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "showSingles")
        }
        get {
            return UserDefaults.standard.bool(forKey: "showSingles")
        }
    }
}
