//
//  SettingsViewController.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/8/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class SettingsViewController: UrsusViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, ThemeModeCollectionViewCellDelegate {
	
	var unwindSegueIdentifier = "Settings->NewReleases"
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
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
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch section {
		case 0: // THEME OPTIONS
			var numRows = 1
			if PreferenceManager.shared.themeMode == .auto {
				numRows += 2
				if PreferenceManager.shared.themeDeterminer == .displayBrightness {
					numRows += 1
				}
			}
			
			return numRows
			
		case 1: // RELEASE OPTIONS
			return 2
			
		default:
			return 0
		}
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		var size = CGSize(width: collectionView.frame.width, height: 50)
		
		switch indexPath.section {
		case 0: // THEME OPTIONS
			switch indexPath.row {
			case 0: size.height = 120 // THEME MODE
			default: return size
			}
		default: return size
		}
		return size
	}
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		var reusableView = UICollectionReusableView()
		
		if kind == UICollectionElementKindSectionHeader {
			
			reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SettingsCollectionViewHeader", for: indexPath) as! HeaderCollectionReusableView
			switch indexPath.section {
				
			case 0: (reusableView as! HeaderCollectionReusableView).textLabel.text = "THEME OPTIONS"
				break
				
			case 1: (reusableView as! HeaderCollectionReusableView).textLabel.text = "RELEASE OPTIONS"
				break
				
			default: return reusableView
			}
			
			return reusableView
		}
		
		else if kind == UICollectionElementKindSectionFooter {
			return reusableView
		}
		
		return reusableView
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		var cell = UICollectionViewCell()
		switch indexPath.section {
		case 0: // THEME OPTIONS
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
				
			case 1: // THEME MODE DETERMINER
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeDeterminerDisplayBrightnessCell", for: indexPath) as! UrsusCollectionViewCell
				(cell as! SettingsCollectionViewCell).textLabel?.text = "Display Brightness"
				(cell as! SettingsCollectionViewCell).accessoryView?.isHidden = PreferenceManager.shared.themeDeterminer != .displayBrightness
				break
				
			case 2: // DISPLAY BRIGHTNESS THRESHOLD OR TWILIGHT
				if PreferenceManager.shared.themeDeterminer == .displayBrightness {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DisplayBrightnessThresholdCell", for: indexPath)
					(cell as! DisplayBrightnessThresholdCollectionViewCell).slider.value = PreferenceManager.shared.themeBrightnessThreshold
				} else {
					cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeDeterminerTwilightCell", for: indexPath)
					(cell as! SettingsCollectionViewCell).textLabel?.text = "Twilight"
					(cell as! SettingsCollectionViewCell).accessoryView?.isHidden = PreferenceManager.shared.themeDeterminer != .twilight
				}
				break
				
			case 3: // TWILIGHT
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeDeterminerTwilightCell", for: indexPath)
				(cell as! SettingsCollectionViewCell).textLabel?.text = "Twilight"
				(cell as! SettingsCollectionViewCell).accessoryView?.isHidden = PreferenceManager.shared.themeDeterminer != .twilight
			
			default: return cell
			}
			return cell
			
		case 1: // RELEASE OPTIONS
			switch indexPath.row {
			case 0: // IGNORE SINGLES
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IgnoreSinglesCell", for: indexPath) as! SettingsCollectionViewCell
				(cell as! SettingsCollectionViewCell).textLabel?.text = "Ignore Singles"
				((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.ignoreSingles
				break
				
			case 1: // IGNORE EPS
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IgnoreEPsCell", for: indexPath) as! SettingsCollectionViewCell
				(cell as! SettingsCollectionViewCell).textLabel?.text = "Ignore EPs"
				((cell as! SettingsCollectionViewCell).accessoryView as? UISwitch)?.isOn = PreferenceManager.shared.ignoreEPs
				break
				
			default: return cell
			}
			return cell
			
		default: return cell
		}
		
	}
	func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		switch indexPath.section {
		case 0: // THEME OPTIONS
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
		case 0: // THEME OPTIONS
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
		collectionView?.reloadSections([0])
	}

	
	
	
	
	@IBAction func toggleIgnoreSingles(_ sender: UISwitch) {
		PreferenceManager.shared.ignoreSingles = sender.isOn
	}
	@IBAction func toggleIgnoreEPs(_ sender: UISwitch) {
		PreferenceManager.shared.ignoreEPs = sender.isOn
	}
	@IBAction func adjustThemeModeDisplayBrightnessThreshold(_ sender: UISlider) {
		PreferenceManager.shared.themeBrightnessThreshold = sender.value
	}
	
	
	
	
	
	
	// MARK: - Navigation
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
		PreferenceManager.shared.save()
	}
}
