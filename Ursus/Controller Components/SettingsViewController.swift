//
//  SettingsViewController.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/8/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class SettingsViewController: UrsusViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ThemeModeCollectionViewCellDelegate, UIPickerCollectionViewCellDelegate {
	
    override func viewDidLoad() {
        super.viewDidLoad()
				
		DispatchQueue.main.async {
			
			if PreferenceManager.shared.theme == .dark {
				
				self.view.backgroundColor = StyleKit.darkTintColor
				self.collectionView?.backgroundColor = StyleKit.darkBackdropOverlayColor.withAlphaComponent(0.95)
			} else {
				self.view.backgroundColor = StyleKit.lightTintColor
				self.collectionView?.backgroundColor = StyleKit.lightBackdropOverlayColor.withAlphaComponent(0.95)
			}
			
		}
		
    }
	
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	override func themeDidChange() {
		
		super.themeDidChange()
		
		DispatchQueue.main.async {
			
			if PreferenceManager.shared.theme == .dark {
				
				self.view.backgroundColor = StyleKit.darkTintColor
				self.collectionView?.backgroundColor = StyleKit.darkBackdropOverlayColor.withAlphaComponent(0.95)
			} else {
				self.view.backgroundColor = StyleKit.lightTintColor
				self.collectionView?.backgroundColor = StyleKit.lightBackdropOverlayColor.withAlphaComponent(0.95)
			}
			
		}
	}
	
	

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
			numRows = 3
			if PreferenceManager.shared.includeSingles {
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
		return CGSize(width: self.view.bounds.width, height: section > 0 ? 60 : 30)
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
					if PreferenceManager.shared.maxReleaseAge == 1 {
						timeUnit = " month"
					}
					footerText += "Releases from the past \(PreferenceManager.shared.maxReleaseAge == 1 ? timeUnit : String(PreferenceManager.shared.maxReleaseAge) + timeUnit) will be shown. "
				}
				break
				
			default: return reusableView
			}
			
			(reusableView as! FooterCollectionReusableView).textLabel?.text = footerText
			
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
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeDeterminerDisplayBrightnessCell", for: indexPath) as! UrsusCollectionViewCell
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
				
			default: return cell
			}
			return cell
			
		case 1: // RELEASE OPTIONS
			switch indexPath.row {
			case 0: // IGNORE SINGLES
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IncludeSinglesCell", for: indexPath) as! SettingsCollectionViewCell
				((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.includeSingles
				break
				
			case 1: // INCLUDE EPS / IGNORE FEATURES
				if PreferenceManager.shared.includeSingles {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IgnoreFeaturesCell", for: indexPath) as! SettingsCollectionViewCell
					((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.ignoreFeatures
				} else {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IncludeEPsCell", for: indexPath) as! SettingsCollectionViewCell
					((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.includeEPs
				}
				break
				
			case 2: // INCLUDE EPS / SHOW PREVIOUS RELEASES
				if PreferenceManager.shared.includeSingles {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IncludeEPsCell", for: indexPath) as! SettingsCollectionViewCell
					((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.includeEPs
				} else {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowPreviousReleasesCell", for: indexPath)
					((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.showPreviousReleases
				}
				break
				
			case 3: // SHOW PREVIOUS RELEASES / MAX RELEASE AGE
				
				if PreferenceManager.shared.includeSingles {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ShowPreviousReleasesCell", for: indexPath)
					((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.showPreviousReleases
				} else {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaxReleaseAgeCell", for: indexPath)
					(cell as! UIPickerCollectionViewCell).leftTextLabel.text = "Only show releases from the past"
					(cell as! UIPickerCollectionViewCell).pickerButton.setTitle(String(PreferenceManager.shared.maxReleaseAge), for: .normal)
					var timeUnit = "months"
					if PreferenceManager.shared.maxReleaseAge == 1 {
						timeUnit = "month"
					}
					(cell as! UIPickerCollectionViewCell).rightTextLabel.text = timeUnit
					(cell as! UIPickerCollectionViewCell).delegate = self
				}
				break
				
			case 4: // MAX RELEASE AGE
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MaxReleaseAgeCell", for: indexPath)
				(cell as! UIPickerCollectionViewCell).leftTextLabel.text = "Only show releases from the past"
				(cell as! UIPickerCollectionViewCell).pickerButton.setTitle(String(PreferenceManager.shared.maxReleaseAge), for: .normal)
				var timeUnit = "months"
				if PreferenceManager.shared.maxReleaseAge == 1 {
					timeUnit = "month"
				}
				(cell as! UIPickerCollectionViewCell).rightTextLabel.text = timeUnit
				(cell as! UIPickerCollectionViewCell).delegate = self
				break
				
			default: return cell
			}
			return cell
			
		default: return cell
			
		}
		
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
				collectionView.reloadSections([0])
				break
				
			default: return
				
			}
			break
			
		default: return
		}
	}
	func didSelectTheme(theme: Theme?) {
		if theme != nil {
			PreferenceManager.shared.themeMode = .manual
			PreferenceManager.shared.theme = theme!
		} else {
			PreferenceManager.shared.themeMode = .auto
		}
		self.collectionView?.reloadSections([0])
	}

	
	
	
	
	@IBAction func adjustThemeModeDisplayBrightnessThreshold(_ sender: UISlider) {
		PreferenceManager.shared.themeBrightnessThreshold = Double(sender.value)
	}
	@IBAction func toggleAdaptiveArtistView(_ sender: UISwitch) {
		PreferenceManager.shared.adaptiveArtistView = sender.isOn
		self.collectionView?.reloadSections([0])
	}

	@IBAction func toggleIncludeSingles(_ sender: UISwitch) {
		PreferenceManager.shared.includeSingles = sender.isOn
		self.collectionView?.reloadSections([1])
	}
	@IBAction func toggleIgnoreFeatures(_ sender: UISwitch) {
		PreferenceManager.shared.ignoreFeatures = sender.isOn
	}
	@IBAction func toggleIncludeEPs(_ sender: UISwitch) {
		PreferenceManager.shared.includeEPs = sender.isOn
	}
	@IBAction func toggleShowPreviousReleases(_ sender: UISwitch) {
		PreferenceManager.shared.showPreviousReleases = sender.isOn
		self.collectionView?.reloadSections([1])
	}
	func pickerCell(_ pickerCell: UIPickerCollectionViewCell, didSelectItemAt indexPath: IndexPath) {
		PreferenceManager.shared.maxReleaseAge = Int64(indexPath.row)+1
		self.collectionView?.reloadSections([1])
	}
	
	
	
	
	
	
	// MARK: - Navigation
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
		PreferenceManager.shared.save()
	}
}
