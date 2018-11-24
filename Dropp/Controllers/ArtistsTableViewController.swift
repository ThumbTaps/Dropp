//
//  ArtistsTableViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 7/18/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

class ArtistsTableViewController: UITableViewController,
	UITableViewDataSourcePrefetching,
	UISearchControllerDelegate,
UISearchResultsUpdating {
	
	var isSearching: Bool {
		return !(self.navigationItem.searchController?.searchBar.text?.isEmpty ?? true)
	}
	var filtered: [Artist] = []
	var dataSource: [Artist] {
		return self.isSearching ? self.filtered : DataStore.followedArtists
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
		self.navigationItem.leftBarButtonItem = self.editButtonItem
		
		self.navigationItem.searchController = UISearchController(searchResultsController: nil)
		if let searchBar = self.navigationItem.searchController?.searchBar {
			searchBar.autocapitalizationType = .words
			self.navigationItem.titleView?.addSubview(searchBar)
		}
		
		self.navigationItem.searchController?.delegate = self
		self.navigationItem.searchController?.searchResultsUpdater = self
		self.navigationItem.searchController?.dimsBackgroundDuringPresentation = false
		self.navigationItem.searchController?.searchBar.tintColor = self.view.tintColor
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		self.tableView.reloadData()
	}
	
	func didPresentSearchController(_ searchController: UISearchController) {
		DispatchQueue.main.async {
			searchController.searchBar.becomeFirstResponder()
		}
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		if self.isSearching {
			self.filtered = DataStore.followedArtists.filter({ (artist) -> Bool in
				return artist.name.lowercased().range(of: searchController.searchBar.text?.lowercased() ?? "") != nil
			})
		} else {
			self.filtered = []
		}
		
		self.tableView.reloadData()
	}
	
	
	
	func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { (indexPath) in
			self.dataSource[indexPath.row].getArtwork(thumbnail: true)
		}
	}
	// MARK: - Table view data source
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.dataSource.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "artistCell", for: indexPath) as? ArtistTableViewCell else {
			return UITableViewCell()
		}
		
		let artist = self.dataSource[indexPath.row]
		
		// Configure the cell...
		cell.nameLabel?.text = artist.name
		DispatchQueue.global().async {
			artist.getArtwork(thumbnail: true) { (image, error) in
				DispatchQueue.main.async {
					cell.artworkImageView.image = image
				}
			}
		}
		
		return cell
	}
	
	// Override to support conditional editing of the table view.
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		// Return false if you do not want the specified item to be editable.
		return true
	}
	
	// Override to support editing the table view.
	override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		return [
			UITableViewRowAction(style: .destructive, title: "Unfollow", handler: { (_, indexPath) in
				self.tableView(tableView, commit: .delete, forRowAt: indexPath)
			})
		]
	}
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		
		if editingStyle == .delete {
			// Delete the row from the data source
			self.dataSource[indexPath.row].unfollow()
			tableView.deleteRows(at: [indexPath], with: .bottom)
		}
	}
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
	
	/*
	// Override to support rearranging the table view.
	override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
	
	}
	*/
	
	/*
	// Override to support conditional rearranging of the table view.
	override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
	// Return false if you do not want the item to be re-orderable.
	return true
	}
	*/
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Get the new view controller using segue.destination.
		// Pass the selected object to the new view controller.
		if segue.identifier == "artists->Artist" {
			guard let destination = segue.destination as? ArtistViewController,
				let selectedRow = self.tableView.indexPathForSelectedRow?.row else {
                    assertionFailure("Unable to determine selected row.")
					return
			}
			destination.artist = self.dataSource[selectedRow]
		}
	}
    
    @IBAction func unwind(segue: UIStoryboardSegue) {}
}

