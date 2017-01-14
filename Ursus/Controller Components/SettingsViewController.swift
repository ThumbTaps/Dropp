//
//  SettingsViewController.swift
//  Ursus
//
//  Created by Jeffery Jackson, Jr. on 1/8/17.
//  Copyright © 2017 Jeffery Jackson, Jr. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet weak var tableView: UITableView!
	
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
		Notification.Name.UrsusThemeDidChange.add(self, selector: #selector(self.themeDidChange))

    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
	}

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	
	func themeDidChange() {
		
		if PreferenceManager.shared.themeMode == .dark {
			
			self.view.tintColor = StyleKit.darkIconGlyphColor
			self.view.backgroundColor = StyleKit.darkTintColor
		} else {
			
			self.view.tintColor = StyleKit.lightIconGlyphColor
			self.view.backgroundColor = StyleKit.lightTintColor
		}
	}
	
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
	
	
	
	
	
	// MARK: - UITableViewDataSource
	func numberOfSections(in tableView: UITableView) -> Int {
		
		return 1
	}
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		return 1
	}
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		var cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "BasicSetting")!
		
		switch indexPath.section {
		case 0:
			break
		default: break
		}
		
		return cell
	}
}
