//
//  ChangeIconCollectionViewController.swift
//  Dropp
//
//  Created by Jeffery Jackson, Jr. on 11/24/18.
//  Copyright © 2018 Thumb Taps, LLC. All rights reserved.
//

import UIKit

class AlternateIconCollectionViewController: UICollectionViewController {
    
    struct Icon {
        var title: String?
        var imageName: String
    }
    
    var alternateIcons: [Icon] {
        guard let infoPlistPath = Bundle.main.path(forResource: "Info", ofType: "plist") else {
            return []
        }
        guard let infoPlistDictionary = NSDictionary(contentsOfFile: infoPlistPath) else {
            return []
        }
        guard let outerDictionary = infoPlistDictionary.object(forKey: "CFBundleIcons") as? NSDictionary else {
            return []
        }
        guard let alternateIconsDictionary = outerDictionary.object(forKey: "CFBundleAlternateIcons") as? NSDictionary else {
            return []
        }
        
        var alternateIcons = alternateIconsDictionary.compactMap({ (key, value) -> Icon? in
            guard let title = key as? String,
                let alternateIcon = value as? NSDictionary else {
                    return nil
            }
            
            var icon = Icon(title: title, imageName: "")
            
            guard let iconFiles = alternateIcon.object(forKey: "CFBundleIconFiles") as? NSArray else {
                return nil
            }
            
            guard let imageName = iconFiles[0] as? String else {
                return nil
            }
            
            icon.imageName = imageName.replacingOccurrences(of: ".appiconset", with: "")
            
            return icon
        })
        
        alternateIcons.insert(Icon(title: nil, imageName: "AppIcon"), at: 0)
        
        return alternateIcons
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard UIApplication.shared.supportsAlternateIcons else {
            let alertController = UIAlertController(title: "Alternate Icons Not Supported", message: "This device does not support the alternate icons feature.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (alertAction) in
                self.navigationController?.popViewController(animated: true)
            }))
            self.present(alertController, animated: true)
            return
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Do any additional setup after loading the view.
        print(alternateIcons)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.alternateIcons.count
    }
    
    

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "alternateIconCell", for: indexPath) as? AlternateIconCollectionViewCell else {
            assertionFailure("Unable to create alternate icon cell.")
            return UICollectionViewCell()
        }
    
        // Configure the cell
        cell.iconImageView.image = UIImage(named: self.alternateIcons[indexPath.row].imageName)
        
        guard let indexOfCurrentIcon = self.alternateIcons.firstIndex(where: { (icon) -> Bool in
            return icon.title == UIApplication.shared.alternateIconName
        }) else {
            cell.isSelected = indexPath.row == 0
            
            return cell
        }
        
        cell.isSelected = indexOfCurrentIcon == indexPath.row
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let indexOfCurrentIcon = self.alternateIcons.firstIndex(where: { (icon) -> Bool in
            return icon.title == UIApplication.shared.alternateIconName
        }) else {
            return false
        }
        
        return indexPath.row != indexOfCurrentIcon
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedIcon = self.alternateIcons[indexPath.row]
        
        UIApplication.shared.setAlternateIconName(selectedIcon.title) { (error) in
            guard error == nil else {
                let alertController = UIAlertController(title: "Unable to Change Icon", message: "There was an issue changing the application icon.", preferredStyle: .alert)
                self.present(alertController, animated: true)
                
                return
            }
            
            self.collectionView.reloadData()
        }
    }

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


extension AlternateIconCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 4, height: collectionView.frame.width / 4)
    }
}
