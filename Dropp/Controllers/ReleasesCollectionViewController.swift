//
//  ReleaseCollectionViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 7/20/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

class ReleasesCollectionViewController: UICollectionViewController {
	
	private enum Section: Int {
		case Upcoming, Today, Past
		
		static func count() -> Int {
			return self.Past.rawValue + 1
		}
		
		var reuseIdentifier: String {
			switch self {
			case .Upcoming: return "releaseCell_artworkOnly"
			case .Today: return "releaseCell"
			case .Past: return "releaseCell_small"
			}
		}
		
		var releases: [Release] {
			switch self {
			case .Upcoming:
				return DataStore.releases.filter({ (release) -> Bool in
					return !Calendar.autoupdatingCurrent.isDateInToday(release.releaseDate) && release.releaseDate > Date()
				})
			case .Today:
//				var filteredReleases = DataStore.releases.filter({ (release) -> Bool in
//					return Calendar.autoupdatingCurrent.isDateInToday(release.releaseDate)
//				})
//				let randomRelease = DataStore.releases.randomElement()
//				let newRelease = Release(by: randomRelease!.artist, titled: randomRelease!.title, on: Date(), withIdentifer: randomRelease!.id)
//				newRelease.artworkURL = randomRelease?.artworkURL
//				filteredReleases.append(newRelease)
//				return filteredReleases
				
				return DataStore.releases.filter({ (release) -> Bool in
					return Calendar.autoupdatingCurrent.isDateInToday(release.releaseDate)
				})
			case .Past:
				return DataStore.releases.filter({ (release) -> Bool in
					return !Calendar.autoupdatingCurrent.isDateInToday(release.releaseDate) && release.releaseDate < Date()
				})
			}
		}
		
		var label: String {
			switch self {
			case .Upcoming: return "upcoming"
			case .Today: return "today"
			case .Past: return "in the past"
			}
		}
		
		var descriptor: String? {
			let formatter = DateFormatter()
			formatter.dateFormat = "MMMM d"
			
			switch self {
			case .Upcoming:
				guard let latestRelease = self.releases.max(by: { (release1, release2) -> Bool in
					return release1.releaseDate > release2.releaseDate
				}) else {
					return nil
				}
				
				return "Through \(formatter.string(from: latestRelease.releaseDate))"
				
			case .Today:
				return formatter.string(from: Date())
				
			case .Past:
				guard let pastDate = Calendar.autoupdatingCurrent.date(byAdding: PreferenceStore.releaseHistoryThreshold.unit, value: -PreferenceStore.releaseHistoryThreshold.amount, to: Date()) else {
					return nil
				}
				
				return "Since \(formatter.string(from: pastDate))"
			}
		}
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationController?.isNavigationBarHidden = true
		
		let refreshControl = UIRefreshControl()
		refreshControl.addTarget(self, action: #selector(self.refreshReleases), for: .valueChanged)
		self.collectionView.refreshControl = refreshControl
		
		(self.collectionViewLayout as? UICollectionViewFlowLayout)?.sectionHeadersPinToVisibleBounds = true
		
		self.collectionView.contentInset.top = -UIApplication.shared.statusBarFrame.height
	}
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.refreshReleases()
	}
    
    
    
    
    @objc func refreshReleases() {
        DataStore.refreshReleases {
            DispatchQueue.main.async {
                
                // stop refreshing if necessary
                if (self.collectionView.refreshControl?.isRefreshing ?? false) {
                    // after 200 milliseconds
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
                        self.collectionView.refreshControl?.endRefreshing()
                        
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
                            self.collectionView.reloadData()
                        }
                    }
                } else {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    
	
	
	// MARK: - Navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "releases->Release" {
            guard let destination = segue.destination as? ReleaseViewController,
            let selectedIndexPath = self.collectionView.indexPathsForSelectedItems?.first else {
                assertionFailure("Unable to determine selected release.")
                return
            }
            
            guard let section = Section.init(rawValue: selectedIndexPath.section) else {
                assertionFailure("Unable to determine section.")
                return
            }
            
            destination.release = section.releases[selectedIndexPath.row]
        }
	}
    @IBAction func unwind(segue: UIStoryboardSegue) {}
	
	
    
    
    // MARK: - UITableView Data Source
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
		return Section.count()
	}
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		guard let section = Section.init(rawValue: section) else {
			assertionFailure("Unable to determine section.")
			return 0
		}
		
		return section.releases.count
	}
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		guard let section = Section.init(rawValue: indexPath.section) else {
			assertionFailure("Unable to determine section.")
			return UICollectionViewCell()
		}
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: section.reuseIdentifier, for: indexPath) as! ReleaseCollectionViewCell
		
		let release = section.releases[indexPath.row]
		
		// Configure the cell...
		cell.titleLabel?.text = release.title
		cell.artistNameLabel?.text = release.artist.name
		
		cell.classificationIndicator?.setTitle(release.classification.indicatorString, for: .normal)
		cell.setClassificationIndicatorHidden(release.classification == .album)
		
		DispatchQueue.global().async {
			release.getArtwork(thumbnail: true) { (image, error) in
				DispatchQueue.main.async {
					cell.artworkImageView.image = image
				}
			}
		}
		
		return cell
	}
}

extension ReleasesCollectionViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		guard let section = Section.init(rawValue: section) else {
			assertionFailure("Unable to determine section.")
			return CGSize.zero
		}
		
		return section.releases.isEmpty ? CGSize.zero : CGSize(width: collectionView.frame.width, height: 80 + UIApplication.shared.statusBarFrame.height)
	}
	
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		
		guard let section = Section.init(rawValue: indexPath.section) else {
			assertionFailure("Unable to determine section.")
			return UICollectionReusableView()
		}
		
		let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerReusableView", for: indexPath) as! HeaderCollectionReusableView
		
		header.primaryLabel.text = section.label.uppercased()
		var labelColor: UIColor
		switch section {
		case .Upcoming:
			labelColor = UIColor(white: 0.2, alpha: 1)
		case .Today:
			labelColor = collectionView.tintColor
		case .Past:
			labelColor = UIColor(white: 0.35, alpha: 1)
		}
		header.primaryLabel.textColor = labelColor
		header.secondaryLabel?.text = section.descriptor?.uppercased()
		if section.descriptor == nil {
			header.secondaryLabel?.font = UIFont.systemFont(ofSize: 0)
		}
		
		return header
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		
		guard let section = Section.init(rawValue: indexPath.section) else {
			assertionFailure("Unable to determine section.")
			return CGSize.zero
		}
		
		var width: CGFloat = collectionView.frame.width
		var height: CGFloat = 140
		
		switch section.reuseIdentifier {
		case "releaseCell_artworkOnly":
			width = 80
			height = 80
			break
		case "releaseCell_small":
			height = 70
			break
		default:
			break
		}
		
		return CGSize(width: width, height: height)
	}
	
	/*
	// Uncomment this method to specify if the specified item should be highlighted during tracking
	override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
	return true
	}
	*/
	
	/*
	// Uncomment this method to specify if the specified item should be selected
	override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
	return true
	}
	*/
	
	/*
	// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
	override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
	return false
	}
	
	override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
	return false
	}
	
	override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
	
	}
	*/
	
}


