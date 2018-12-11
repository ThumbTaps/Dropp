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
//        self.navigationItem.leftBarButtonItem = self.editButtonItem
		
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
    
    @objc func gotoSettings() {
        self.performSegue(withIdentifier: "artists->Search", sender: self)
    }
    @objc func gotoSettingsWithSearch() {
        self.performSegue(withIdentifier: "artists->Search", sender: self.navigationItem.searchController?.searchBar.text)
    }
	
	
	
	func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
		indexPaths.forEach { (indexPath) in
			self.dataSource[indexPath.row].getArtwork(thumbnail: true)
		}
	}
    
	// MARK: - Table view data source
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.dataSource.isEmpty {
            return tableView.frame.height - (self.navigationController?.navigationBar.frame.height ?? 0)
        }
        
        return 60
    }
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.dataSource.isEmpty {
            return 1
        }
        
		return self.dataSource.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.dataSource.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "noArtistsCell", for: indexPath) as? NoResultsTableViewCell else {
                return UITableViewCell()
            }
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
            cell.actionButton.removeTarget(nil, action: nil, for: .touchUpInside)
            
            if self.isSearching {
                cell.iconImageView.image = UIImage(named: "Hero Icons/search")
                cell.descriptionLabel.text = "None of the artists you're following match your search."
                cell.actionButton.setTitle("Search for Artist", for: .normal)
                cell.actionButton.addTarget(self, action: #selector(self.gotoSettingsWithSearch), for: .touchUpInside)
                
                return cell
            }
            
            cell.iconImageView.image = UIImage(named: "Hero Icons/artists")
            cell.descriptionLabel.text = "You aren't following any artists yet."
            cell.actionButton.setTitle("Add an Artist", for: .normal)
            cell.actionButton.addTarget(self, action: #selector(self.gotoSettings), for: .touchUpInside)
            
            return cell
        }
        
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
		return !self.dataSource.isEmpty
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

