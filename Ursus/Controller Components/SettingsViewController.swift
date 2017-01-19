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
		return 1
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch section {
		case 0:
			return 1
		default:
			return 0
		}
	}
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		var size = CGSize(width: collectionView.frame.width, height: 60)
		
		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 0: size.height = 120
			default: return size
			}
		default: return size
		}
		return size
	}
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		var reusableView = UICollectionReusableView()
		
		if kind == UICollectionElementKindSectionHeader {
			
			switch indexPath.section {
			case 0:
				reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SettingsCollectionViewHeader", for: indexPath) as! HeaderCollectionReusableView
				(reusableView as! HeaderCollectionReusableView).textLabel.text = "THEME OPTIONS"
				return reusableView
			default: return reusableView
			}
		}
		
		else if kind == UICollectionElementKindSectionFooter {
			return reusableView
		}
		
		return reusableView
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		var cell = UICollectionViewCell()
		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 0:
				cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThemeModeCell", for: indexPath) as! ThemeModeCollectionViewCell
				if PreferenceManager.shared.autoThemeMode {
					(cell as! ThemeModeCollectionViewCell).autoOption.selected = true
				} else {
					if PreferenceManager.shared.autoThemeMode {
						(cell as! ThemeModeCollectionViewCell).autoOption.selected = true
					} else {
						
						if PreferenceManager.shared.themeMode == .dark {
							(cell as! ThemeModeCollectionViewCell).darkOption.selected = true
						} else {
							(cell as! ThemeModeCollectionViewCell).lightOption.selected = true
						}
					}
				}
				break
			default: return cell
			}
			return cell
		default: return cell
		}
		
	}

	
	
	
	
	// MARK: - Navigation
	func dismiss() {
		
		self.performSegue(withIdentifier: self.unwindSegueIdentifier, sender: nil)
	}
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
}
