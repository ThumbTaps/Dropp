//
//  ReleaseSortingViewController.swift
//  Lissic
//
//  Created by Jeffery Jackson, Jr. on 2/18/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class ReleaseSortingViewController: LissicViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		self.themeDidChange()
    }
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.exit))
		tapGestureRecognizer.cancelsTouchesInView = false
		tapGestureRecognizer.delaysTouchesBegan = false
		tapGestureRecognizer.delegate = self
		self.view.addGestureRecognizer(tapGestureRecognizer)
	}
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	
	
	// MARK: Notifications
	override func themeDidChange() {
		
		DispatchQueue.main.async {
			
			if PreferenceManager.shared.theme == .dark {
				self.collectionView?.indicatorStyle = .white
				self.navigationTitle?.textColor = StyleKit.darkTertiaryTextColor
			} else {
				self.collectionView?.indicatorStyle = .default
				self.navigationTitle?.textColor = StyleKit.lightTertiaryTextColor
			}
		}
	}
	
	
	
	
	
	// MARK: - UICollectionViewDataSource
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 3
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		var cell: SettingsCollectionViewCell = SettingsCollectionViewCell()
		
		switch indexPath.row {
		case 0:
			cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReleaseDateSortingCell", for: indexPath) as! SettingsCollectionViewCell
			cell.accessoryView?.isHidden = PreferenceManager.shared.releaseSorting != .releaseDate
			break
		case 1:
			cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReleaseTitleSortingCell", for: indexPath) as! SettingsCollectionViewCell
			cell.accessoryView?.isHidden = PreferenceManager.shared.releaseSorting != .releaseTitle
			break
		case 2:
			cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtistNameSortingCell", for: indexPath) as! SettingsCollectionViewCell
			cell.accessoryView?.isHidden = PreferenceManager.shared.releaseSorting != .artistName
			break
		default: return cell
		}
		
		if PreferenceManager.shared.theme == .dark {
			cell.textLabel?.textColor = StyleKit.darkTintColor
		} else {
			cell.textLabel?.textColor = StyleKit.lightTintColor
		}
		
		return cell
	}
	
	
	
	
	
	// MARK: - UICollectionViewDelegate
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		switch indexPath.row {
		case 0: PreferenceManager.shared.releaseSorting = .releaseDate
			break
		case 1: PreferenceManager.shared.releaseSorting = .releaseTitle
			break
		case 2: PreferenceManager.shared.releaseSorting = .artistName
			break
		default: break
		}
		
		self.performSegue(withIdentifier: "ReleaseSorting->NewReleases", sender: nil)
	}
	
	
	
	
	
	// MARK: - UICollectionViewDelegateFlowLayout
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		return CGSize(width: self.view.bounds.width, height: 50)
	}
	
	
	
	
	// MARK: - UIGestureRecognizerDelegate
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		
		if touch.location(in: self.view).y > self.topScrollFadeView?.bounds.height ?? 0 {
			return true
		}
		
		return false
	}
	
	
	
	
	
    // MARK: - Navigation
	func exit() {
		self.performSegue(withIdentifier: "ReleaseSorting->NewReleases", sender: nil)
	}
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}
