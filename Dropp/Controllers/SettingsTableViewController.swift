//
//  SettingsTableViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 11/4/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet weak var releaseHistoryThresholdLabel: UILabel!
    @IBOutlet weak var releaseHistoryPickerView: UIPickerView!
    
    @IBOutlet weak var preferExplicitVersionsSwitch: UISwitch!
    
    var canEditReleaseHistory: Bool = false {
        didSet {
            tableView.reloadRows(at: [IndexPath(row: GeneralSection.ReleaseHistoryPicker.rawValue, section: Section.General.rawValue)], with: .none)
        }
    }
    
    private enum Section: Int {
        case General
        
        static func count() -> Int {
            return self.General.rawValue + 1
        }
    }
    
    private enum GeneralSection: Int {
        case ReleaseHistory, ReleaseHistoryPicker, PreferExplicitVersions
        
        static func count() -> Int {
            return self.PreferExplicitVersions.rawValue + 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // indicate current release history preference
        let unit = ReleaseHistoryUnit.unitForCalendarComponent(forComponent: PreferenceStore.releaseHistoryThreshold.unit)
        self.releaseHistoryThresholdLabel.text = "\(PreferenceStore.releaseHistoryThreshold.amount) \(unit.stringValue)\(PreferenceStore.releaseHistoryThreshold.amount != 1 ? "s" : "")"
        self.releaseHistoryPickerView.selectRow(PreferenceStore.releaseHistoryThreshold.amount-1, inComponent: ReleaseHistoryComponent.Amount.rawValue, animated: false)
        self.releaseHistoryPickerView.selectRow(ReleaseHistoryUnit.unitForCalendarComponent(forComponent: PreferenceStore.releaseHistoryThreshold.unit).rawValue, inComponent: ReleaseHistoryComponent.Unit.rawValue, animated: false)
        
        self.preferExplicitVersionsSwitch.isOn = PreferenceStore.preferExplicitVersions
    }
    
    
    
    @IBAction func togglePreferExplicitVersions(_ sender: UISwitch) {
        PreferenceStore.preferExplicitVersions = sender.isOn
    }
    
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = Section.init(rawValue: section) else {
            assertionFailure("Unable to determine section.")
            return 0
        }
        
        switch section {
        case .General: fallthrough
        default:
            return GeneralSection.count()
        }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let section = Section.init(rawValue: indexPath.section) else {
            assertionFailure("Unable to determine section.")
            return 0
        }
        
        switch section {
        case .General:
            guard let row = GeneralSection.init(rawValue: indexPath.row) else {
                assertionFailure("Unable to determine row.")
                return 0
            }
            
            switch row {
            case .ReleaseHistory: fallthrough
            case .PreferExplicitVersions:
                return 44
            case .ReleaseHistoryPicker:
                return self.canEditReleaseHistory ? 120 : 0
            }
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let section = Section.init(rawValue: indexPath.section) else {
            assertionFailure("Unable to determine section.")
            return
        }
        
        switch section {
        case .General:
            guard let row = GeneralSection.init(rawValue: indexPath.row) else {
                assertionFailure("Unable to determine row.")
                return
            }
            
            switch row {
            case .ReleaseHistory:
                self.canEditReleaseHistory = !self.canEditReleaseHistory
            default:
                return
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    private enum ReleaseHistoryComponent: Int {
        case Amount, Unit
        
        static func count() -> Int {
            return self.Unit.rawValue + 1
        }
    }
    private enum ReleaseHistoryUnit: Int {
        case Day, Week, Month, Year
        
        static func count() -> Int {
            return self.Year.rawValue + 1
        }
        
        static func calendarComponent(forUnit unit: ReleaseHistoryUnit) -> Calendar.Component {
            switch unit {
            case .Day:
                return .day
            case .Week:
                return .weekOfMonth
            case .Month:
                return .month
            case .Year:
                return .year
            }
        }
        
        static func unitForCalendarComponent(forComponent component: Calendar.Component) -> ReleaseHistoryUnit {
            switch component {
            case .day:
                return .Day
            case .weekOfMonth:
                return .Week
            case .year:
                return .Year
            case .month: fallthrough
            default:
                return .Month
            }
        }
        
        var stringValue: String {
            switch self {
            case .Day:
                return "day"
            case .Week:
                return "week"
            case .Month:
                return "month"
            case .Year:
                return "year"
            }
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let component = ReleaseHistoryComponent.init(rawValue: component) else {
            assertionFailure("Unable to determine component.")
            return 0
        }
        
        switch component {
        case .Amount:
            switch PreferenceStore.releaseHistoryThreshold.unit {
            case .day:
                return 6
            case .weekOfMonth:
                return 4
            case .month:
                return 11
            case .year:
                return 1
            default:
                return 0
            }
            
        case .Unit:
            return ReleaseHistoryUnit.count()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let component = ReleaseHistoryComponent.init(rawValue: component) else {
            assertionFailure("Unable to determine component.")
            return ""
        }
        
        var label = ""
        
        switch component {
        case .Amount:
            label += "\(row+1)"
            
        case .Unit:
            guard let unit = ReleaseHistoryUnit.init(rawValue: row) else {
                assertionFailure("Unable to determine unit.")
                return ""
            }
            
            label = unit.stringValue
            
            if PreferenceStore.releaseHistoryThreshold.amount != 1 {
                label += "s"
            }
        }
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case self.releaseHistoryPickerView: fallthrough
        default:
            // update release history preference
            guard let component = ReleaseHistoryComponent.init(rawValue: component) else {
                assertionFailure("Unable to determine component.")
                return
            }
            
            switch component {
            case .Amount:
                let unit = ReleaseHistoryUnit.unitForCalendarComponent(forComponent: PreferenceStore.releaseHistoryThreshold.unit)
                PreferenceStore.releaseHistoryThreshold.amount = row+1
                self.releaseHistoryThresholdLabel.text = "\(PreferenceStore.releaseHistoryThreshold.amount) \(unit.stringValue)\(PreferenceStore.releaseHistoryThreshold.amount != 1 ? "s" : "")"
                
            case .Unit:
                let unit = ReleaseHistoryUnit.init(rawValue: row) ?? .Month
                PreferenceStore.releaseHistoryThreshold.unit = ReleaseHistoryUnit.calendarComponent(forUnit: unit)
                self.releaseHistoryThresholdLabel.text = "\(PreferenceStore.releaseHistoryThreshold.amount) \(unit.stringValue)\(PreferenceStore.releaseHistoryThreshold.amount != 1 ? "s" : "")"
            }
        }
        
        pickerView.reloadAllComponents()
    }
}

