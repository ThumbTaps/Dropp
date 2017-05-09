//
//  SettingsViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 1/8/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class SettingsViewController: DroppViewController {
	
	override var indicator: UIView? {
		return SettingsButton()
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
						
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	

	
	
	
	// MARK: - Navigation
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
		PreferenceManager.shared.save()
		
		super.prepare(for: segue, sender: sender)
	}
}


extension SettingsViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ThemeModeCollectionViewCellDelegate, UIPickerCollectionViewCellDelegate {
	
	// MARK: - UICollectionViewDataSource
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 2
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		var numRows = 0
		
		switch section {
		case 0: // DISPLAY OPTIONS
			numRows = 2
			if PreferenceManager.shared.themeMode == .auto {
				numRows += 2
				if PreferenceManager.shared.themeDeterminer == .displayBrightness {
					numRows += 1
				}
			}
			break
			
		case 1: // RELEASE OPTIONS
			numRows = 4
			if PreferenceManager.shared.includeSingles {
				numRows += 1
			}
			if PreferenceManager.shared.autoMarkAsSeen {
				numRows += 1
			}
			if PreferenceManager.shared.showPreviousReleases {
				numRows += 1
			}
			break
			
		default: return numRows
		}
		
		return numRows
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: self.view.bounds.width, height: 50)
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		var size = CGSize(width: collectionView.frame.width, height: 50)
		
		switch indexPath.section {
		case 0: // DISPLAY OPTIONS
			switch indexPath.row {
			case 0: size.height = 120 // THEME MODE
			default: return size
			}
		default: return size
		}
		return size
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
		
		let standardFooterSize = CGSize(width: self.view.bounds.width, height: 80)
		switch section {
		case 0: // DISPLAY OPTIONS
			if PreferenceManager.shared.themeMode == .auto {
				return standardFooterSize
			} else {
				return .zero
			}
			
		case 1: // RELEASE OPTIONS
			return standardFooterSize
			
		default: return .zero
		}
	}
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		var reusableView = UICollectionReusableView()
		
		if kind == UICollectionElementKindSectionHeader {
			
			reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SettingsCollectionViewHeader", for: indexPath) as! HeaderCollectionReusableView
			switch indexPath.section {
				
			case 0: (reusableView as! HeaderCollectionReusableView).textLabel.text = "DISPLAY OPTIONS"
				break
				
			case 1: (reusableView as! HeaderCollectionReusableView).textLabel.text = "RELEASE OPTIONS"
				break
				
			default: return reusableView
			}
			
			(reusableView as? HeaderCollectionReusableView)?.textLabel.textColor = ThemeKit.primaryTextColor
			(reusableView as? HeaderCollectionReusableView)?.strokeColor = ThemeKit.strokeColor
			reusableView.backgroundColor = ThemeKit.backgroundColor

			return reusableView
		}
			
		else if kind == UICollectionElementKindSectionFooter {
			
			reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SettingsCollectionViewFooter", for: indexPath) as! FooterCollectionReusableView
			
			var footerText = ""
			
			switch indexPath.section {
				
			case 0: // DISPLAY OPTIONS
				if PreferenceManager.shared.themeMode == .auto {
					if PreferenceManager.shared.themeDeterminer == .displayBrightness {
						footerText += "The theme will change according to the display's brightness setting. "
					} else if PreferenceManager.shared.themeDeterminer == .twilight {
						footerText += "The theme will change according to the rising and setting of the sun. "
					}
				}
				if PreferenceManager.shared.adaptiveArtistView {
					footerText += "The artist view will adapt to match the color palette of the current artist's artwork. "
				} else {
					footerText += "The artist view will match the color palette of the rest of the app. "
				}
				break
				
			case 1: // RELEASE OPTIONS
				if PreferenceManager.shared.includeSingles && PreferenceManager.shared.includeEPs {
					if PreferenceManager.shared.ignoreFeatures {
						footerText += "New releases will include EPs and exclude singles where the artist is only featuring. "
					} else {
						footerText += "New releases will include EPs and singles. "
					}
				} else if PreferenceManager.shared.includeSingles && !PreferenceManager.shared.includeEPs {
					if PreferenceManager.shared.ignoreFeatures {
						footerText += "New releases will exclude EPs and singles where the artist is only featuring. "
					} else {
						footerText += "New releases will exclude EPs. "
					}
				} else if !PreferenceManager.shared.includeSingles && PreferenceManager.shared.includeEPs {
					footerText += "New releases will exclude all singles. "
				} else {
					footerText += "New releases will exclude EPs and singles. "
				}
				if PreferenceManager.shared.showPreviousReleases {
					var timeUnit = " months"
					if PreferenceManager.shared.maxPreviousReleaseAge == 1 {
						timeUnit = " month"
					}
					footerText += "Releases from the past \(PreferenceManager.shared.maxPreviousReleaseAge == 1 ? timeUnit : String(PreferenceManager.shared.maxPreviousReleaseAge) + timeUnit) will be shown. "
				}
				break
				
			default: return reusableView
			}
			
			(reusableView as! FooterCollectionReusableView).textLabel?.text = footerText
			reusableView.backgroundColor = ThemeKit.backdropOverlayColor
			
			return reusableView
		}
		
		return reusableView
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		var cell = UICollectionViewCell()
		switch indexPath.section {
		case 0: // DISPLAY OPTIONS
			switch indexPath.row {
			case 0: // THEME MODE
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeModeCell", for: indexPath) as! ThemeModeCollectionViewCell
				if PreferenceManager.shared.themeMode == .auto {
					(cell as! ThemeModeCollectionViewCell).autoOption.selected = true
					(cell as! ThemeModeCollectionViewCell).lightOption.selected = false
					(cell as! ThemeModeCollectionViewCell).darkOption.selected = false
				} else {
					
					if PreferenceManager.shared.theme == .dark {
						(cell as! ThemeModeCollectionViewCell).autoOption.selected = false
						(cell as! ThemeModeCollectionViewCell).lightOption.selected = false
						(cell as! ThemeModeCollectionViewCell).darkOption.selected = true
					} else {
						(cell as! ThemeModeCollectionViewCell).autoOption.selected = false
						(cell as! ThemeModeCollectionViewCell).lightOption.selected = true
						(cell as! ThemeModeCollectionViewCell).darkOption.selected = false
					}
				}
				(cell as! ThemeModeCollectionViewCell).delegate = self
				break
				
			case 1: // THEME MODE DETERMINER OR ADAPTIVE ARTIST VIEW
				if PreferenceManager.shared.themeMode == .auto {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeDeterminerDisplayBrightnessCell", for: indexPath) as! DroppCollectionViewCell
					(cell as! SettingsCollectionViewCell).accessoryView?.isHidden = PreferenceManager.shared.themeDeterminer != .displayBrightness
				} else {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdaptiveArtistViewCell", for: indexPath)
					((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.adaptiveArtistView
				}
				break
				
			case 2: // DISPLAY BRIGHTNESS THRESHOLD OR TWILIGHT
				if PreferenceManager.shared.themeDeterminer == .displayBrightness {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DisplayBrightnessThresholdCell", for: indexPath)
					(cell as! DisplayBrightnessThresholdCollectionViewCell).slider.value = Float(PreferenceManager.shared.themeBrightnessThreshold)
				} else {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeDeterminerTwilightCell", for: indexPath)
					(cell as! SettingsCollectionViewCell).accessoryView?.isHidden = PreferenceManager.shared.themeDeterminer != .twilight
				}
				break
				
			case 3: // TWILIGHT OR ADAPTIVE ARTIST VIEW
				if PreferenceManager.shared.themeDeterminer == .displayBrightness {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeDeterminerTwilightCell", for: indexPath)
					(cell as! SettingsCollectionViewCell).accessoryView?.isHidden = PreferenceManager.shared.themeDeterminer != .twilight
				} else {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdaptiveArtistViewCell", for: indexPath)
					((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.adaptiveArtistView
				}
				break
				
			case 4:
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AdaptiveArtistViewCell", for: indexPath)
				((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.adaptiveArtistView
				break
				
			default: break
			}
			
		case 1: // RELEASE OPTIONS
			switch indexPath.row {
			case 0: // IGNORE SINGLES
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IncludeSinglesCell", for: indexPath) as! SettingsCollectionViewCell
				((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.includeSingles
				break
				
			case 1: // IGNORE FEATURES / INCLUDE EPS
				if PreferenceManager.shared.includeSingles {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IgnoreFeaturesCell", for: indexPath) as! SettingsCollectionViewCell
					((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.ignoreFeatures
				} else {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IncludeEPsCell", for: indexPath) as! SettingsCollectionViewCell
					((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.includeEPs
				}
				break
				
			case 2: // INCLUDE EPS / AUTO MARK AS SEEN
				if PreferenceManager.shared.includeSingles {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IncludeEPsCell", for: indexPath) as! SettingsCollectionViewCell
					((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.includeEPs
				} else {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AutoMarkAsSeenCell", for: indexPath) as! SettingsCollectionViewCell
					((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.autoMarkAsSeen
				}
				break
				
			case 3: // AUTO MARK AS SEEN / MAX NEW RELEASE AGE / SHOW PREVIOUS RELEASES
				if PreferenceManager.shared.includeSingles {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AutoMarkAsSeenCell", for: indexPath) as! SettingsCollectionViewCell
					((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.autoMarkAsSeen
				} else {
					if PreferenceManager.shared.autoMarkAsSeen {
						cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaxNewReleaseAgeCell", for: indexPath)
						(cell as! UIPickerCollectionViewCell).leftTextLabel.text = "Automatically mark as seen after"
						(cell as! UIPickerCollectionViewCell).pickerButton.setTitle(String(PreferenceManager.shared.maxNewReleaseAge), for: .normal)
						var timeUnit = "days"
						if PreferenceManager.shared.maxNewReleaseAge == 1 {
							timeUnit = "day"
						}
						(cell as! UIPickerCollectionViewCell).rightTextLabel.text = timeUnit
						(cell as! UIPickerCollectionViewCell).delegate = self
						(cell as! UIPickerCollectionViewCell).options = [1, 2, 3, 4, 5, 6, 7]
						(cell as! UIPickerCollectionViewCell).selectedIndex = (cell as! UIPickerCollectionViewCell).options.index(where: {
							Int64($0 as! Int) == PreferenceManager.shared.maxNewReleaseAge
						}) ?? 0
						
					} else {
						cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowPreviousReleasesCell", for: indexPath)
						((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.showPreviousReleases
					}
				}
				break
				
			case 4: // MAX NEW RELEASE AGE / SHOW PREVIOUS RELEASES / MAX PREVIOUS RELEASE AGE
				if PreferenceManager.shared.includeSingles {
					if PreferenceManager.shared.autoMarkAsSeen {
						cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaxNewReleaseAgeCell", for: indexPath)
						(cell as! UIPickerCollectionViewCell).leftTextLabel.text = "Automatically mark as seen after"
						(cell as! UIPickerCollectionViewCell).pickerButton.setTitle(String(PreferenceManager.shared.maxNewReleaseAge), for: .normal)
						var timeUnit = "days"
						if PreferenceManager.shared.maxNewReleaseAge == 1 {
							timeUnit = "day"
						}
						(cell as! UIPickerCollectionViewCell).rightTextLabel.text = timeUnit
						(cell as! UIPickerCollectionViewCell).delegate = self
						(cell as! UIPickerCollectionViewCell).options = [1, 2, 3, 4, 5, 6, 7]
						(cell as! UIPickerCollectionViewCell).selectedIndex = (cell as! UIPickerCollectionViewCell).options.index(where: {
							Int64($0 as! Int) == PreferenceManager.shared.maxNewReleaseAge
						}) ?? 0
						
					} else {
						cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowPreviousReleasesCell", for: indexPath)
						((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.showPreviousReleases
					}
				} else {
					if PreferenceManager.shared.autoMarkAsSeen {
						cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowPreviousReleasesCell", for: indexPath)
						((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.showPreviousReleases
					} else {
						if PreferenceManager.shared.showPreviousReleases {
							cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaxPreviousReleaseAgeCell", for: indexPath)
							(cell as! UIPickerCollectionViewCell).leftTextLabel.text = "Only show releases from the past"
							(cell as! UIPickerCollectionViewCell).pickerButton.setTitle(String(PreferenceManager.shared.maxPreviousReleaseAge), for: .normal)
							var timeUnit = "months"
							if PreferenceManager.shared.maxPreviousReleaseAge == 1 {
								timeUnit = "month"
							}
							(cell as! UIPickerCollectionViewCell).rightTextLabel.text = timeUnit
							(cell as! UIPickerCollectionViewCell).delegate = self
							(cell as! UIPickerCollectionViewCell).options = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
							(cell as! UIPickerCollectionViewCell).selectedIndex = (cell as! UIPickerCollectionViewCell).options.index(where: {
								Int64($0 as! Int) == PreferenceManager.shared.maxPreviousReleaseAge
							}) ?? 0
						}
					}
				}
				break
				
			case 5: // SHOW PREVIOUS RELEASES / MAX PREVIOUS RELEASE AGE
				if PreferenceManager.shared.includeSingles {
					if PreferenceManager.shared.autoMarkAsSeen {
						cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowPreviousReleasesCell", for: indexPath)
						((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.showPreviousReleases
					} else {
						if PreferenceManager.shared.showPreviousReleases {
							cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaxPreviousReleaseAgeCell", for: indexPath)
							(cell as! UIPickerCollectionViewCell).leftTextLabel.text = "Only show releases from the past"
							(cell as! UIPickerCollectionViewCell).pickerButton.setTitle(String(PreferenceManager.shared.maxPreviousReleaseAge), for: .normal)
							var timeUnit = "months"
							if PreferenceManager.shared.maxPreviousReleaseAge == 1 {
								timeUnit = "month"
							}
							(cell as! UIPickerCollectionViewCell).rightTextLabel.text = timeUnit
							(cell as! UIPickerCollectionViewCell).delegate = self
							(cell as! UIPickerCollectionViewCell).options = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
							(cell as! UIPickerCollectionViewCell).selectedIndex = (cell as! UIPickerCollectionViewCell).options.index(where: {
								Int64($0 as! Int) == PreferenceManager.shared.maxPreviousReleaseAge
							}) ?? 0
						}
					}
				} else {
					if PreferenceManager.shared.autoMarkAsSeen {
						if PreferenceManager.shared.showPreviousReleases {
							cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaxPreviousReleaseAgeCell", for: indexPath)
							(cell as! UIPickerCollectionViewCell).leftTextLabel.text = "Only show releases from the past"
							(cell as! UIPickerCollectionViewCell).pickerButton.setTitle(String(PreferenceManager.shared.maxPreviousReleaseAge), for: .normal)
							var timeUnit = "months"
							if PreferenceManager.shared.maxPreviousReleaseAge == 1 {
								timeUnit = "month"
							}
							(cell as! UIPickerCollectionViewCell).rightTextLabel.text = timeUnit
							(cell as! UIPickerCollectionViewCell).delegate = self
							(cell as! UIPickerCollectionViewCell).options = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
							(cell as! UIPickerCollectionViewCell).selectedIndex = (cell as! UIPickerCollectionViewCell).options.index(where: {
								Int64($0 as! Int) == PreferenceManager.shared.maxPreviousReleaseAge
							}) ?? 0
						}
					}
				}
				break
				
			case 6: // MAX PREVIOUS RELEASE AGE
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaxPreviousReleaseAgeCell", for: indexPath)
				(cell as! UIPickerCollectionViewCell).leftTextLabel.text = "Only show releases from the past"
				(cell as! UIPickerCollectionViewCell).pickerButton.setTitle(String(PreferenceManager.shared.maxPreviousReleaseAge), for: .normal)
				var timeUnit = "months"
				if PreferenceManager.shared.maxPreviousReleaseAge == 1 {
					timeUnit = "month"
				}
				(cell as! UIPickerCollectionViewCell).rightTextLabel.text = timeUnit
				(cell as! UIPickerCollectionViewCell).delegate = self
				(cell as! UIPickerCollectionViewCell).options = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
				(cell as! UIPickerCollectionViewCell).selectedIndex = (cell as! UIPickerCollectionViewCell).options.index(where: {
					Int64($0 as! Int) == PreferenceManager.shared.maxPreviousReleaseAge
				}) ?? 0
				break
				
			default: break
			}
			
			break
			
		default: break
			
		}
		
		if PreferenceManager.shared.theme == .dark {
			((cell as? SettingsCollectionViewCell)?.accessoryView as? UISwitch)?.tintColor = StyleKit.darkTintColor
			((cell as? SettingsCollectionViewCell)?.accessoryView as? UISwitch)?.onTintColor = StyleKit.darkTintColor
		} else {
			((cell as? SettingsCollectionViewCell)?.accessoryView as? UISwitch)?.tintColor = StyleKit.lightTintColor
			((cell as? SettingsCollectionViewCell)?.accessoryView as? UISwitch)?.onTintColor = StyleKit.lightTintColor
		}
		
		cell.backgroundColor = ThemeKit.backdropOverlayColor
		cell.selectedBackgroundView?.backgroundColor = ThemeKit.tintColor.withAlpha(0.2)
		
		return cell
		
	}
	func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		switch indexPath.section {
		case 0: // DISPLAY OPTIONS
			switch indexPath.row {
			case 1: return true // DISPLAY BRIGHTNESS
			case 2: return PreferenceManager.shared.themeDeterminer != .displayBrightness // BRIGHTNESS THRESHOLD / TWILIGHT
			case 3: return PreferenceManager.shared.themeDeterminer == .displayBrightness // TWILIGHT
			default: return false
			}
		default: return false
		}
	}
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		return self.collectionView(collectionView, shouldHighlightItemAt: indexPath)
	}
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		switch indexPath.section {
		case 0: // DISPLAY OPTIONS
			switch indexPath.row {
			case 1: // DISPLAY BRIGHTNESS
				PreferenceManager.shared.themeDeterminer = .displayBrightness
				collectionView.reloadSections([0])
				break
				
			case 2, 3: // TWILIGHT
				PreferenceManager.shared.themeDeterminer = .twilight
				PreferenceManager.shared.themeDeterminerDidChangeNotification.add(self, selector: #selector(self.themeDeterminerChangeFailed))
				collectionView.reloadSections([0])
				break
				
			default: return
				
			}
			break
			
		default: return
		}
	}
	
	func themeDeterminerChangeFailed() {
		PreferenceManager.shared.themeDeterminerDidChangeNotification.remove(self)
		self.collectionView?.reloadSections([0])
		let alertView = UIAlertController(title: "Could Not Determine Theme", message: "There was an issue determining the theme based on the twilight times for your location. Please make sure location services are enabled and allowed.", preferredStyle: .alert)
		alertView.view.tintColor = self.view.tintColor
		alertView.addAction(UIAlertAction(title: "OK", style: .default))
		self.present(alertView, animated: true, completion: nil)
	}
	func didSelectTheme(theme: Theme?) {
		if theme != nil {
			PreferenceManager.shared.themeMode = .manual
			PreferenceManager.shared.theme = theme!
			if #available(iOS 10.3, *) {
				if UIApplication.shared.supportsAlternateIcons {
					UIApplication.shared.setAlternateIconName("Dark Icon", completionHandler: { (error) in
						guard error == nil else {
							print(error!)
							return
						}
					})
				}
			}
		} else {
			PreferenceManager.shared.themeMode = .auto
		}
		self.collectionView?.performBatchUpdates({
			self.collectionView?.reloadSections([0])
		})
	}
	
	
	
	// MARK: - Settings Triggers
	@IBAction func adjustThemeModeDisplayBrightnessThreshold(_ sender: UISlider) {
		PreferenceManager.shared.themeBrightnessThreshold = Double(sender.value)
	}
	@IBAction func toggleAdaptiveArtistView(_ sender: UISwitch) {
		PreferenceManager.shared.adaptiveArtistView = sender.isOn
		self.collectionView?.performBatchUpdates({
			self.collectionView?.reloadSections([0])
		})
	}
	
	@IBAction func toggleIncludeSingles(_ sender: UISwitch) {
		PreferenceManager.shared.includeSingles = sender.isOn
		self.collectionView?.performBatchUpdates({
			self.collectionView?.reloadSections([1])
		})
	}
	@IBAction func toggleIgnoreFeatures(_ sender: UISwitch) {
		PreferenceManager.shared.ignoreFeatures = sender.isOn
	}
	@IBAction func toggleIncludeEPs(_ sender: UISwitch) {
		PreferenceManager.shared.includeEPs = sender.isOn
	}
	@IBAction func toggleAutoMarkAsSeen(_ sender: UISwitch) {
		PreferenceManager.shared.autoMarkAsSeen = sender.isOn
		self.collectionView?.performBatchUpdates({
			self.collectionView?.reloadSections([1])
		})
	}
	@IBAction func toggleShowPreviousReleases(_ sender: UISwitch) {
		PreferenceManager.shared.showPreviousReleases = sender.isOn
		self.collectionView?.performBatchUpdates({
			self.collectionView?.reloadSections([1])
		})
	}
	func pickerCell(_ pickerCell: UIPickerCollectionViewCell, didSelectItemAt indexPath: IndexPath) {
		if pickerCell.reuseIdentifier == "MaxNewReleaseAgeCell" {
			PreferenceManager.shared.maxNewReleaseAge = Int64(pickerCell.options[indexPath.row] as! Int)
		} else if pickerCell.reuseIdentifier == "MaxPreviousReleaseAgeCell" {
			PreferenceManager.shared.maxPreviousReleaseAge = Int64(pickerCell.options[indexPath.row] as! Int)
		}
		self.collectionView?.performBatchUpdates({
			self.collectionView?.reloadSections([1])
		})
	}
}
