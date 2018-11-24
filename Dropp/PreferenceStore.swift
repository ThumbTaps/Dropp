//
//  PreferenceStore.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 10/28/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import Foundation

extension UserDefaults {
    func keyExists(_ key: String!) -> Bool {
        return self.object(forKey: key) != nil
    }
}

class PreferenceStore {
	
    private enum Key: String {
        case ReleaseHistoryThresholdAmountKey
        case ReleaseHistoryThresholdUnitKey
        case PrefereExplicitVersionsKey
        case ShowFeaturesKey
        case ShowEPsKey
        case ShowSinglesKey
    }
    
	struct ReleaseHistoryThreshold {
        var amount: Int = 3
        var unit: Calendar.Component = .month
        
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
			UserDefaults.standard.set(newValue.amount, forKey: Key.ReleaseHistoryThresholdAmountKey.rawValue)
            UserDefaults.standard.set(ReleaseHistoryThreshold.integerValue(forComponent: newValue.unit), forKey: Key.ReleaseHistoryThresholdUnitKey.rawValue)
		}
		get {
            guard UserDefaults.standard.keyExists(Key.ReleaseHistoryThresholdAmountKey.rawValue) &&
                UserDefaults.standard.keyExists(Key.ReleaseHistoryThresholdUnitKey.rawValue) else {
                    return ReleaseHistoryThreshold()
            }
            
			let amount = UserDefaults.standard.integer(forKey: Key.ReleaseHistoryThresholdAmountKey.rawValue)
            let unit = UserDefaults.standard.integer(forKey: Key.ReleaseHistoryThresholdUnitKey.rawValue)
            
            return ReleaseHistoryThreshold(amount: amount, unit: ReleaseHistoryThreshold.calendarComponent(forInt: unit))
		}
	}
    
    static var preferExplicitVersions: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: Key.PrefereExplicitVersionsKey.rawValue)
        }
        get {
            guard UserDefaults.standard.keyExists(Key.PrefereExplicitVersionsKey.rawValue) else {
                return false
            }
            
            return UserDefaults.standard.bool(forKey: Key.PrefereExplicitVersionsKey.rawValue)
        }
    }
    
    static var showFeatures: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: Key.ShowFeaturesKey.rawValue)
        }
        get {
            guard UserDefaults.standard.keyExists(Key.ShowFeaturesKey.rawValue) else {
                return true
            }

            return UserDefaults.standard.bool(forKey: Key.ShowFeaturesKey.rawValue)
        }
    }
    
    static var showEPs: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: Key.ShowEPsKey.rawValue)
        }
        get {
            guard UserDefaults.standard.keyExists(Key.ShowEPsKey.rawValue) else {
                return true
            }

            return UserDefaults.standard.bool(forKey: Key.ShowEPsKey.rawValue)
        }
    }
    
    static var showSingles: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: Key.ShowSinglesKey.rawValue)
        }
        get {
            guard UserDefaults.standard.keyExists(Key.ShowSinglesKey.rawValue) else {
                return true
            }

            return UserDefaults.standard.bool(forKey: Key.ShowSinglesKey.rawValue)
        }
    }
}
