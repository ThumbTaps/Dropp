//
//  SettingsViewController.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/8/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class SettingsViewController: UrsusViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	var unwindSegueIdentifier = "Settings->NewReleases"
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if PreferenceManager.shared.themeMode == .dark {
			
			self.view.backgroundColor = StyleKit.darkTintColor
			self.collectionView?.backgroundColor = StyleKit.darkBackdropOverlayColor.withAlphaComponent(0.95)
		} else {
			self.view.backgroundColor = StyleKit.lightTintColor
			self.collectionView?.backgroundColor = StyleKit.lightBackdropOverlayColor.withAlphaComponent(0.95)
		}

	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	override func themeDidChange() {
		
		super.themeDidChange()
		
		if PreferenceManager.shared.themeMode == .dark {
			
			self.view.backgroundColor = StyleKit.darkTintColor
            self.collectionView?.backgroundColor = StyleKit.darkBackdropOverlayColor.withAlphaComponent(0.95)
		} else {
			self.view.backgroundColor = StyleKit.lightTintColor
            self.collectionView?.backgroundColor = StyleKit.lightBackdropOverlayColor.withAlphaComponent(0.95)
		}
	}
	
    

	// MARK: - UICollectionViewDataSource
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 2
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch section {
		case 0: // THEME OPTIONS
			return 1
			
		case 1: // RELEASE OPTIONS
			return 2
			
		default:
			return 0
		}
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		var size = CGSize(width: collectionView.frame.width, height: 60)
		
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
			
			reusableView.tintColor = UIColor.clear
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
				if PreferenceManager.shared.autoThemeMode {
					(cell as! ThemeModeCollectionViewCell).autoOption.selected = true
				} else {
					
					if PreferenceManager.shared.themeMode == .dark {
						(cell as! ThemeModeCollectionViewCell).darkOption.selected = true
					} else {
						(cell as! ThemeModeCollectionViewCell).lightOption.selected = true
					}
				}
				break
				
			case 1: // THEME MODE DETERMINER
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeModeDeterminerCell", for: indexPath) as! UrsusCollectionViewCell
			
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

	
	
	
	
	@IBAction func toggleIgnoreSingles(_ sender: UISwitch) {
		PreferenceManager.shared.ignoreSingles = sender.isOn
	}
	@IBAction func toggleIgnoreEPs(_ sender: UISwitch) {
		PreferenceManager.shared.ignoreEPs = sender.isOn
	}
	
	
	
	
	
	
	// MARK: - Navigation
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
}
