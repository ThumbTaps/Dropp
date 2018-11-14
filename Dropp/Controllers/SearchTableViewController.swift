//
//  SearchTableViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 7/15/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

class SearchTableViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating {
	
	private enum Section: Int {
		case SearchResults, ImportOptions
		
		static func count() -> Int {
			return self.ImportOptions.rawValue + 1
		}
		
		var reuseIdentifier: String {
			switch self {
			case .SearchResults:
				return "searchResultCell"
			case .ImportOptions:
				return "importArtistsCell"
			}
		}
		
		var title: String {
			switch self {
			case .SearchResults:
				return "Search Results"
			case .ImportOptions:
				return ""
			}
		}
		
		var rowHeight: CGFloat {
			switch self {
			case .SearchResults:
				return 44
			case .ImportOptions:
				return 50
			}
		}
	}
	
	var searchResults: [Artist] = []
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.searchController = UISearchController(searchResultsController: nil)
		if let searchBar = self.navigationItem.searchController?.searchBar {
			searchBar.tintColor = self.view.tintColor
			searchBar.autocapitalizationType = .words
			searchBar.placeholder = ["Phantogram", "Conor Oberst", "Kendrick Lamar", "J. Cole", "Glass Animals", "Eminem", "Jenny Lewis", "Electric Guest", "The Strokes", "Domo Genesis", "Death Cab for Cutie", "The Decemberists", "The Front Bottoms", "Modern Baseball", "Andrew Bird", "Okkervil River", "Radiohead", "The Shins", "Vampire Weekend", "Vince Staples", "2Pac"].randomElement()
			
			self.navigationItem.titleView?.addSubview(searchBar)
		}
		
		self.navigationItem.searchController?.delegate = self
		self.navigationItem.searchController?.searchResultsUpdater = self
		self.navigationItem.searchController?.dimsBackgroundDuringPresentation = false
		self.navigationItem.hidesSearchBarWhenScrolling = false

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.navigationItem.searchController?.isActive = true
	}
	
	func didPresentSearchController(_ searchController: UISearchController) {
		DispatchQueue.main.async {
			searchController.searchBar.becomeFirstResponder()
		}
	}

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return Section.count()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let section = Section.init(rawValue: section) else {
			assertionFailure("Unable to determine section.")
			return 0
		}
		
		switch section {
		case .SearchResults:
			return self.searchResults.count
			
		case .ImportOptions:
			return 1
		}
    }
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		guard let section = Section.init(rawValue: section) else {
			assertionFailure("Unable to determine section.")
			return ""
		}
		
		return section.title
	}

	override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		guard let section = Section.init(rawValue: indexPath.section) else {
			assertionFailure("Unable to determine section.")
			return 0
		}
		
		return section.rowHeight
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let section = Section.init(rawValue: indexPath.section) else {
			assertionFailure("Unable to determine section.")
			return UITableViewCell()
		}
		
		let cell = tableView.dequeueReusableCell(withIdentifier: section.reuseIdentifier, for: indexPath)
		
		switch section {
		case .SearchResults:
            (cell as? SearchResultTableViewCell)?.artistNameLabel.text = self.searchResults[indexPath.row].name
            (cell as? SearchResultTableViewCell)?.followButton.isHidden = !self.searchResults[indexPath.row].isFollowed
			break
			
		case .ImportOptions:
			break
		}

        return cell
    }
	
	
	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		guard let section = Section.init(rawValue: indexPath.section) else {
			assertionFailure("Unable to determine section.")
			return false
		}
		
		switch section {
		case .SearchResults:
			let artist = self.searchResults[indexPath.row]
			return !artist.isFollowed
			
		case .ImportOptions:
			return false
		}
	}
	
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let followAction = UITableViewRowAction(style: .normal, title: "Follow", handler: { (_, indexPath) in
			self.searchResults[indexPath.row].follow()
			tableView.reloadRows(at: [indexPath], with: .none)
		})
		followAction.backgroundColor = self.view.tintColor
		
		return [
			followAction
		]
	}
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		if editingStyle == .delete {
			// Delete the row from the data source
			DataStore.followedArtists[indexPath.row].unfollow()
			tableView.deleteRows(at: [indexPath], with: .bottom)
		}
	}

	
	
	// MARK - Search Results Updating
	func updateSearchResults(for searchController: UISearchController) {

		Artist.search(named: searchController.searchBar.text) { (artists, error) in
			guard error == nil else {
				print(error!)
				return
			}
			
			guard artists != nil else {
				return
			}
			
			self.searchResults = artists!
			
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}
	


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
		if segue.identifier == "search->Artist" {
			guard let destination = segue.destination as? ArtistViewController,
				let selectedRow = self.tableView.indexPathForSelectedRow?.row else {
					return
			}
			destination.artist = self.searchResults[selectedRow]
		}
    }
    
    @IBAction func unwind(segue: UIStoryboardSegue) {}
}
