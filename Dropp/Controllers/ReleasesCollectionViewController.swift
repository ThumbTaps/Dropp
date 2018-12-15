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
				
		let refreshControl = ReleasesRefreshControl()
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
    @objc func gotoArtists() {
        self.tabBarController?.selectedIndex = 1
    }
    @objc func gotoSettings() {
        self.tabBarController?.selectedIndex = 2
    }
    @IBAction func unwind(segue: UIStoryboardSegue) {}
	
	
    
    
    // MARK: - UICollectionView Data Source
	override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if DataStore.releases.isEmpty {
            return 1
        }
        
		return Section.count()
	}
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if DataStore.releases.isEmpty {
            return 1
        }
        
		guard let section = Section.init(rawValue: section) else {
			assertionFailure("Unable to determine section.")
			return 0
		}
		
		return section.releases.count
	}
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if DataStore.releases.isEmpty {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "noReleasesCell", for: indexPath) as! NoResultsCollectionViewCell
            
            // determine most probable reason for lack of releases
            if DataStore.followedArtists.count < 10 {
                // not following any artists
                cell.descriptionLabel.text = "Nothing to see here. Try following some\(DataStore.followedArtists.isEmpty ? " " : " more ")artists."
                cell.actionButton.glyph = .artists
                cell.actionButton.setTitle("Go to Artists", for: .normal)
                cell.actionButton.addTarget(self, action: #selector(self.gotoArtists), for: .touchUpInside)
                
                return cell
            }
            
            cell.descriptionLabel.text = "There haven't been any releases in the past\(PreferenceStore.releaseHistoryThreshold.amount == 1 ? "" : " \(PreferenceStore.releaseHistoryThreshold.amount)") \(PreferenceStore.releaseHistoryThreshold.unit.stringValue)\(PreferenceStore.releaseHistoryThreshold.amount == 1 ? "" : "s"). Maybe try adjusting your release settings?"
            cell.actionButton.glyph = .settings
            cell.actionButton.setTitle("Settings", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.gotoSettings), for: .touchUpInside)
            
            return cell
        }
		
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
    
    
    // MARK: - UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        view.layer.zPosition = 0.0
    }
}

extension ReleasesCollectionViewController: UICollectionViewDataSourcePrefetching {
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { (indexPath) in
            if DataStore.releases.isEmpty {
                return
            }
            
            guard let section = Section.init(rawValue: indexPath.section) else {
                return
            }
            
            let release = section.releases[indexPath.row]
            
            release.getArtwork(thumbnail: true)
        }
    }
}

extension ReleasesCollectionViewController: UICollectionViewDelegateFlowLayout {
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if DataStore.releases.isEmpty {
            return CGSize.zero
        }
        
		guard let section = Section.init(rawValue: section) else {
			assertionFailure("Unable to determine section.")
			return CGSize.zero
		}
		
		return section.releases.isEmpty ? CGSize.zero : CGSize(width: collectionView.frame.width, height: 80 + UIApplication.shared.statusBarFrame.height)
	}
	
	override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if DataStore.releases.isEmpty {
            return UICollectionReusableView()
        }
		
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
		header.secondaryLabel?.text = section.descriptor
		if section.descriptor == nil {
			header.secondaryLabel?.font = UIFont.systemFont(ofSize: 0)
		}
		
		return header
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if DataStore.releases.isEmpty {
            return CGSize(width: collectionView.frame.width, height: collectionView.frame.height-10)
        }
		
		guard let section = Section.init(rawValue: indexPath.section) else {
			assertionFailure("Unable to determine section.")
			return CGSize.zero
		}
		
		var width: CGFloat = collectionView.frame.width - 16
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
	
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}


class ReleasesRefreshControl: UIRefreshControl {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.frame.origin.y += UIApplication.shared.statusBarFrame.height
    }
}
